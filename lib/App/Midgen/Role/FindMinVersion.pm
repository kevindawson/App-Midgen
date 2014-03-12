package App::Midgen::Role::FindMinVersion;

use constant {TWO => 2,};

use Types::Standard qw( Bool );
use Moo::Role;
requires qw( ppi_document debug );

our $VERSION = '0.30';
$VERSION = eval $VERSION; ## no critic

use Perl::MinimumVersion;
use Try::Tiny;
use version;

#######
# find min perl version
######
sub min_version {
	my $self = shift;

	my $dist_min_ver = $App::Midgen::Min_Version;
	my $object;

	try {
		$object = Perl::MinimumVersion->new($self->ppi_document);
	};

	# Find the minimum version
	try {
		$dist_min_ver
			= version->parse($dist_min_ver)
			> version->parse($object->minimum_version)
			? version->parse($dist_min_ver)
			: version->parse($object->minimum_version);
	};

	try {
		$dist_min_ver
			= version->parse($dist_min_ver)
			> version->parse($object->minimum_explicit_version)
			? version->parse($dist_min_ver)
			: version->parse($object->minimum_explicit_version);
	};

	try {
		$dist_min_ver
			= version->parse($dist_min_ver)
			> version->parse($object->minimum_syntax_version)
			? version->parse($dist_min_ver)
			: version->parse($object->minimum_syntax_version);
	};

	print "min_version - $dist_min_ver\n" if ($self->verbose == TWO);

	$App::Midgen::Min_Version = version->parse($dist_min_ver)->numify;
	return;
}

no Moo::Role;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Midgen::Roles::FindMinVersion - used by L<App::Midgen>

=head1 VERSION

version: 0.30

=head1 METHODS

=over 4

=item * min_version

Used to find the minimum version of your package by taking a quick look,
in a module or script and updating C<$App::Midgen::Min_Version> accordingly.

=back

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

