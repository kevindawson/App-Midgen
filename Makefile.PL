use inc::Module::Install::DSL 1.06;

all_from lib/App::Midgen.pm
requires_from lib/App::Midgen.pm

requires Data::Printer                0.35
requires File::Slurp                  9999.19
requires Moo                          1.000008
requires MooX::Types::MooseLike::Base 0.16
requires PPI                          1.215
requires Try::Tiny                    0.12

test_requires Test::More 0.98

install_script midgen

no_index directory  qw{ t xt eg share inc privinc }

