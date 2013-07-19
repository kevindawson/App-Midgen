package App::Midgen::Role::Output;

use v5.10;
use Moo::Role;
with qw(
	App::Midgen::Role::Output::MIdsl
	App::Midgen::Role::Output::MI
	App::Midgen::Role::Output::MB
	App::Midgen::Role::Output::Dzil
	App::Midgen::Role::Output::Dist
	App::Midgen::Role::Output::CPANfile
	App::Midgen::Role::Output::METAjson
	App::Midgen::Role::Output::Infile
);
requires qw( format distribution_name get_module_version verbose );

# turn off experimental warnings
no if $] > 5.017010, warnings => 'experimental::smartmatch';

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.25_09';
use English qw( -no_match_vars ); # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

#######
# output_header
#######
sub output_header {
	my $self = shift;

	given ( $self->format ) {

		when ('dsl') {
			$self->header_dsl(
				$self->distribution_name,
				$self->get_module_version('inc::Module::Install::DSL')
			);
		}
		when ('mi') {
			$self->header_mi(
				$self->distribution_name,
				$self->get_module_version('inc::Module::Install')
			);
		}
		when ('dist') {
			$self->header_dist( $self->distribution_name );
		}
		when ('cpanfile') {
			$self->header_cpanfile(
				$self->distribution_name,
				$self->get_module_version('inc::Module::Install')
			) if not $self->quiet;

		}
		when ('dzil') {
			$self->header_dzil( $self->distribution_name );
		}
		when ('mb') {
			$self->header_mb( $self->distribution_name );
		}
		when ('metajson') {
			$self->header_metajson( $self->distribution_name );
		}
		when ('infile') {
			$self->header_infile( $self->distribution_name );
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
	my $required_ref = shift;

	given ( $self->format ) {

		when ('dsl') {
			$self->body_dsl( $title, $required_ref );
		}
		when ('mi') {
			$self->body_mi( $title, $required_ref );
		}
		when ('dist') {
			$self->body_dist( $title, $required_ref );
		}
		when ('cpanfile') {
			$self->body_cpanfile( $title, $required_ref );
		}
		when ('dzil') {
			$self->body_dzil( $title, $required_ref );
		}
		when ('mb') {
			$self->body_mb( $title, $required_ref );
		}
		when ('metajson') {
			$self->body_metajson( $title, $required_ref );
		}
		when ('infile') {
			$self->body_infile( $title, $required_ref );
		}
	}

	return;
}

#######
# output_footer
#######
sub output_footer {
	my $self = shift;

	given ( $self->format ) {

		when ('dsl') {
			$self->footer_dsl( $self->distribution_name );
		}
		when ('mi') {
			$self->footer_mi( $self->distribution_name );
		}
		when ('dist') {
			$self->footer_dist( $self->distribution_name );
		}
		when ('cpanfile') {
			$self->footer_cpanfile( $self->distribution_name );
		}
		when ('dzil') {
			$self->footer_dzil( $self->distribution_name );
		}
		when ('mb') {
			$self->footer_mb( $self->distribution_name );
		}
		when ('metajson') {
			$self->footer_metajson( $self->distribution_name );
		}
		when ('infile') {
			$self->footer_infile( $self->distribution_name );
		}
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

App::Midgen::Role::Output - A collection of output orientated methods used by L<App::Midgen>

=head1 VERSION

version: 0.25_09

=head1 DESCRIPTION

The output format uses colour to add visualization of module version number
types, be that mcpan, dual-life or added distribution.

=head1 METHODS

=over 4

=item * output_header 

=item * output_main_body 

=item * output_footer 

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

