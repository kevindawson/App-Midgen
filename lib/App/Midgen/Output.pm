package App::Midgen::Output;

use v5.10;
use Moo;

our $VERSION = '0.12';
use English qw( -no_match_vars ); # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Carp;
use CPAN;
use Data::Printer {
	caller_info => 1,
	colored     => 1,
};
use constant {
	BLANK => qq{ },
	NONE  => q{},
	THREE => 3,
};
use File::Spec;


#######
# header_dsl
#######
sub header_dsl {
	my $self = shift;
	my $package_name = shift // NONE;

	# Let's get the current version of Module::Install::DSL
	my $mod = CPAN::Shell->expand( 'Module', 'inc::Module::Install::DSL' );
	$package_name =~ s{::}{/}g;

	print "\n";
	say 'use inc::Module::Install::DSL ' . $mod->cpan_version . ';';
	print "\n";
	if ( $package_name ne NONE ) {
		say 'all_from lib/' . $package_name . '.pm';
		say 'requires_from lib/' . $package_name . '.pm';
	}

	return;
}
#######
# body_dsl
#######
sub body_dsl {
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift;
	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}

	foreach my $module_name ( sort keys %{$required_ref} ) {

		if ( $module_name =~ /^Win32/sxm ) {
			printf "%s %-*s %s if win32\n", $title, $pm_length, $module_name, $required_ref->{$module_name};
		} else {
			printf "%s %-*s %s\n", $title, $pm_length, $module_name, $required_ref->{$module_name};
		}
	}
	print "\n";
	return;
}
#######
# footer_dsl
#######
sub footer_dsl {
	my $self = shift;

	print "\n";
	say '#ToDo you should consider the following';
	say "homepage\t...";
	say "bugtracker\t...";
	say "repository\t...";

	print "\n";
	if ( defined -d File::Spec->catfile( $App::Midgen::Working_Dir, './share' ) ) {
		say 'install_share';
		print "\n";
	}

	if ( defined -d File::Spec->catfile( $App::Midgen::Working_Dir, './script' ) ) {
		say 'install_script ...';
		print "\n";
	} elsif ( defined -d File::Spec->catfile( $App::Midgen::Working_Dir, './bin' ) ) {
		say "install_script bin/...";
		print "\n";
	}

	my @no_index = $self->no_index;
	if (@no_index) {
		say "no_index directory qw{ @no_index }";
		print "\n";
	}

	# say 'no_index directory  qw{ t xt eg share inc privinc }';
	print "\n";

	return;
}


#######
# header_mi
#######
sub header_mi {
	my $self = shift;
	my $package_name = shift // NONE;
	$package_name =~ s{::}{/}g;

	print "\n";
	if ( $package_name ne NONE ) {
		say "all_from 'lib/$package_name.pm';";
	}
	print "\n";

	return;
}
#######
# body_mi
#######
sub body_mi {
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift;
	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}

	foreach my $module_name ( sort keys %{$required_ref} ) {

		if ( $module_name =~ /^Win32/sxm ) {
			my $sq_key = "'$module_name'";
			printf "%s %-*s => '%s' if win32;\n", $title, $pm_length + 2, $sq_key, $required_ref->{$module_name};
		} else {
			my $sq_key = "'$module_name'";
			printf "%s %-*s => '%s';\n", $title, $pm_length + 2, $sq_key, $required_ref->{$module_name};
		}

	}
	print "\n";
	return;
}
#######
# footer_mi
#######
sub footer_mi {
	my $self = shift;

	print "\n";
	say '#ToDo you should consider the following';
	say "homepage\t'...';";
	say "bugtracker\t'...';";
	say "repository\t'...';";
	print "\n";

	if ( defined -d File::Spec->catfile( $App::Midgen::Working_Dir, './share' ) ) {
		say 'install_share;';
		print "\n";
	}

	if ( defined -d File::Spec->catfile( $App::Midgen::Working_Dir, './script' ) ) {
		say "install_script 'script/...';";
		print "\n";
	} elsif ( defined -d File::Spec->catfile( $App::Midgen::Working_Dir, './bin' ) ) {
		say "install_script 'bin/...';";
		print "\n";
	}

	my @no_index = $self->no_index;
	if (@no_index) {
		say "no_index directory qw{ @no_index };";
		print "\n";
	}

	# say 'no_index directory  qw{ t xt eg share inc privinc }';
	say 'WriteAll';
	print "\n";

	return;
}


#######
# header_build
#######
sub header_build {
	my $self = shift;
	my $package_name = shift // NONE;

	# print "\n";
	# say "WriteMakefile(";
	if ( $package_name ne NONE ) {
		print "\n";
		$package_name =~ s{::}{-}g;
		say 'NAME => ' . $package_name;
		# $package_name =~ tr{-}{/};
		# say "VERSION_FROM => lib/$package_name.pm";
		print "\n";
	}

	return;
}
#######
# body_build
#######
sub body_build {
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift;
	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}

	say $title . ' => {';

	foreach my $module_name ( sort keys %{$required_ref} ) {

		my $sq_key = "'$module_name'";
		printf "\t %-*s => '%s',\n", $pm_length + 2, $sq_key, $required_ref->{$module_name};

	}
	say '},';
	print "\n";
	return;
}
#######
# footer_build
#######
sub footer_build {
	my $self = shift;

	# print "\n";
	# say ');';
	print "\n";

	return;
}


#######
# header_dzil
#######
sub header_dzil {
	my $self = shift;
	my $package_name = shift // NONE;

	# print "\n";
	# say 'dzil header underdevelopment';
	# print "\n";

	return;
}
#######
# body_dzil
#######
sub body_dzil {
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift;
	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}

	given ($title) {
		when ('requires')      { say '"PREREQ_PM" => {'; }
		when ('test_requires') { say '"BUILD_REQUIRES" => {'; }
		when ('recommends')    { return; }
	}

	foreach my $module_name ( sort keys %{$required_ref} ) {

		my $sq_key = '"' . $module_name . '"';
		printf "\t %-*s => '%s',\n", $pm_length + 2, $sq_key, $required_ref->{$module_name};

	}
	say '},';
	print "\n";
	return;
}
#######
# footer_dzil
#######
sub footer_dzil {
	my $self = shift;

	# print "\n";
	# say 'dzil footer underdevelopment';
	print "\n";

	return;
}


#######
# header_dist
#######
sub header_dist {
	my $self = shift;
	my $package_name = shift // NONE;

	if ( $package_name ne NONE ) {
		print "\n";
		$package_name =~ s{::}{-}g;
		say 'name        = ' . $package_name;
		$package_name =~ tr{-}{/};
		say "main_module = lib/$package_name.pm";
		print "\n";
	}

	return;
}
#######
# body_dist
#######
sub body_dist {
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift;
	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}
	given ($title) {
		when ('requires')      { say '[Prereqs]'; }
		when ('test_requires') { say '[Prereqs / TestRequires]'; }
		when ('recommends')    { say '[Prereqs / RuntimeRecommends]'; }
	}

	foreach my $module_name ( sort keys %{$required_ref} ) {

		# my $sq_key = '"' . $module_name . '"';
		printf "%-*s = %s\n", $pm_length, $module_name, $required_ref->{$module_name};

	}
	print "\n";
	return;
}
#######
# footer_dist
#######
sub footer_dist {
	my $self = shift;

	print "\n";
	say '#ToDo you should consider the following';
	say '[MetaResources]';
	say 'homepage          = ...';
	say 'bugtracker.web    = ...';
	say 'bugtracker.mailto = ...';
	say 'repository.url    = ...';
	say 'repository.web    = ...';
	say 'repository.type   = ...';
	print "\n";

	my @no_index = $self->no_index;
	if (@no_index) {
		say '[MetaNoIndex]';
		for (@no_index) {
			say "directory = $_" if $_ ne 'inc';
		}
		print "\n";
	}

	return;
}

#######
# no_index
#######
sub no_index {
	my $self = shift;

	#ToDo add more options as and when
	my @dirs_to_check = qw( corpus eg examples fbp inc maint misc privinc share t xt );
	my @dirs_found;

	for (@dirs_to_check) {

		#ignore synatax warning for global
		push @dirs_found, $_ if -d File::Spec->catfile( $App::Midgen::Working_Dir, $_ );
	}
	return @dirs_found;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Output - A collection of output orinated methods used by L<App::Midgen> 

=head1 VERSION

This document describes App::Midgen::Output version: 0.12

=head1 METHODS

=over 4

=item * header_dsl

=item * body_dsl

=item * footer_dsl

=item * header_mi

=item * body_mi

=item * footer_mi

=item * header_build

=item * body_build

=item * footer_build

=item * header_dzil

=item * body_dzil

=item * footer_dzil

=item * header_dist

=item * body_dist

=item * footer_dist

=item * no_index

Suggest some of your local directories you can 'no_index'

=back

=head1 SEE ALSO

L<App::Midgen>,

=head1 AUTHOR

See L<App::Midgen>

=head2 CONTRIBUTORS

See L<App::Midgen>

=head1 COPYRIGHT

See L<App::Midgen>

=head1 LICENSE

See L<App::Midgen>

=cut
