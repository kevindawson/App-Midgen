#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use English qw( -no_match_vars ); # Avoids regex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Test::More tests => 22;

BEGIN {
  use_ok('App::Midgen');
  use_ok('App::Midgen::Roles');
  use_ok('App::Midgen::Output');

  use_ok('Carp',                   '1.260');
  use_ok('Cwd',                    '3.400');
  use_ok('Data::Printer',          '0.350');
  use_ok('File::Spec',             '3.400');
  use_ok('Getopt::Long',           '2.390');
  use_ok('MetaCPAN::API',          '0.430');
  use_ok('Module::CoreList',       '2.840');
  use_ok('Moo',                    '1.001');
  use_ok('MooX::Types::MooseLike', '0.230');
  use_ok('PPI',                    '1.215');
  use_ok('Perl::MinimumVersion',   '1.320');
  use_ok('Perl::PrereqScanner',    '1.015');
  use_ok('Pod::Usage',             '1.610');
  use_ok('Scalar::Util',           '1.270');
  use_ok('Time::Stamp',            '1.300');
  use_ok('Try::Tiny',              '0.120');
  use_ok('constant',               '1.250');
  use_ok('version',                '0.990200');

  use_ok('Test::More', '0.98');
}

diag("Testing App::Midgen v$App::Midgen::VERSION");

done_testing();

__END__
