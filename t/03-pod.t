#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use English qw( -no_match_vars ); # Avoids regex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Test::More;

eval 'use Test::Pod 1.45';
plan skip_all => "Test::Pod 1.45 required for testing POD" if $@;
all_pod_files_ok();

done_testing();

__END__
