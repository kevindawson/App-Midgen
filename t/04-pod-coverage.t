#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use English qw( -no_match_vars ); # Avoids regex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Test::More;

eval 'use Test::Pod::Coverage 1.08';
plan skip_all => "Test::Pod::Coverage 1.08 required for testing POD coverage" if $@;
all_pod_coverage_ok();

done_testing();

__END__
