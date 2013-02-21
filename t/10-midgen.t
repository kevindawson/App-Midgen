#!/usr/bin/env perl

use v5.10;
use strict;
use warnings FATAL => 'all';
use English qw( -no_match_vars ); # Avoids regex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Test::More tests => 35;

######
# let's check our subs/methods.
######

my @subs = qw(
	base_parent find_makefile_requires find_makefile_test_requires
	find_package_names find_required_modules find_required_test_modules
	first_package_name initialise output_footer output_header
	output_main_body process_found_modules remove_noisy_children
	remove_twins run store_modules
	recommends_in_double_quote recommends_in_single_quote 
);

use_ok( 'App::Midgen', @subs );

foreach my $subs (@subs) {
	can_ok( 'App::Midgen', $subs );
}

my @attributes = qw(
	base_parent core verbose mojo noisy_children twins debug
);
my $midgen1 = App::Midgen->new();

foreach my $attribute (@attributes) {
	is( $midgen1->{$attribute}, 0, "default found $attribute" );
}
is( $midgen1->{output_format}, 'dsl', "default found output_format" );

my $midgen2 = App::Midgen->new(
	base_parent    => 1,
	core           => 1,
	verbose        => 1,
	output_format  => 'mi',
	mojo           => 1,
	noisy_children => 1,
	twins          => 1,
	debug          => 1,
); App::Midgen->new();

foreach my $attribute (@attributes) {
	is( $midgen2->{$attribute}, 1, "defined found $attribute" );
}
is( $midgen2->{output_format}, 'mi', "defined found output_format" );


done_testing();

__END__
