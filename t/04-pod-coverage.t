#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use English qw( -no_match_vars );
local $OUTPUT_AUTOFLUSH = 1;

use Test::More;

my $mod_ver = 1.08;
eval "use Test::Pod::Coverage $mod_ver";
plan skip_all => "Test::Pod::Coverage $mod_ver required for testing POD coverage" if $@;
all_pod_coverage_ok();

done_testing();

__END__
