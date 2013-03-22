use inc::Module::Install::DSL 1.06;

all_from lib/App/Midgen.pm
requires_from lib/App/Midgen.pm

perl_version 5.010001

requires Carp                   1.26
requires Cwd                    3.4
requires Data::Printer          0.35
requires File::Slurp            9999.19
requires File::Spec             3.4
requires Getopt::Long           2.39
requires JSON::Tiny             0.25
requires MetaCPAN::API          0.43
requires Module::CoreList       2.85
requires Moo                    1.001
requires MooX::Types::MooseLike 0.23
requires PPI                    1.215
requires Perl::MinimumVersion   1.32
requires Perl::PrereqScanner    1.015
requires Pod::Usage             1.61
requires Scalar::Util           1.27
requires Term::ANSIColor        4.02
requires Time::Stamp            1.3
requires Try::Tiny              0.12
requires constant               1.27
requires version                0.9902

test_requires Test::More 0.98

recommends Test::Pod           1.46
recommends Test::Pod::Coverage 1.08

install_script midgen

homepage    https://github.com/kevindawson/App-Midgen
bugtracker  https://github.com/kevindawson/App-Midgen/issues
repository  git://github.com/kevindawson/App-Midgen.git

no_index directory  qw{ inc t xt }
