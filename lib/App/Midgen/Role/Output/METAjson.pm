package App::Midgen::Role::Output::METAjson;

use v5.10;
use Moo::Role;
requires qw( no_index verbose );

# turn off experimental warnings
no if $] > 5.017010, warnings => 'experimental::smartmatch';

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.27_09';
use English qw( -no_match_vars ); # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Term::ANSIColor qw( :constants colored );
use Data::Printer { caller_info => 1, colored => 1, };
use constant {
	BLANK  => q{ },
	NONE   => q{},
	THREE  => q{   },
	SIX    => q{      },
	NINE   => q{         },
	TWELVE => q{            },
};
use File::Spec;

#######
# header_metajson
#######
sub header_metajson {
	my $self = shift;
	my $package_name = shift // NONE;
	$package_name =~ s{::}{-}g;

	say '{';
	if ( $self->verbose > 0 ) {
		say BRIGHT_BLACK THREE . '"abstract" : "This is a short description of the purpose of the distribution.",';
		say THREE . '"author" : "...",';
		say THREE . '"dynamic_config" : "0|1",';
		say THREE . '"generated_by" : "...",';
		say THREE . '"license" : [';
		say SIX . '"perl_5"';
		say THREE . '],';
		say THREE . '"meta-spec" : {';
		say SIX . '"url" : "http://search.cpan.org/perldoc?CPAN::Meta::Spec",';
		say SIX . '"version" : "2"';
		say THREE . '},';
	}
	say CLEAR THREE . '"name" : "' . $package_name . q{",};

	if ( $self->verbose > 0 ) {
		say BRIGHT_BLACK THREE . '"release_status" : "stable|testing|unstable",';
		say THREE . '"version" : "...",';
	}

	return;
}

#######
# body_metajson
#######
sub body_metajson {
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift;

	given ($title) {

		when ('requires') {
			say CLEAR THREE . '"prereqs" : {';
			say SIX . '"runtime" : {';
			say NINE . '"requires" : {';

			$required_ref->{'perl'} = $App::Midgen::Min_Version;

			foreach my $module_name ( sort keys %{$required_ref} ) {
				say TWELVE . "\"$module_name\" : \"$required_ref->{$module_name}\","
					if $required_ref->{$module_name} !~ m/mcpan/;
			}
			print NINE . '}';

			if ( $self->verbose > 0 ) {
				say BRIGHT_BLACK ",\n" . NINE . '"suggests" : {...},';
				print NINE . '"recommends" : {...},';
			}
			say CLEAR "\n" . SIX . '},';
		}
		when ('test_requires') {
			say SIX . '"test" : {';
			say NINE . '"requires" : {';
			foreach my $module_name ( sort keys %{$required_ref} ) {
				say TWELVE . "\"$module_name\" : \"" . $required_ref->{$module_name} . '",'
					if $required_ref->{$module_name} !~ m/mcpan/;
			}
			print NINE . '}';
		}
		when ('recommends') {
			if ($required_ref) {
				say ',';
				say NINE . '"suggests" : {';
				foreach my $module_name ( sort keys %{$required_ref} ) {
					say TWELVE . "\"$module_name\" : \"" . $required_ref->{$module_name} . '",'
						if $required_ref->{$module_name} !~ m/mcpan/;

				}
				say NINE . '}';

				print SIX . '}';

			} else {
				print "\n";
				print SIX . '}';

			}
		}
		when ('test_develop') {
			if ($required_ref) {

				say ',';
				say SIX . '"develop" : {';
				say NINE . '"requires" : {';
				foreach my $module_name ( sort keys %{$required_ref} ) {
					say TWELVE . "\"$module_name\" : \"" . $required_ref->{$module_name} . '",'
						if $required_ref->{$module_name} !~ m/mcpan/;

				}
				say NINE . '}';
				print SIX . '}';
			}
		}
	}

	return;
}

#######
# footer_metajson
#######
sub footer_metajson {
	my $self = shift;
	my $package_name = shift // NONE;
	$package_name =~ s{::}{-}g;

	print "\n";

	#  if ($self->verbose > 0) {
	#    say SIX . '},';
	#    say BRIGHT_BLACK SIX . '"build" : {';
	#    say NINE . '"requires" : {...}';
	#    say SIX . '}';
	#  }
	#  else {
	#    say SIX . '}';
	#  }

	say THREE . '}';
	my @no_index = $self->no_index;
	if (@no_index) {
		say THREE . '"no_index" : {';
		say SIX . '"directory" : [';
		foreach my $no_idx (@no_index) {
			say NINE . q{"} . $no_idx . q{",};
		}
		say SIX . ']';
	}

	if ( $self->verbose > 0 ) {
		say THREE . '},';
		say BRIGHT_BLACK THREE . '"resources" : {';
		say SIX . '"bugtracker" : {';
		say NINE . '"web" : "https://github.com/.../' . $package_name . '/issues"';
		say SIX . '},';
		say SIX . '"homepage" : "https://github.com/.../' . $package_name . q{",};
		say SIX . '"repository" : {';
		say NINE . '"type" : "git",';
		say NINE . '"url" : "https://github.com/.../' . $package_name . q{.git",};
		say NINE . '"web" : "https://github.com/.../' . $package_name . q{"};
		say SIX . '}';
		say THREE . '},';
		say THREE . '"x_contributors" : [';
		say SIX . '"brian d foy (ADOPTME) <brian.d.foy@gmail.com>",';
		say SIX . '"Fred Bloggs <fred@bloggs.org>"';
		say THREE . q{]};
	} else {
		say THREE . '}';
	}

	say CLEAR . '}';
	print qq{\n};
	return;
}


no Moo;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Role::Output::METAjson - Output Format - META.json,
used by L<App::Midgen>

=head1 VERSION

version: 0.27_09

=head1 DESCRIPTION

The output format uses colour to add visualization of module version number
types, be that mcpan, dual-life or added distribution.

=head1 METHODS

=over 4

=item * header_metajson

=item * body_metajson

=item * footer_metajson

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

255:	To save a full .LOG file rerun with -g
