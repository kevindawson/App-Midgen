package App::Midgen::Roles;

use v5.10;
use Moo::Role;
use MooX::Types::MooseLike::Base qw(:all);

our $VERSION = '0.10';
use English qw( -no_match_vars ); # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Carp;

#######
# cmd line options
#######

has 'base_parent' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

has 'core' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

has 'debug' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

has 'mojo' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

has 'noisy_children' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

has 'output_format' => (
	is  => 'ro',
	isa => sub {
		my $format = { dsl => 1, mi => 1, build => 1, dzil => 1, dist => 1 };
		croak 'not a supported output format' unless defined $format->{ $_[0] };
		return;
	},
	default => sub {
		'dsl';
	},
	required => 1,
);

has 'padre' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	lazy => 1,
	default => sub {
		0;
	},
	required => 1,
);

has 'verbose' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

has 'twins' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

#######
# some encapsulated attributes
#######

has 'package_name' => (
	is  => 'rw',
	isa => Str,
);

has 'package_names' => (
	is  => 'rw',
	isa => ArrayRef,
);

has 'requires' => (
	is  => 'rw',
	isa => HashRef,
);

has 'test_requires' => (
	is  => 'rw',
	isa => HashRef,
);

has 'recommends' => (
	is  => 'rw',
	isa => HashRef,
);

has 'found_twins' => (
	is      => 'rw',
	isa     => Bool,
	lazy => 1,
	default => sub {
		0;
	},
	required => 1,
);


1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Roles - Package Options and Attributes used by L<App::Midgen>

=head1 VERSION

This document describes App::Midgen::Roles version: 0.10

=head1 OPTIONS

=over 4

=item * base_parent

=item * core

=item * debug

=item * mojo

=item * noisy_children

=item * output_format

=item * padre

=item * twins

=item * verbose

=back

for more info see L<midgen>

=head1 ACCESSORS

=over 4

=item * found_twins

Used as a flag to re-run noisy children after descovery of twins

=item * package_name

Our best guess as to this packages name

=item * package_names

Some package names we found along the way

=item * requires

Some where to store required modules and version info in

=item * test_requires

Some where to store test_required modules and version info in

=item * recommends

Some where to store recommend modules and version info in

=back


=head1 AUTHOR

Kevin Dawson E<lt>bowtie@cpan.orgE<gt>

=head2 CONTRIBUTORS

none at present

=head1 COPYRIGHT

Copyright E<copy> 2013 AUTHOR and CONTRIBUTORS as listed above.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl 5 itself.

=head1 SEE ALSO

L<App::Midgen>,

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
