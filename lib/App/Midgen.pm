package App::Midgen;

use v5.10;
use Moo;
with qw( App::Midgen::Roles );
use App::Midgen::Output;

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.14';
use English qw( -no_match_vars ); # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Carp;
use Cwd;
use Data::Printer { caller_info => 1, colored => 1, };
use File::Find qw(find);
use File::Spec;
use MetaCPAN::API;
use Module::CoreList;
use PPI;
use Perl::MinimumVersion;
use Perl::PrereqScanner;
use Scalar::Util qw(looks_like_number);
use Try::Tiny;

use constant {
	BLANK => qq{ },
	NONE  => q{},
	THREE => 3,
};
use version;

# stop rlib from Fing all over cwd
our $Working_Dir = cwd();
our $Min_Version = 0;

#######
# run
#######
sub run {
	my $self = shift;
	$self->_initialise();
	try {
		$self->first_package_name();
	};
	$self->_output_header();

	$self->find_required_modules();
	$self->find_required_test_modules();

	$self->remove_noisy_children( $self->{requires} );
	$self->remove_twins( $self->{requires} );

	# Run a second time if we found any twins, this will sort out twins and triplets etc
	$self->remove_noisy_children( $self->{requires} ) if $self->{found_twins};

	# Now we have switched to MetaCPAN-Api we can hunt for noisy children in test requires
	$self->remove_noisy_children( $self->{test_requires} );

	$self->_output_main_body( 'requires',      $self->{requires} );
	$self->_output_main_body( 'test_requires', $self->{test_requires} );
	$self->_output_main_body( 'recommends',    $self->{recommends} );

	$self->_output_footer();

	return;
}

#######
# initialise
#######
sub _initialise {
	my $self = shift;

	# let's give Output a copy, to stop it being Fup as well suspect Tiny::Path as-well
	say 'working in dir: ' . $Working_Dir if $self->{debug};

	$self->{output}  = App::Midgen::Output->new();
	$self->{scanner} = Perl::PrereqScanner->new();
	$self->{mcpan}   = MetaCPAN::API->new() || croak "arse: $ERRNO";

	return;
}

#######
# first_package_name
#######
sub first_package_name {
	my $self = shift;

	try {
		find( sub { _find_package_names($self); }, File::Spec->catfile( $Working_Dir, 'lib' ) );
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
sub _find_package_names {
	my $self     = shift;
	my $filename = $_;
	state $files_checked;
	if ( defined $files_checked ) {
		return if $files_checked >= THREE;
	}

	# Only check in pm files
	return if $filename !~ /[.]pm$/sxm;

	# Load a Document from a file
	$self->{ppi_document} = PPI::Document->new($filename);
	try {
		$self->min_version();
	};

	# Extract package names
	push @{ $self->{package_names} }, $self->{ppi_document}->find_first('PPI::Statement::Package')->namespace;
	$files_checked++;

	return;
}


#######
# find_required_modules
#######
sub find_required_modules {
	my $self = shift;

	# By default we shell only check lib and script (to bin or not?)
	my @posiable_directories_to_search = map { File::Spec->catfile( $Working_Dir, $_ ) } qw( script bin lib );

	my @directories_to_search = ();
	for my $directory (@posiable_directories_to_search) {
		if ( defined -d $directory ) {
			push @directories_to_search, $directory;
		}
	}
	p @directories_to_search if $self->{debug};

	try {
		find( sub { _find_makefile_requires($self); }, @directories_to_search );
	};

	return;

}
#######
# find_required_modules
#######
sub find_required_test_modules {
	my $self = shift;

	# By default we shell only check t\ (to xt\ or not?)
	my @posiable_directories_to_search = map { File::Spec->catfile( $Working_Dir, $_ ) } qw( t );
	my @directories_to_search = ();
	for my $directory (@posiable_directories_to_search) {
		if ( defined -d $directory ) {
			push @directories_to_search, $directory;
		}
	}

	try {
		find( sub { _find_makefile_test_requires($self); }, @directories_to_search );
	};

	return;

}

#######
# _find_makefile_requires
#######
sub _find_makefile_requires {
	my $self     = shift;
	my $filename = $_;
	$self->{ppi_document} = PPI::Document->new($filename);
	my $is_script = 0;

	given ($filename) {
		when (m/[.]pm$/) { say 'looking for requires in (.pm)-> ' . $filename if $self->{verbose}; }
		when (m/[.]\w{2,4}$/) { say 'rejecting ' . $filename if $self->{verbose}; return; }
		default { return if not $self->_is_perlfile($filename); $is_script = 1; }
	}
	try {
		$self->min_version() if $is_script;
	};

	my $prereqs = $self->{scanner}->scan_ppi_document( $self->{ppi_document} );
	my @modules = $prereqs->required_modules;

	$self->_process_found_modules( 'requires', \@modules );
	return;
}

########
# is this a perl file
#######
sub _is_perlfile {
	my $self     = shift;
	my $filename = shift;

	$self->{ppi_document} = PPI::Document->new($filename);
	my $ppi_tc = $self->{ppi_document}->find('PPI::Token::Comment');

	my $not_a_pl_file = 0;

	if ($ppi_tc) {

		# check first token-comment for a she-bang
		$not_a_pl_file = 1 if $ppi_tc->[0]->content =~ m/^#!.+perl.*$/;
	}

	if ( $self->{ppi_document}->find('PPI::Statement::Package') || $not_a_pl_file ) {
		if ( $self->{verbose} ) {

			print "looking for requires in (package) -> " if $self->{ppi_document}->find('PPI::Statement::Package');
			print "looking for requires in (shebang) -> " if $ppi_tc->[0]->content =~ /perl/;
			say $filename ;
		}
		return 1;
	} else {
		return 0;
	}

}


#######
# _find_makefile_test_requires
#######
sub _find_makefile_test_requires {
	my $self     = shift;
	my $filename = $_;
	return if $filename !~ /[.]t|pm$/sxm;

	say 'looking for test_requires in: ' . $filename if $self->{verbose};

	# Load a Document from a file and check use and require contents
	$self->{ppi_document} = PPI::Document->new($filename);

	my $prereqs = $self->{scanner}->scan_ppi_document( $self->{ppi_document} );
	my @modules = $prereqs->required_modules;

	p @modules if $self->{debug};

	$self->_process_found_modules( 'test_requires', \@modules );

	#These are really recommends
	$self->_recommends_in_single_quote();
	$self->_recommends_in_double_quote();

	return;
}


#######
# composed method - recommends_in_single_quote
#######
sub _recommends_in_single_quote {
	my $self = shift;

	# Hack for use_ok in test files, Ouch!
	# Now lets double check the ptq-Single hidden in a test file
	my $ppi_tqs = $self->{ppi_document}->find('PPI::Token::Quote::Single');
	if ($ppi_tqs) {
		my @modules;
		foreach my $include ( @{$ppi_tqs} ) {
			my $module = $include->content;
			$module =~ s/^[']//;
			$module =~ s/[']$//;

			if ( $module =~ /::/ && $module !~ /main/ && !$module =~ /use/ ) {

				$module =~ s/(\s[\w|\s]+)$//;
				p $module if $self->{debug};

				# if we have found it already ignore it - or - contains ;|=
				if ( !$self->{requires}{$module} && !$self->{test_requires}{$module} && $module !~ /[;|=]/ ) {
					push @modules, $module;
				}

				# if we found a module, process it
				if ( scalar @modules > 0 ) {
					$self->_process_found_modules( 'recommends', \@modules );
				}

			} elsif ( $module =~ /::/ && $module =~ /use/ ) {

				$module =~ s/^use\s//;
				$module =~ s/(\s[\s|\w|\n|.|;]+)$//;
				p $module if $self->{debug};

				# if we have found it already ignore it - or - contains ;|=
				if ( !$self->{requires}{$module} && !$self->{test_requires}{$module} && $module !~ /[;|=]/ ) {
					push @modules, $module;
				}

				# if we found a module, process it
				if ( scalar @modules > 0 ) {
					$self->_process_found_modules( 'recommends', \@modules );
				}
			}

		}
	}
	return;
}
#######
# composed method - recommends_in_double_quote
#######
sub _recommends_in_double_quote {
	my $self = shift;

	# Now lets double check the ptq-Doubles hidden in a test file - why O why - rtfm pbp
	my $ppi_tqd = $self->{ppi_document}->find('PPI::Token::Quote::Double');
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
				if ( !$self->{requires}{$module} && !$self->{test_requires}{$module} ) {
					push @modules, $module;
				}
			}

			# if we found a module, process it
			if ( scalar @modules > 0 ) {
				$self->_process_found_modules( 'recommends', \@modules );
			}
		}
	}
	return;
}

#######
# composed method - _process_found_modules
#######
sub _process_found_modules {
	my $self         = shift;
	my $require_type = shift;
	my $modules_ref  = shift;

	foreach my $module ( @{$modules_ref} ) {

		p $module if $self->{debug};

		#deal with ''
		next if $module eq NONE;

		given ($module) {
			when (/perl/sxm) {

				# ignore perl we will get it from minperl required
				next;
			}
			when (/^$self->{package_name}/sxm) {

				# don't include our own packages here
				next;
			}
			when (/^t::/sxm) {

				# don't include our own test packages here
				next;
			}
			when (/Mojo/sxm) {

				# $self->_check_mojo_core($module);
				$module = 'Mojolicious' if $self->_check_mojo_core($module);
			}
		}

		if ( $module =~ /^Padre/sxm && $module !~ /^Padre::Plugin::/sxm && !$self->{padre} ) {

			# mark all Padre core as just Padre, for plugins
			$module = 'Padre';
		}

		next if defined $self->{requires}{$module};
		next if defined $self->{test_requires}{$module};

		p $module if $self->{debug};

		# hash with core modules to process regardless
		my $ignore_core = { 'File::Path' => 1, 'Test::More' => 1, };
		if ( !$ignore_core->{$module} ) {

			# next if Module::CoreList->first_release($module);
			if ( Module::CoreList->first_release($module) ) {

				# Skip if we are not interested in core modules
				next if !$self->{core};

				# Assign a temp value to indicate a core module
				if ( $self->{core} && !$self->{zero} ) {
					$self->{$require_type}{$module} = 'core';
				} elsif ( $self->{core} && $self->{zero} ) {
					$self->{$require_type}{$module} = 0;
				}
			}
		}

		$self->_store_modules( $require_type, $module );
	}
	return;
}

#######
# composed method - _store_modules
#######
sub _store_modules {
	my $self         = shift;
	my $require_type = shift;
	my $module       = shift;
	p $module if $self->{debug};

	my $version = $self->get_module_version( $module, $require_type );
	given ($version) {

		when ('!mcpan') {
			$self->{$require_type}{$module} = '!mcpan' if not defined $self->{$require_type}{$module};
		}
		default {
			$self->{$require_type}{$module} = $version;
		}
	}

	return;
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
					if ( $self->{noisy_children} ) {
						print "\n";
						say 'delete miscreant noisy child '
							. $sorted_modules[$n] . ' => '
							. $required_ref->{ $sorted_modules[$n] };
					}
					try {
						delete $required_ref->{ $sorted_modules[$n] };
						splice @sorted_modules, $n, 1;
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
# remove_twins
#######
sub remove_twins {
	my $self = shift;
	my $required_ref = shift || return;
	my @sorted_modules;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		push @sorted_modules, $module_name;
	}

	p @sorted_modules if $self->{debug};

	# exit if only 1 Module found
	return if $#sorted_modules == 0;

	my $n = 0;
	while ( $sorted_modules[$n] ) {

		my $dum_name    = $sorted_modules[$n];
		my @p_score     = split /::/, $dum_name;
		my $dum_score   = @p_score;
		my $dum_parient = $dum_name;
		$dum_parient =~ s/(::\w+)$//;

		my $dee_score;
		my $dee_parient;
		my $dee_name;
		if ( ( $n + 1 ) <= $#sorted_modules ) {
			$n++;

			# Use of implicit split to @_ is deprecated
			$dee_name    = $sorted_modules[$n];
			$dee_score   = @{ [ split /::/, $dee_name ] };
			$dee_parient = $dee_name;
			$dee_parient =~ s/(::\w+)$//;
		}

		# Checking for same patient and score
		if ( $dum_parient eq $dee_parient && $dum_score == $dee_score ) {

			# Test for same version number
			if ( $required_ref->{ $sorted_modules[ $n - 1 ] } eq $required_ref->{ $sorted_modules[$n] } ) {

				if ( $self->{twins} ) {
					print "\n";
					say 'i have found twins';
					say $dum_name . ' ('
						. $required_ref->{ $sorted_modules[ $n - 1 ] }
						. ') <-twins-> '
						. $dee_name . ' ('
						. $required_ref->{ $sorted_modules[$n] } . ')';
				}

				#Check for vailed parent
				my $version;

				$version = $self->get_module_version($dum_parient);

				if ( looks_like_number($version) ) {

					#Check parent version against a twins version
					if ( $version eq $required_ref->{ $sorted_modules[$n] } ) {
						say $dum_parient . ' -> ' . $version . ' is the parent of these twins' if $self->{twins};
						$required_ref->{$dum_parient} = $version;
						$self->{found_twins} = 1;
					}
				}
			}
		}
		$n++ if ( $n == $#sorted_modules );
	}
	return;
}

#######
# _check_mojo_core
#######
sub _check_mojo_core {
	my $self        = shift;
	my $mojo_module = shift;
	my $mojo_module_ver;
	state $mojo_ver;

	if ( not defined $mojo_ver ) {
		$mojo_ver = $self->get_module_version('Mojolicious');
		p $mojo_ver if $self->{debug};
	}

	$mojo_module_ver = $self->get_module_version($mojo_module);

	if ( $self->{mojo} ) {
		say 'looks like we found another mojo core module';
		say $mojo_module . ' version ' . $mojo_module_ver;
	}

	# true if undef or version numbers match
	# undef is true as Mojo is missing version numbers in all sub modules - Fing idiots
	if ( $mojo_module_ver eq 'undef' ) {
		return 1;
	} elsif ( defined $mojo_module_ver ) {
		if ( $mojo_ver == $mojo_module_ver ) {
			return 1;
		}
	} else {
		return 0;
	}
}

#######
# get module version using metacpan_api
#######
sub get_module_version {
	my $self         = shift;
	my $module       = shift;
	my $require_type = shift || undef;
	my $cpan_version;
	my $found = 0;
	my $dist;

	try {
		$module =~ s/::/-/g;

		# quick n dirty, get version number if module is classed as a distribution in metacpan
		my $mod = $self->{mcpan}->release( distribution => $module );
		$cpan_version = version->parse( $mod->{version_numified} )->numify;

		# $cpan_version = $mod->{version_numified};

		$found = 1;
	}
	catch {
		try {
			$module =~ s/-/::/g;
			my $mcpan_module_info = $self->{mcpan}->module($module);
			$dist = $mcpan_module_info->{distribution};

			# mark all perl core modules with either 'core' or '0'
			if ( $dist eq 'perl' ) {
				if ( $self->{zero} ) {
					$cpan_version = version->parse(0)->numify;
				} else {
					$cpan_version = 'core';
				}
				$found = 1;
			}
		};
		if ( $found == 0 ) {
			try {
				my $mod = $self->{mcpan}->release( distribution => $dist );

				# $cpan_version = $mod->{version_numified};
				$cpan_version = version->parse( $mod->{version_numified} )->numify;
				$found        = 1;
				$self->mod_in_dist( $dist, $module, $require_type, $mod->{version_numified} ) if $require_type;
			}
		}
	}
	finally {
		# not in metacpan so mark accordingly
		$cpan_version = '!mcpan' if $found == 0;
	};
	return $cpan_version;
}
#######
# composed method
#######
sub mod_in_dist {
	my $self         = shift;
	my $dist         = shift;
	my $module       = shift;
	my $require_type = shift;
	my $version      = shift;

	# say 'bong';
	$dist =~ s/-/::/g;
	if ( $module =~ /$dist/ ) {

		# Do We need to do a degree of separation test also
		my $dist_score = split /::/, $dist;
		my $mod_score  = split /::/, $module;
		unless ( ( $dist_score + 1 ) == $mod_score ) {
			print 'Warning: this is out side of my scope, manual intervention required -> ';
			print "module - $module  -> in dist - $dist \n";
		}

		# say 'require_type - ' . $require_type;
		given ($require_type) {
			when ('requires') {

				# Add a what should be a parent
				$self->{$require_type}{$dist} = version->parse($version)->numify
					if !$self->{$require_type}{$dist};
			}
			when ('test_requires') {

				# say 'test_requires';
				next if $self->{requires}{$dist};
				$self->{$require_type}{$dist} = version->parse($version)->numify
					if !$self->{$require_type}{$dist};
			}
		}
	}


	return;
}


#######
# find min perl version
######
sub min_version {
	my $self = shift;

	# Create the version checking object
	my $object = Perl::MinimumVersion->new( $self->{ppi_document} );

	# Find the minimum version
	my $minimum_version = $object->minimum_version;
	$Min_Version =
		  version->parse($Min_Version) > version->parse($minimum_version)
		? version->parse($Min_Version)->numify
		: version->parse($minimum_version)->numify;


	my $minimum_explicit_version = $object->minimum_explicit_version;
	$Min_Version =
		  version->parse($Min_Version) > version->parse($minimum_explicit_version)
		? version->parse($Min_Version)->numify
		: version->parse($minimum_explicit_version)->numify;

	my $minimum_syntax_version = $object->minimum_syntax_version;
	$Min_Version =
		  version->parse($Min_Version) > version->parse($minimum_syntax_version)
		? version->parse($Min_Version)->numify
		: version->parse($minimum_syntax_version)->numify;

	say 'min_version - ' . $Min_Version if $self->{debug};

	return;
}

#######
# _output_header
#######
sub _output_header {
	my $self = shift;

	given ( $self->{output_format} ) {

		when ('mi') {
			$self->{output}->header_mi( $self->{package_name}, $self->get_module_version('inc::Module::Install') );
		}
		when ('dsl') {
			$self->{output}
				->header_dsl( $self->{package_name}, $self->get_module_version('inc::Module::Install::DSL') );
		}
		when ('build') {
			$self->{output}->header_build( $self->{package_name} );
		}
		when ('dzil') {
			$self->{output}->header_dzil( $self->{package_name} );
		}
		when ('dist') {
			$self->{output}->header_dist( $self->{package_name} );
		}
	}
	return;
}
#######
# _output_main_body
#######
sub _output_main_body {
	my $self         = shift;
	my $title        = shift || 'title missing';
	my $required_ref = shift || return;

	given ( $self->{output_format} ) {

		when ('mi') {
			$self->{output}->body_mi( $title, $required_ref );
		}
		when ('dsl') {
			$self->{output}->body_dsl( $title, $required_ref );
		}
		when ('build') {
			$self->{output}->body_build( $title, $required_ref );
		}
		when ('dzil') {
			$self->{output}->body_dzil( $title, $required_ref );
		}
		when ('dist') {
			$self->{output}->body_dist( $title, $required_ref );
		}
	}

	return;
}
#######
# _output_footer
#######
sub _output_footer {
	my $self = shift;

	given ( $self->{output_format} ) {

		when ('mi') {
			$self->{output}->footer_mi( $self->{package_name} );
		}
		when ('dsl') {
			$self->{output}->footer_dsl( $self->{package_name} );
		}
		when ('build') {
			$self->{output}->footer_build( $self->{package_name} );
		}
		when ('dzil') {
			$self->{output}->footer_dzil( $self->{package_name} );
		}
		when ('dist') {
			$self->{output}->footer_dist( $self->{package_name} );
		}
	}

	return;
}

no Moo;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen - Check B<requires> & B<test_rerquires> of your Package for CPAN inclusion.

=head1 VERSION

This document describes App::Midgen version: 0.14

=head1 SYNOPSIS

Change to the root of your package and run

 midgen

Now with a Getopt --help or -?

 midgen -?

See L<midgen> for cmd line option info.
 
=head1 DESCRIPTION

This is an aid to present a packages module requirements by scanning 
the package, 
then displaying in a familiar format with the current version number 
from MetaCPAN.

This started out as a way of generating the core for a Module::Install::DSL Makefile.PL, 
why DSL because it's nice and clean, 
so now you can generate the contents and check when you want, 
yes it's another L<PPI> powered app.

All output goes to STDOUT, so you can use it as you see fit.

=head3 MetaCPAN Version Number Displayed

=over 4

=item * NN.nnnnnn we got the current version number from MetaCPAN (numify).

=item * 'core' indicates the module is a perl core module.

=item * '!mcpan' must be local, one of yours. Not in MetaCPAN, Not in core.

=back

I<Food for thought, if we update our Modules, 
don't we want our users to use the current version, 
so should we not by default do the same with others Modules. 
Thus we always show the current version number, regardless.>

We also display some other info to complement the modules we have found.

For more info and sample output see L<wiki|https://github.com/kevindawson/App-Midgen/wiki>

=head1 METHODS

=over 4

=item * find_required_modules

Search for Includes B<use> and B<require> in package modules

=item * find_required_test_modules

Search for Includes B<use> and B<require> in test scripts, 
also B<use_ok>, I<plus some other patterns along the way.>

=item * first_package_name

Assume first package found is your packages name

=item * get_module_version

side affect of re-factoring, helps with code readability

=item * min_version

Uses L<Perl::MinimumVersion> to find the minimum version of your package by taking a quick look, 
I<note this is not a full scan, suggest you use L<perlver> for a full scan>.

=item * mod_in_dist

Check if module is in a distribution and use that version number, rather than 'undef'

=item * remove_noisy_children

Parent A::B has noisy Children A::B::C and A::B::D all with same version number.

=item * remove_twins

Twins E::F::G and E::F::H  have a parent E::F with same version number, 
so we add a parent E::F and re-test for noisy children, 
catching triplets along the way.

=item * run


=back


=head1 CONFIGURATION AND ENVIRONMENT
  
App::Midgen requires no configuration files or environment variables.


=head1 DEPENDENCIES

L<App::Midgen::Roles>, L<App::Midgen::Output>,

=head1 INCOMPATIBILITIES

After some reflection, we do not scan xt/... 
as the methods by which the modules  are Included are various, 
this is best left to the module Author. 

=head1 WARNINGS

As our mantra is to show the current version of a module, 
we do this by asking MetaCPAN directly so we are going to need to 
connect to L<http://api.metacpan.org/v0/>.


=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
through the web interface at
L<https://github.com/kevindawson/App-Midgen/issues>.
If reporting a Bug, also supply the Module info, midgen failed against.

=head1 AUTHOR

Kevin Dawson E<lt>bowtie@cpan.orgE<gt>

=head2 CONTRIBUTORS

Ahmad M. Zawawi E<lt>ahmad.zawawi@gmail.comE<gt>

Matt S. Trout E<lt>mst@shadowcat.co.ukE<gt>

Tommy Butler E<lt>ace@tommybutler.meE<gt>

Neil Bowers E<lt>neilb@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright E<copy> 2013 the App:Midgen L</AUTHOR> and L</CONTRIBUTORS> 
as listed above.


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
