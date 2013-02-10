#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use English qw( -no_match_vars ); # Avoids regex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Test::More tests => 20;


use_ok('App::Midgen');
use_ok('App::Midgen::Roles');

use_ok( 'CPAN',                         '1.9800' );
use_ok( 'Carp',                         '1.26' );
use_ok( 'Cwd',                          '3.40' );
use_ok( 'Data::Printer',                '0.35' );
use_ok( 'File::Slurp',                  '9999.19' );
use_ok( 'File::Spec',                   '3.40' );
use_ok( 'Getopt::Long',                 '2.38' );
use_ok( 'Module::CoreList',             '2.80' );
use_ok( 'Moo',                          '1.000008' );
use_ok( 'MooX::Types::MooseLike::Base', '0.16' );
use_ok( 'PPI',                          '1.215' );
use_ok( 'Pod::Usage',                   '1.61' );
use_ok( 'Try::Tiny',                    '0.12' );
use_ok( 'autodie',                      '2.13' );
use_ok( 'constant',                     '1.25' );
use_ok( 'lib',                          '0.63' );

use_ok( 'Test::More', '0.98' );
use_ok( 'strictures', '1.004004' );

diag("Testing App::Midgen v$App::Midgen::VERSION");

done_testing();

__END__
