package App::Midgen::Output;

use v5.10;
use Moo;
# turn off experimental warnings
no if $] > 5.017010, warnings => 'experimental::smartmatch';

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.23';
use English qw( -no_match_vars ); # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Term::ANSIColor qw( :constants colored );
use Data::Printer { caller_info => 1, colored => 1, };
use constant { BLANK => q{ }, NONE => q{}, THREE => 3, };
use File::Spec;

#######
# header_dsl
#######
sub header_dsl {
	my $self         = shift;
	my $package_name = shift // NONE;
	my $mi_ver       = shift // NONE;

	$package_name =~ s{::}{/}g;

	print "\n";
	say 'use inc::Module::Install::DSL ' . colored( $mi_ver, 'yellow' ) . q{;};
	print "\n";
	if ( $package_name ne NONE ) {
		say 'all_from lib/' . $package_name . '.pm';
		say 'requires_from lib/' . $package_name . '.pm';
	}

	print "\n";
	return;
}
#######
# body_dsl
#######
sub body_dsl {
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift || return;
	say 'perl_version ' . $App::Midgen::Min_Version if $title eq 'requires';
	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}

	foreach my $module_name ( sort keys %{$required_ref} ) {

		if ( $module_name =~ /^Win32/sxm ) {
			printf "%s %-*s %s %s\n", $title, $pm_length, $module_name,
				$required_ref->{$module_name}, colored( 'if win32', 'bright_green' );
		} else {
			printf "%s %-*s %s\n", $title, $pm_length, $module_name, $required_ref->{$module_name};
		}
	}
	return;
}
#######
# footer_dsl
#######
sub footer_dsl {
	my $self = shift;
	my $package_name = shift // NONE;
	$package_name =~ s{::}{-}g;

	print BRIGHT_BLACK "\n";
	say '# ToDo you should consider the following';
	say "homepage    https://github.com/.../$package_name";
	say "bugtracker  https://github.com/.../$package_name/issues";
	say "repository  git://github.com/.../$package_name.git";

	print CLEAR "\n";
	if ( defined -d File::Spec->catdir( $App::Midgen::Working_Dir, 'share' ) ) {
		say 'install_share';
		print "\n";
	}

	if ( defined -d File::Spec->catdir( $App::Midgen::Working_Dir, 'script' ) ) {
		say 'install_script ...';
		print "\n";
	} elsif ( defined -d File::Spec->catdir( $App::Midgen::Working_Dir, 'bin' ) ) {
		say 'install_script bin/...';
		print "\n";
	}

	my @no_index = $self->no_index;
	if (@no_index) {
		say "no_index directory qw{ @no_index }";
		print "\n";
	}

	#	print "\n";

	return;
}


#######
# header_mi
#######
sub header_mi {
	my $self         = shift;
	my $package_name = shift // NONE;
	my $mi_ver       = shift // NONE;

	print "\n";
	say 'use inc::Module::Install ' . colored( $mi_ver, 'yellow' ) . q{;};
	print "\n";
	if ( $package_name ne NONE ) {
		$package_name =~ s{::}{-}g;
		say "name '$package_name';";
		$package_name =~ tr{-}{/};
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
	my $required_ref = shift || return;

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}

	say "perl_version '$App::Midgen::Min_Version';" if $title eq 'requires';
	print "\n";

	foreach my $module_name ( sort keys %{$required_ref} ) {

		if ( $module_name =~ /^Win32/sxm ) {
			my $sq_key = "'$module_name'";
			printf "%s %-*s => '%s' %s;\n", $title, $pm_length + 2, $sq_key,
				$required_ref->{$module_name}, colored( 'if win32', 'bright_green' );
		} else {
			my $sq_key = "'$module_name'";
			printf "%s %-*s => '%s';\n", $title, $pm_length + 2, $sq_key, $required_ref->{$module_name};
		}

	}

	return;
}
#######
# footer_mi
#######
sub footer_mi {
	my $self = shift;
	my $package_name = shift // NONE;
	$package_name =~ s{::}{-}g;

	print BRIGHT_BLACK "\n";
	say '# ToDo you should consider the following';
	say "homepage    'https://github.com/.../$package_name';";
	say "bugtracker  'https://github.com/.../$package_name/issues';";
	say "repository  'git://github.com/.../$package_name.git';";
	print "\n";
	say 'Meta->add_metadata(';
	say "\tx_contributors => [";
	say "\t\t'brian d foy (ADOPTME) <brian.d.foy\@gmail.com>',";
	say "\t\t'Fred Bloggs <fred\@bloggs.org>',";
	say "\t],";
	say ");\n";
	print CLEAR;

	if ( defined -d File::Spec->catdir( $App::Midgen::Working_Dir, 'share' ) ) {
		say 'install_share;';
		print "\n";
	}

	if ( defined -d File::Spec->catdir( $App::Midgen::Working_Dir, 'script' ) ) {
		say 'install_script \'script/...\';';
		print "\n";
	} elsif ( defined -d File::Spec->catdir( $App::Midgen::Working_Dir, 'bin' ) ) {
		say 'install_script \'bin/...\';';
		print "\n";
	}

	my @no_index = $self->no_index;
	if (@no_index) {
		say "no_index 'directory' => qw{ @no_index };";
		print "\n";
	}

	say 'WriteAll';
	print "\n";

	return;
}


#######
# header_mb
#######
sub header_mb {
	my $self = shift;
	my $package_name = shift // NONE;

	if ( $package_name ne NONE ) {
		print "\n";
		$package_name =~ s{::}{-}g;
		say '"dist_name" => "' . $package_name . q{",};
		print "\n";
	}

	return;
}
#######
# body_mb
#######
sub body_mb {
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift || return;
	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}
	say q{"} . $title . '" => {';

	foreach my $module_name ( sort keys %{$required_ref} ) {

		my $sq_key = "\"$module_name\"";
		printf "\t %-*s => \"%s\",\n", $pm_length + 2, $sq_key, $required_ref->{$module_name};

	}
	say '},';

	return;
}
#######
# footer_mb
#######
sub footer_mb {
	my $self = shift;

	if ( defined -d File::Spec->catdir( $App::Midgen::Working_Dir, 'script' ) ) {
		print "\n";
		say '"script_files" => [';
		print "\t\"script/...\"\n";
		say '],';
	} elsif ( defined -d File::Spec->catdir( $App::Midgen::Working_Dir, 'bin' ) ) {
		print "\n";
		say '"script_files" => [';
		print "\t\"bin/...\"\n";
		say '],';
	}

	print "\n";

	return;
}


#######
# header_dzil
#######
sub header_dzil {
	my $self = shift;
	my $package_name = shift // NONE;

	if ( $package_name ne NONE ) {
		print "\n";
		say "'NAME' => '$package_name'";
		$package_name =~ s{::}{/}g;
		say "'VERSION_FROM' => 'lib/$package_name.pm'";
		print "\n";
	}

	return;
}
#######
# body_dzil
#######
sub body_dzil {
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift || return;
	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}

	given ($title) {
		when ('requires')      { say '\'PREREQ_PM\' => {'; }
		when ('test_requires') { say '\'BUILD_REQUIRES\' => {'; }
		when ('recommends')    { return; }
	}

	foreach my $module_name ( sort keys %{$required_ref} ) {

		my $sq_key = q{"} . $module_name . q{"};
		printf "\t %-*s => '%s',\n", $pm_length + 2, $sq_key, $required_ref->{$module_name};

	}
	say '},';

	return;
}
#######
# footer_dzil
#######
sub footer_dzil {
	my $self = shift;
	my $package_name = shift // NONE;
	$package_name =~ s{::}{-}g;

	print BRIGHT_BLACK "\n";
	say '# ToDo you should consider the following';
	say '\'META_MERGE\' => {';
	say "\t'resources' => {";
	say "\t\t'homepage' => 'https://github.com/.../$package_name',";
	say "\t\t'repository' => 'git://github.com/.../$package_name.git',";
	say "\t\t'bugtracker' => 'https://github.com/.../$package_name/issues',";
	say "\t},";
	say "\t'x_contributors' => [";
	say "\t\t'brian d foy (ADOPTME) <brian.d.foy\@gmail.com>',";
	say "\t\t'Fred Bloggs <fred\@bloggs.org>',";
	say "\t],";
	say '},';
	print CLEAR "\n";

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
	my $required_ref = shift || return;;
	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}
	given ($title) {
		when ('requires') {
			say '[Prereqs]';
			printf "%-*s = %s\n", $pm_length, 'perl', $App::Midgen::Min_Version;
		}
		when ('test_requires') { say '[Prereqs / TestRequires]'; }
		when ('recommends')    { say '[Prereqs / RuntimeRecommends]'; }
	}

	foreach my $module_name ( sort keys %{$required_ref} ) {

		# my $sq_key = '"' . $module_name . '"';
		printf "%-*s = %s\n", $pm_length, $module_name, $required_ref->{$module_name};

	}

	return;
}
#######
# footer_dist
#######
sub footer_dist {
	my $self = shift;
	my $package_name = shift // NONE;
	$package_name =~ s{::}{-}g;

	print "\n";
	my @no_index = $self->no_index;
	if (@no_index) {
		say '[MetaNoIndex]';
		foreach (@no_index) {
			say "directory = $_" if $_ ne 'inc';
		}
		print "\n";
	}

	if ( defined -d File::Spec->catdir( $App::Midgen::Working_Dir, 'share' ) ) {
		say '[ShareDir]';
		say 'dir = share';
		print "\n";
	}

	if ( defined -d File::Spec->catdir( $App::Midgen::Working_Dir, 'script' ) ) {
		say '[ExecDir]';
		say 'dir = script';
		print "\n";
	} elsif ( defined -d File::Spec->catdir( $App::Midgen::Working_Dir, 'bin' ) ) {
		say '[ExecDir]';
		say 'dir = bin';
		print "\n";
	}

	say BRIGHT_BLACK '# ToDo you should consider the following';
	say '[MetaResources]';
	say "homepage          = https://github.com/.../$package_name";
	say "bugtracker.web    = https://github.com/.../$package_name/issues";
	say 'bugtracker.mailto = ...';
	say "repository.url    = git://github.com/.../$package_name.git";
	say 'repository.type   = git';
	say "repository.web    = https://github.com/.../$package_name";
	print "\n";

	say '[Meta::Contributors]';
	say 'contributor = brian d foy (ADOPTME) <brian.d.foy@gmail.com>';
	say 'contributor = Fred Bloggs <fred@bloggs.org>';
	print CLEAR "\n";

	return;
}


#######
# header_cpanfile
#######
sub header_cpanfile {
	my $self         = shift;
	my $package_name = shift // NONE;
	my $mi_ver       = shift // NONE;

	#	$package_name =~ s{::}{-}g;
	print BRIGHT_BLACK "\n";
	say '# Makefile.PL';
	say 'use inc::Module::Install ' . $mi_ver . q{;};

	$package_name =~ s{::}{-}g;
	say "name '$package_name';";
	say 'license \'perl\';';

	$package_name =~ tr{-}{/};
	say "version_from 'lib/$package_name.pm';";

	print "\n";
	say 'cpanfile;';
	say 'WriteAll;';
	print CLEAR "\n";

	return;
}
#######
# body_cpanfile
#######
sub body_cpanfile {
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift;

	if ( $title eq 'requires' ) {
		print "\n";

		#		print BRIGHT_BLACK "\n";
		#		say '# cpanfile';
		#		print CLEAR;
		say "requires 'perl', '$App::Midgen::Min_Version';";
		print "\n";
	}
#	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}
	given ($title) {
		when ('requires') {
			foreach my $module_name ( sort keys %{$required_ref} ) {

				my $mod_name = "'$module_name',";
				printf "%s %-*s '%s';\n", $title, $pm_length + THREE, $mod_name, $required_ref->{$module_name};
			}
		}
		when ('test_requires') {
			print "\n";
			say 'on test => sub {';
			foreach my $module_name ( sort keys %{$required_ref} ) {
				my $mod_name = "'$module_name',";
				printf "\t%s %-*s '%s';\n", 'requires', $pm_length + THREE, $mod_name, $required_ref->{$module_name};
			}
			print "\n" if %{$required_ref};
		}
		when ('recommends') {
			foreach my $module_name ( sort keys %{$required_ref} ) {
				my $mod_name = "'$module_name',";
				printf "\t%s %-*s '%s';\n", 'suggests', $pm_length + THREE, $mod_name, $required_ref->{$module_name};
			}
			say '};';
		}
		when ('test_develop') {
			print "\n";
			say 'on develop => sub {';
			foreach my $module_name ( sort keys %{$required_ref} ) {
				my $mod_name = "'$module_name',";
				printf "\t%s %-*s '%s';\n", 'recommends', $pm_length + THREE, $mod_name, $required_ref->{$module_name};
			}
			say '};';
		}
	}


	return;
}
#######
# footer_cpanfile
#######
sub footer_cpanfile {
	my $self = shift;
	my $package_name = shift // NONE;
	$package_name =~ s{::}{-}g;

	print "\n";

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

	foreach my $dir (@dirs_to_check) {

		#ignore syntax warning for global
		push @dirs_found, $dir
			if -d File::Spec->catdir( $App::Midgen::Working_Dir, $dir );
	}
	return @dirs_found;
}

no Moo;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Output - A collection of output orientated methods used by L<App::Midgen>

=head1 VERSION

This document describes App::Midgen::Output version: 0.23

=head1 DESCRIPTION

The output format uses colour to add visualization of module version number
 types, be that mcpan, dual-life or added distribution.

=head1 METHODS

=over 4

=item * header_dsl

=item * body_dsl

=item * footer_dsl

=item * header_mi

=item * body_mi

=item * footer_mi

=item * header_cpanfile

=item * body_cpanfile

=item * footer_cpanfile

=item * header_mb

=item * body_mb

=item * footer_mb

=item * header_dzil

=item * body_dzil

=item * footer_dzil

=item * header_dist

=item * body_dist

=item * footer_dist

=item * no_index

Suggest some of your local directories you can 'no_index'

=back

=head1 DEPENDENCIES

L<Term::ANSIColor>

=head1 SEE ALSO

L<App::Midgen>

=head1 AUTHOR

See L<App::Midgen>

=head2 CONTRIBUTORS

See L<App::Midgen>

=head1 COPYRIGHT

See L<App::Midgen>

=head1 LICENSE

See L<App::Midgen>

=cut
