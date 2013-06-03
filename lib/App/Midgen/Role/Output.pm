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
);

# turn off experimental warnings
no if $] > 5.017010, warnings => 'experimental::smartmatch';

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.23_01';
use English qw( -no_match_vars ); # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

#######
# _output_header
#######
sub _output_header {
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
	}
	return;
}

#######
# output_main_body
#######
sub _output_main_body {
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
	}

	return;
}

#######
# output_footer
#######
sub _output_footer {
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

