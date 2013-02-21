use inc::Module::Install::DSL 1.06;

all_from lib/App/Midgen.pm
requires_from lib/App/Midgen.pm

requires CPAN                         1.9800
requires Carp                         1.26
requires Cwd                          3.40
requires Data::Printer                0.35
requires File::Slurp                  9999.19
requires File::Spec                   3.40
requires Getopt::Long                 2.38
requires Module::CoreList             2.82
requires Moo                          1.000008
requires MooX::Types::MooseLike::Base 0.21
requires PPI                          1.215
requires Pod::Usage                   1.61
requires Try::Tiny                    0.12
requires constant                     1.25
requires lib                          0.63

test_requires Test::More 0.98

install_script midgen

homepage    https://github.com/kevindawson/App-Midgen
bugtracker  https://github.com/kevindawson/App-Midgen/issues
repository  git://github.com/kevindawson/App-Midgen.git

no_index directory  qw{ t xt eg share inc privinc }

