package App::Midgen::Roles;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.05';
use English qw( -no_match_vars ); # Avoids regex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Moo::Role;
use MooX::Types::MooseLike::Base qw(:all);

#######
# options
#######
has 'base_parent' => (
	is  => 'ro',
	isa => Bool,
	required => 1,
);
has 'core' => (
	is  => 'ro',
	isa => Bool,
	required => 1,
);
has 'debug' => (
	is  => 'ro',
	isa => Bool,
	required => 1,
);
has 'mojo' => (
	is  => 'ro',
	isa => Bool,
	required => 1,
);
has 'noisy_children' => (
	is  => 'ro',
	isa => Bool,
	required => 1,
);
has 'output_format' => (
	is => 'ro',
	isa => Str,
	required => 1,
);
has 'verbose' => (
	is  => 'ro',
	isa => Bool,
	required => 1,
);

#######
# encapsulated attributes
#######
has 'package_names' => (
	is  => 'rw',
	isa => ArrayRef,
);


1;
