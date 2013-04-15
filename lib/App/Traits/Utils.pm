package App::Midgen::Traits::Utils;

use v5.10;
use Moo::Role;
use Types::Standard qw( ArrayRef Bool Object Str );

#use Type::Tiny;
#use MooX::Types::MooseLike::Base qw(:all);

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.21_03';
use Carp;

has 'parent' => (
	is       => 'ro',
	isa      => Bool,
	required => 1,
	default  => sub {0},
);


#######
# composed method degree of separation
# parent A::B - child A::B::C
#######
sub degree_separation {
  my $self   = shift;
  my $parent = shift;
  my $child  = shift;

  # Use of implicit split to @_ is deprecated
  my $parent_score = @{[split /::/, $parent]};
  my $child_score  = @{[split /::/, $child]};
  say 'parent - ' . $parent . ' score - ' . $parent_score if $self->debug;
  say 'child - ' . $child . ' score - ' . $child_score    if $self->debug;

  # switch around for a positive number
  return $child_score - $parent_score;
}



no Moo::Role;

1;

