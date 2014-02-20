package App::Midgen::Role::FindMinVersion;

use v5.10;
use Types::Standard qw( Bool );
use Moo::Role;
requires qw( ppi_document debug );

our $VERSION = '0.29_07';
#use English qw( -no_match_vars );
use Data::Printer {caller_info => 1, colored => 1,};
use Perl::MinimumVersion;
use Try::Tiny;

use version;

#######
# find min perl version
######
sub min_version {
	my $self         = shift;

	my $dist_min_ver = $App::Midgen::Min_Version;
	my $object;

	try {
		$object = Perl::MinimumVersion->new($self->ppi_document);
#		p $object->minimum_syntax_reason;
	};

	# Find the minimum version
	try {
		my $minimum_version = $object->minimum_version;
		$dist_min_ver
			= version->parse($dist_min_ver) > version->parse($minimum_version)
			? version->parse($dist_min_ver)->numify
			: version->parse($minimum_version)->numify;

#		p $minimum_version if $self->debug;
	};

	try {
		my $minimum_explicit_version = $object->minimum_explicit_version;
		$dist_min_ver
			= version->parse($dist_min_ver)
			> version->parse($minimum_explicit_version)
			? version->parse($dist_min_ver)->numify
			: version->parse($minimum_explicit_version)->numify;

#		p $minimum_explicit_version if $self->debug;
	};

	try {
		my $minimum_syntax_version = $object->minimum_syntax_version;
		$dist_min_ver
			= version->parse($dist_min_ver)
			> version->parse($minimum_syntax_version)
			? version->parse($dist_min_ver)->numify
			: version->parse($minimum_syntax_version)->numify;

#		p $minimum_syntax_version if $self->debug;
	};

	warn 'min_version - ' . $dist_min_ver if $self->debug;
	$App::Midgen::Min_Version = $dist_min_ver;
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

version: 0.29_07

=head1 METHODS

=over 4

=item * min_version

Used to find the minimum version of your package by taking a quick look,
in a module or script and updating C<$App::Midgen::Min_Version> accordingly.

=back

=head2 ACCESSORS

=over 4

=item * min_ver_fast

Used as a flag to indicate which of the following is install

  TRUE ->  L<Perl::MinimumVersion::Fast>
  FALSE -> L<Perl::MinimumVersion>

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

