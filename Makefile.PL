use inc::Module::Install::DSL 1.06;

all_from lib/App/Midgen.pm
requires_from lib/App/Midgen.pm

perl_version 5.010001

requires Carp                   1.260
requires Cwd                    3.400
requires Data::Printer          0.350
requires File::Spec             3.400
requires Getopt::Long           2.390
requires MetaCPAN::API          0.430
requires Module::CoreList       2.840
requires Moo                    1.001
requires MooX::Types::MooseLike 0.230
requires PPI                    1.215
requires Perl::MinimumVersion   1.320
requires Perl::PrereqScanner    1.015
requires Pod::Usage             1.610
requires Scalar::Util           1.270
requires Time::Stamp            1.300
requires Try::Tiny              0.120
requires constant               1.250
requires version                0.990200

test_requires Test::More 0.980

recommends Test::Pod           1.460
recommends Test::Pod::Coverage 1.080

install_script midgen

homepage    https://github.com/kevindawson/App-Midgen
bugtracker  https://github.com/kevindawson/App-Midgen/issues
repository  git://github.com/kevindawson/App-Midgen.git

no_index directory  qw{ inc t xt }
