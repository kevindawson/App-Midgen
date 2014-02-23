package App::Midgen::Role::Output::MB;

use v5.10;
use Moo::Role;

# turn off experimental warnings
no if $] > 5.017010, warnings => 'experimental::smartmatch';

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.29_09';
$VERSION = eval $VERSION; ## no critic

use English qw( -no_match_vars ); # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Term::ANSIColor qw( :constants colored );
use Data::Printer { caller_info => 1, colored => 1, };
use constant { BLANK => q{ }, NONE => q{}, THREE => 3, };
use File::Spec;

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

no Moo;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Midgen::Role::Output::MB - Output Format - Module::Build,
used by L<App::Midgen>

=head1 VERSION

version: 0.29_09

=head1 DESCRIPTION

The output format uses colour to add visualization of module version number
types, be that mcpan, dual-life or added distribution.

=head1 METHODS

=over 4

=item * header_mb

=item * body_mb

=item * footer_mb

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

