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

  use_ok('Carp',                   '1.26');
  use_ok('Cwd',                    '3.4');
  use_ok('Data::Printer',          '0.35');
  use_ok('File::Spec',             '3.4');
  use_ok('Getopt::Long',           '2.39');
  use_ok('MetaCPAN::API',          '0.43');
  use_ok('Module::CoreList',       '2.84');
  use_ok('Moo',                    '1.001');
  use_ok('MooX::Types::MooseLike', '0.23');
  use_ok('PPI',                    '1.215');
  use_ok('Perl::MinimumVersion',   '1.32');
  use_ok('Perl::PrereqScanner',    '1.015');
  use_ok('Pod::Usage',             '1.61');
  use_ok('Scalar::Util',           '1.27');
  use_ok('Time::Stamp',            '1.3');
  use_ok('Try::Tiny',              '0.12');
  use_ok('constant',               '1.25');
  use_ok('version',                '0.9902');

  use_ok('Test::More', '0.98');
}

diag("Testing App::Midgen v$App::Midgen::VERSION");

done_testing();

__END__
