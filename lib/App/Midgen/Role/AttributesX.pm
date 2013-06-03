package App::Midgen::Role::Attributes;

use v5.10;
use Moo::Role;
use MooX::Types::MooseLike::Base qw( InstanceOf );
use Data::Printer { caller_info => 1, colored => 1, };

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.23';
use Carp;

#######
# some encapsulated -> attributes
#######

has 'mcpan' => (
	is      => 'rw',
	isa     => InstanceOf [ 'MetaCPAN::API', ],
	lazy    => 1,
	builder => '_build_mcpan',
	handles => [qw( module release )],
);

sub _build_mcpan {
	my $self = shift;
	return MetaCPAN::API->new();
}

has 'output' => (
	is      => 'rw',
	isa     => InstanceOf [ 'App::Midgen::Output', ],
	lazy    => 1,
	builder => '_build_output',
);

sub _build_output {
	my $self = shift;
	return App::Midgen::Output->new();
}

has 'scanner' => (
	is      => 'rw',
	isa     => InstanceOf [ 'Perl::PrereqScanner', ],
	lazy    => 1,
	builder => '_build_scanner',
	handles => [qw( scan_ppi_document )],
);

sub _build_scanner {
	my $self = shift;
	return Perl::PrereqScanner->new();
}

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

=head2 ACCESSORS

=over 4

=item * mcpan

accessor to MetaCPAN::API object

=item * output

accessor to App::Midgen::Output object

=item * scanner

accessor to Perl::PrereqScanner object

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
