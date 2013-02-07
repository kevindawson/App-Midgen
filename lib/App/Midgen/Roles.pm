package App::Midgen::Roles;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.05';
use English qw( -no_match_vars ); # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Moo::Role;
use MooX::Types::MooseLike::Base qw(:all);
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
	default => sub { 0 },
	required => 1,
);
has 'core' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub { 0 },
	required => 1,
);
has 'debug' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub { 0 },
	required => 1,
);
has 'mojo' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub { 0 },
	required => 1,
);
has 'noisy_children' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub { 0 },
	required => 1,
);
has 'output_format' => (
	is  => 'ro',
	isa => sub {
		my $format = { dsl => 1, mi => 1, build => 1, };
		croak 'not a supported output format' unless defined $format->{ $_[0] };
		return;
	},
	default => sub { 'dsl' },
	required => 1,
);
has 'verbose' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub { 0 },
	required => 1,
);

#######
# some encapsulated attributes
#######

# Our best guess as to this packages name
has 'package_name' => (
	is  => 'rw',
	isa => Str,
);

# Some package names we found along the way
has 'package_names' => (
	is  => 'rw',
	isa => ArrayRef,
);

# Some where to store required modules and version info in
has 'requires' => (
	is  => 'rw',
	isa => HashRef,
);

# Some where to store test_required modules and version info in
has 'test_requires' => (
	is  => 'rw',
	isa => HashRef,
);

1;
