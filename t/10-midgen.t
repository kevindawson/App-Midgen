#!/usr/bin/env perl

use v5.10;
use strict;
use warnings FATAL => 'all';
use English qw( -no_match_vars ); # Avoids regex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Test::More tests => 32;

######
# let's check our subs/methods.
######

my @subs = qw(
	find_required_modules find_required_test_modules
	first_package_name remove_noisy_children mcpan
	remove_twins found_twins run min_version output
	package_name package_names numify ppi_document
	scanner get_module_version mod_in_dist
);

use_ok( 'App::Midgen', @subs );

foreach my $subs (@subs) {
	can_ok( 'App::Midgen', $subs );
}

my @attributes = qw(
	core dual_life verbose experimental zero debug
);
my $midgen1 = App::Midgen->new();

foreach my $attribute (@attributes) {
	is( $midgen1->{$attribute}, 0, "default found $attribute" );
}
is( $midgen1->{format}, 'dsl', "default found format" );

my $midgen2 = App::Midgen->new(
	core         => 1,
	dual_life    => 1,
	verbose      => 1,
	format       => 'mi',
	experimental => 1,
	zero         => 1,
	debug        => 1,
);
App::Midgen->new();

foreach my $attribute (@attributes) {
	is( $midgen2->{$attribute}, 1, "defined found $attribute" );
}
is( $midgen2->{format}, 'mi', "defined found output format" );


done_testing();

__END__

