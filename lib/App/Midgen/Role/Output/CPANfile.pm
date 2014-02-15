package App::Midgen::Role::Output::CPANfile;

use v5.10;
use Moo::Role;
requires qw( verbose );

# turn off experimental warnings
no if $] > 5.017010, warnings => 'experimental::smartmatch';

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.29_03';
use English qw( -no_match_vars );    # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Term::ANSIColor qw( :constants colored );
use Data::Printer {caller_info => 1, colored => 1,};
use constant {BLANK => q{ }, NONE => q{}, THREE => 3,};
use File::Spec;

#######
# header_cpanfile
#######
sub header_cpanfile {
	my $self         = shift;
	my $package_name = shift // NONE;
	my $mi_ver       = shift // NONE;

#	if ( $self->verbose > 0 ) {
#		print BRIGHT_BLACK "\n";
#		say '# Makefile.PL';
#		say 'use inc::Module::Install ' . $mi_ver . q{;};
#
#		$package_name =~ s{::}{-}g;
#		say "name '$package_name';";
#		say 'license \'perl\';';
#
#		$package_name =~ tr{-}{/};
#		say "version_from 'lib/$package_name.pm';";
#
#		print "\n";
#		say 'cpanfile;';
#		say 'WriteAll;';
#		print CLEAR "\n";
#	}

	return;
}

#######
# body_cpanfile
#######
sub body_cpanfile {
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift;

	my $pm_length = 0;
	foreach my $module_name (sort keys %{$required_ref}) {
		if (length $module_name > $pm_length) {
			$pm_length = length $module_name;
		}
	}
	given ($title) {
		when ('requires') {
			print "\n";

			$required_ref->{'perl'} = $App::Midgen::Min_Version;
			foreach my $module_name (sort keys %{$required_ref}) {

				my $mod_name = "'$module_name',";
				printf "%s %-*s '%s';\n", $title, $pm_length + THREE, $mod_name,
					$required_ref->{$module_name}
					if $required_ref->{$module_name} !~ m/mcpan/;
			}
		}
		when ('runtime_recommends') {
			print "\n";
			foreach my $module_name (sort keys %{$required_ref}) {

				my $mod_name = "'$module_name',";
				printf "%s %-*s '%s';\n", 'recommends', $pm_length + THREE,
					$mod_name, $required_ref->{$module_name}
					if $required_ref->{$module_name} !~ m/mcpan/;
			}
		}
		when ('test_requires') {
			print "\n";
			say 'on test => sub {';
			foreach my $module_name (sort keys %{$required_ref}) {
				my $mod_name = "'$module_name',";
				printf "\t%s %-*s '%s';\n", 'requires', $pm_length + THREE,
					$mod_name, $required_ref->{$module_name} if $required_ref->{$module_name} !~ m/mcpan/;

			}
			print "\n" if %{$required_ref};
		}
		when ('recommends') {
			foreach my $module_name (sort keys %{$required_ref}) {
				my $mod_name = "'$module_name',";
				printf "\t%s %-*s '%s';\n", 'suggests', $pm_length + THREE,
					$mod_name, $required_ref->{$module_name} if $required_ref->{$module_name} !~ m/mcpan/;

			}
			say '};';
		}
		when ('test_develop') {
			print "\n";
			say 'on develop => sub {';
			foreach my $module_name (sort keys %{$required_ref}) {
				my $mod_name = "'$module_name',";
				printf "\t%s %-*s '%s';\n", 'recommends', $pm_length + THREE,
					$mod_name, $required_ref->{$module_name} if $required_ref->{$module_name} !~ m/mcpan/;

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


no Moo;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Midgen::Role::Output::CPANfile - Output Format - cpanfile,
used by L<App::Midgen>

=head1 VERSION

version: 0.29_03

=head1 DESCRIPTION

The output format uses colour to add visualization of module version number
types, be that mcpan, dual-life or added distribution.

=head1 METHODS

=over 4

=item * header_cpanfile

=item * body_cpanfile

=item * footer_cpanfile

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

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

