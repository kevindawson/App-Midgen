package App::Midgen;

use v5.10;
use strict;
use warnings;
use Moo;
with qw( App::Midgen::Roles );
use App::Midgen::Output;

our $VERSION = '0.08';
use English qw( -no_match_vars ); # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use CPAN;
use Carp;
use Cwd;
use Data::Printer {
	caller_info => 1,
	colored     => 1,
};
use File::Spec;
use File::Find qw(find);
use File::Slurp qw(read_file write_file);
use Module::CoreList;
use PPI;
use Try::Tiny;
use constant {
	BLANK => qq{ },
	NONE  => q{},
};



#######
# run
#######
sub run {
	my $self = shift;
	$self->initialise();
	try {
		$self->first_package_name();
	};
	$self->output_header();

	$self->find_required_modules();
	$self->remove_noisy_children( $self->{requires} ) if ( !$self->{verbose} );
	$self->output_main_body( 'requires', $self->{requires} );

	$self->find_required_test_modules();
	$self->output_main_body( 'test_requires', $self->{test_requires} );
	$self->output_footer();

	print "\n";

	return;
}

#######
# initialise
#######
sub initialise {
	my $self = shift;
	$self->{output} = App::Midgen::Output->new;

	# stop rlib from Fing all over cwd
	$self->{working_dir} = cwd();
	say 'working in dir: ' . $self->{working_dir} if $self->{debug};

	# set up cpan bit's as well as checking we are up to date
	CPAN::HandleConfig->load;
	CPAN::Shell::setup_output;
	CPAN::Index->reload;
	return;
}

#######
# first_package_name
#######
sub first_package_name {
	my $self = shift;

	try {
		find( sub { find_package_names($self); }, File::Spec->catfile( $self->{working_dir}, 'lib' ) );
	};

	p $self->{package_names} if $self->{debug};

	# We will assume the first package found is our Package Name, pot lock :)
	$self->{package_name} = $self->{package_names}[0];
	say 'Package: ' . $self->{package_name} if $self->{verbose};

	return;
}
#######
# find_package_name
#######
sub find_package_names {
	my $self     = shift;
	my $filename = $_;

	# Only check in pm files
	return if $filename !~ /[.]pm$/sxm;

	# Load a Document from a file
	my $document = PPI::Document->new($filename);

	# Extract package names
	push @{ $self->{package_names} }, $document->find_first('PPI::Statement::Package')->namespace;

	return;
}


#######
# find_required_modules
#######
sub find_required_modules {
	my $self = shift;

	# By default we shell only check lib and script (to bin or not?)
	my @posiable_directories_to_search = map { File::Spec->catfile( $self->{working_dir}, $_ ) } qw( lib script );

	my @directories_to_search = ();
	for my $directory (@posiable_directories_to_search) {
		if ( defined -d $directory ) {
			push @directories_to_search, $directory;
		}
	}
	p @directories_to_search if $self->{debug};

	try {
		find( sub { find_makefile_requires($self); }, @directories_to_search );
	};

	return;

}
#######
# find_required_modules
#######
sub find_required_test_modules {
	my $self = shift;

	my @posiable_directories_to_search = File::Spec->catfile( $self->{working_dir}, 't' );
	my @directories_to_search = ();
	for my $directory (@posiable_directories_to_search) {
		if ( defined -d $directory ) {
			push @directories_to_search, $directory;
		}
	}

	try {
		find( sub { find_makefile_test_requires($self); }, @directories_to_search );
	};

	return;

}

#######
# find_makefile_requires
#######
sub find_makefile_requires {
	my $self     = shift;
	my $filename = $_;
	my $document = PPI::Document->new($filename);
	return
		unless ( defined $document->find('PPI::Statement::Package')
		|| $document->find('PPI::Token::Comment') =~ /perl$/ );

	if ( $self->{verbose} ) {
		say 'looking for requires in -> ' . $filename;
	}

	my $ppi_i = $document->find('PPI::Statement::Include');
	p $ppi_i if $self->{debug};

	if ($ppi_i) {
		foreach my $include ( @{$ppi_i} ) {
			p $include if $self->{debug};
			next if $include->type eq 'no';

			my @modules = $include->module;
			p @modules if $self->{debug};
			if ( !$self->{base_parent} ) {
				my @base_parent_modules = $self->base_parent( $include->module, $include->content, $include->pragma );
				if (@base_parent_modules) {
					@modules = @base_parent_modules;
				}

			}

			foreach my $module (@modules) {
				p $module if $self->{debug};

				if ( !$self->{core} ) {
					p $module if $self->{debug};

					# hash with core modules to process regardless
					my $ignore_core = { 'File::Path' => 1, };
					if ( !$ignore_core->{$module} ) {
						next if Module::CoreList->first_release($module);
					}
				}

				#deal with ''
				next if $module eq NONE;
				if ( $module =~ /^$self->{package_name}/sxm ) {

					# Tommy here is were we ignore current package children
					# don't include our own packages here
					next;
				}
				if ( $module =~ /Mojo/sxm && !$self->{mojo} ) {
					$module = 'Mojolicious';
				}
				if ( $module =~ /^Padre/sxm && $module !~ /^Padre::Plugin::/sxm && !$self->{padre} ) {

					# mark all Padre core as just Padre, for plugins
					$module = 'Padre';
				}

				$self->store_modules( 'requires', $module );
			}
		}
	}

	return;
}


#######
# find_makefile_test_requires
#######
sub find_makefile_test_requires {
	my $self     = shift;
	my $filename = $_;
	return if $filename !~ /[.]t|pm$/sxm;

	if ( $self->{verbose} ) {
		say 'looking for test_requires in: ' . $filename;
	}

	# Load a Document from a file and check use and require contents
	my $document = PPI::Document->new($filename);
	my $ppi_i    = $document->find('PPI::Statement::Include');

	if ($ppi_i) {
		foreach my $include ( @{$ppi_i} ) {
			next if $include->type eq 'no';

			my @modules = $include->module;

			if ( !$self->{base_parent} ) {
				my @base_parent_modules = $self->base_parent( $include->module, $include->content, $include->pragma );
				if (@base_parent_modules) {
					@modules = @base_parent_modules;
				}
			}

			$self->process_found_modules( \@modules );
		}
	}

	# Hack for use_ok in test files, Ouch!
	# Now lets double check the ptq-Single hidden in a test file
	my $ppi_tqs = $document->find('PPI::Token::Quote::Single');
	if ($ppi_tqs) {
		my @modules;
		foreach my $include ( @{$ppi_tqs} ) {
			if ( $include->content =~ /::/ && $include->content !~ /main/ && !$include->content =~ /use/ ) {
				my $module = $include->content;
				$module =~ s/^[']//;
				$module =~ s/[']$//;
				$module =~ s/(\s[\w|\s]+)$//;
				p $module if $self->{debug};

				# if we have found it already ignore it
				if ( !$self->{requires}{$module} ) {
					push @modules, $module;
				}
			}
			if ( $include->content =~ /::/ && $include->content =~ /use/ ) {
				my $module = $include->content;

				#ToDo test for duplicates and rubbish, part 1 done more to do

				$module =~ s/^[']//;
				$module =~ s/[']$//;
				$module =~ s/^use\s//;
				p $module if $self->{debug};

				# if we have found it already ignore it
				if ( !$self->{requires}{$module} ) {
					push @modules, $module;
				}
			}

			# if we found a modules, process it
			if ( scalar @modules > 0 ) {
				p @modules if $self->{debug};
				$self->process_found_modules( \@modules );
			}
		}
	}

	# Now lets double check the ptq-Doubles hidden in a test file - why O why - rtfm pbp
	my $ppi_tqd = $document->find('PPI::Token::Quote::Double');
	if ($ppi_tqd) {
		my @modules;
		foreach my $include ( @{$ppi_tqd} ) {

			if ( $include->content =~ /::/ && $include->content =~ /use/ ) {
				my $module = $include->content;
				$module =~ s/^["]//;
				$module =~ s/["]$//;
				$module =~ s/^use\s//;
				$module =~ s/(\s[\s|\w|\n|.|;]+)$//;
				p $module if $self->{debug};

				# if we have found it already ignore it
				if ( !$self->{requires}{$module} ) {
					push @modules, $module;
				}
			}

			# if we found a modules, process it
			if ( scalar @modules > 0 ) {
				p @modules if $self->{debug};
				$self->process_found_modules( \@modules );
			}
		}
	}

	return;
}

#######
# composed method - process_found_modules
#######
sub process_found_modules {
	my $self = shift;

	my $modules_ref = shift;
	my @items       = ();

	foreach my $module ( @{$modules_ref} ) {
		if ( !$self->{core} ) {

			p $module if $self->{debug};

			# hash with core modules to process regardless
			# don't ignore Test::More so as to get done_testing mst++
			my $ignore_core = { 'Test::More' => 1, };
			if ( !$ignore_core->{$module} ) {
				next if Module::CoreList->first_release($module);
			}
		}

		#deal with ''
		next if $module eq NONE;
		if ( $module =~ /^$self->{package_name}/sxm ) {

			# don't include our own packages here
			next;
		}
		if ( $module =~ /Mojo/sxm && !$self->{mojo} ) {
			$module = 'Mojolicious';
		}
		if ( $module =~ /^Padre/sxm && $module !~ /^Padre::Plugin::/sxm && !$self->{padre} ) {

			# mark all Padre core as just Padre, for plugins
			$module = 'Padre';
		}

		$self->store_modules( 'test_requires', $module );

	}
	return;
}

#######
# composed method - store_modules
#######
sub store_modules {
	my $self         = shift;
	my $require_type = shift;
	my $module       = shift;

	my $mod;
	my $mod_in_cpan = 0;
	try {
		$mod = CPAN::Shell->expand( 'Module', $module );

		if ( $mod->cpan_version ne 'undef' ) {

			# allocate current cpan version against module name
			$mod_in_cpan = 1;
		}

	}
	catch {
		say "caught - $require_type - $module" if $self->{debug};

		# exclude modules in test dir
		if ( $require_type eq 'requires' ) {
			$self->{$require_type}{$module} = 0;
		} elsif ( $module !~ /^t::/ && $self->{requires}{$module} ) {
			$self->{$require_type}{$module} = 0;
		} elsif ( not defined $self->{requires}{$module} ) {
			$self->{$require_type}{$module} = 0;
		}

	}
	finally {
		if ( $mod_in_cpan && !$self->{requires}{$module} ) {

			# allocate current cpan version against module name
			$self->{$require_type}{$module} = $mod->cpan_version;
		}
	};

	return;
}

#######
# base_parent
#######
sub base_parent {
	my $self    = shift;
	my $module  = shift;
	my $content = shift;
	my $pragma  = shift;
	my @modules = ();
	if ( $module =~ /base|parent/sxm ) {

		if ( $self->{verbose} ) {
			say 'Info: check ' . $pragma . ' pragma: ';
			say $content;
		}

		$content =~ s/^use (base|parent) //;

		$content =~ s/^qw[\<|\(|\{|\[]\n?\t?\s*//;
		$content =~ s/\s*[\>|\)|\}|\]];\n?\t?$//;
		$content =~ s/(\n\t)/, /g;

		@modules = split /, /, $content;
		push @modules, $module;
		p @modules if $self->{debug};
	}
	return @modules;
}

#######
# remove_noisy_children
#######
sub remove_noisy_children {
	my $self = shift;
	my $required_ref = shift || return;
	my @sorted_modules;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		push @sorted_modules, $module_name;
	}

	p @sorted_modules if $self->{debug};

	my $n = 0;
	while ( $sorted_modules[$n] ) {

		my $parent_name  = $sorted_modules[$n];
		my @p_score      = split /::/, $parent_name;
		my $parent_score = @p_score;

		my $child_score;
		if ( ( $n + 1 ) <= $#sorted_modules ) {
			$n++;

			# Use of implicit split to @_ is deprecated
			my $child_name = $sorted_modules[$n];
			$child_score = @{ [ split /::/, $child_name ] };
		}

		if ( $sorted_modules[$n] =~ /^$sorted_modules[$n-1]::/ ) {

			# Checking for one degree of separation
			# ie A::B -> A::B::C is ok but A::B::C::D is not
			if ( ( $parent_score + 1 ) == $child_score ) {

				# Test for same version number
				if ( $required_ref->{ $sorted_modules[ $n - 1 ] } eq $required_ref->{ $sorted_modules[$n] } ) {
					say 'delete miscreant noisy children '
						. $sorted_modules[$n] . ' ver '
						. $required_ref->{ $sorted_modules[$n] }
						if $self->{noisy_children};
					try {
						delete $required_ref->{ $sorted_modules[$n] };
						splice( @sorted_modules, $n, 1 );
						$n--;
					};
					p @sorted_modules if $self->{debug};
				}
			}
		}
		$n++ if ( $n == $#sorted_modules );
	}
	return;
}


#######
# output_header
#######
sub output_header {
	my $self = shift;

	given ( $self->{output_format} ) {

		when ('mi') {
			$self->{output}->header_mi( $self->{package_name} );
		}
		when ('dsl') {
			$self->{output}->header_dsl( $self->{package_name} );
		}
		when ('build') {
			$self->{output}->header_build( $self->{package_name} );
		}
		when ('dzil') {
			$self->{output}->header_dzil( $self->{package_name} );
		}
	}
	return;
}
#######
# output_main_body
#######
sub output_main_body {
	my $self         = shift;
	my $title        = shift || 'title missing';
	my $required_ref = shift || return;

	given ( $self->{output_format} ) {

		when ('mi') {
			$self->{output}->body_mi($title, $required_ref);
		}
		when ('dsl') {
			$self->{output}->body_dsl($title, $required_ref );
		}
		when ('build') {
			$self->{output}->body_build($title, $required_ref );
		}
		when ('dzil') {
			$self->{output}->body_dzil($title, $required_ref );
		}
	}

	return;
}
#######
# output_footer
#######
sub output_footer {
	my $self = shift;
	
	given ( $self->{output_format} ) {

		when ('mi') {
			$self->{output}->footer_mi( );
		}
		when ('dsl') {
			$self->{output}->footer_dsl( );
		}
		when ('build') {
			$self->{output}->footer_build( );
		}
		when ('dzil') {
			$self->{output}->footer_dzil( );
		}
	}

	return;
}


1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen - generate the requires and test requires sections for Makefile.PL

=head1 VERSION

This document describes App::Midgen version 0.08

=head1 SYNOPSIS

Change to root of package and run

 midgen

Now with a Getopt --help or -?

 midgen -?

See L<midgen> for more info.
 
=head1 DESCRIPTION

This started out as a way of generating the core for a Module::Install::DSL Makefile.PL, 
why DSL because it's nice and clean, so now I can generate the contents when I want, 
rather than as I add new use and require statements, and because Adam kicked me :)

For more info and sample output see L<wiki|https://github.com/kevindawson/App-Midgen/wiki>

=head1 METHODS

=over 4

=item * base_parent

=item * find_makefile_requires

=item * find_makefile_test_requires

=item * find_package_names

=item * find_required_modules

=item * find_required_test_modules

=item * first_package_name

=item * initialise

=item * output_footer

=item * output_header

=item * output_main_body

=item * process_found_modules

=item * remove_noisy_children

=item * run

=item * store_modules

=back


=head1 CONFIGURATION AND ENVIRONMENT
  
App::Midgen requires no configuration files or environment variables.


=head1 DEPENDENCIES

L<App::Midgen::Roles>, L<App::Midgen::Output>,

=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
through the web interface at
L<https://github.com/kevindawson/App-Midgen/issues>.
If reporting a Bug, also supply the Module info, midgen failed against.

=head1 AUTHOR

Kevin Dawson E<lt>bowtie@cpan.orgE<gt>

=head2 CONTRIBUTORS

none at present

=head1 COPYRIGHT

Copyright E<copy> 2013 AUTHOR and CONTRIBUTORS as listed above.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl 5 itself.

=head1 SEE ALSO

L<Perl::PrereqScanner>,
L<Module::Install::DSL>,

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

