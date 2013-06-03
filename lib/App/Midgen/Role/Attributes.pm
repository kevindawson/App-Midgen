package App::Midgen::Role::Attributes;

use v5.10;
use Types::Standard qw( ArrayRef Bool Int Object Str);
use Moo::Role;
# use MooX::Types::MooseLike::Base qw(:all);
use Data::Printer { caller_info => 1, colored => 1, };

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.23';
use Carp;

#######
# some encapsulated -> attributes
#######

has 'develop' => (
	is      => 'ro',
	isa     => Bool,
	lazy    => 1,
	builder => '_develop',
);

sub _develop {
	my $self = shift;

	if ( $self->experimental && $self->format eq 'cpanfile' ) {
		return 1;
	} else {
		return 0;
	}
}

has 'distribution_name' => (
	is   => 'rw',
	isa  => Str,
	lazy => 1,
);

has 'found_twins' => (
	is      => 'rw',
	isa     => Bool,
	lazy    => 1,
	default => sub {
		0;
	},
);

has 'numify' => (
	is      => 'rw',
	isa     => Bool,
	default => sub {0},
	lazy    => 1,
);

has 'package_names' => (
	is      => 'rw',
	isa     => ArrayRef,
	default => sub { [] },
	lazy    => 1,
);

has 'ppi_document' => (
	is   => 'rw',
	isa  => Object,
	lazy => 1,
);

has 'xtest' => (
	is      => 'rw',
	isa     => Str,
	lazy    => 1,
	default => sub {
		'test_requires';
	},
);

no Moo::Role;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Role::Attributes - Package Attributes used by L<App::Midgen>

=head1 VERSION

version: 0.23

=head1 METHODS

none as such, but we do have

=head2 ATTRIBUTES

=over 4

=item * develop

=item * distribution_name

=item * found_twins

=item * numify

=item * package_names

=item * ppi_document

=item * xtest

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
