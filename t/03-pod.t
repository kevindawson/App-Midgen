#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use English qw( -no_match_vars );
local $OUTPUT_AUTOFLUSH = 1;

use Test::More;

my $mod_ver = 1.45;
eval "use Test::Pod $mod_ver";
plan skip_all => "Test::Pod $mod_ver required for testing POD" if $EVAL_ERROR;

all_pod_files_ok();

done_testing();

__END__
