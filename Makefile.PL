use inc::Module::Install::DSL 1.06;

all_from lib/App/Midgen.pm
requires_from lib/App/Midgen.pm

perl_version 5.010001

requires Carp                       1.26
requires Cwd                        3.4
requires Class::XSAccessor          1.18 if can_cc
requires Data::Printer              0.35
requires File::Slurp                9999.19
requires File::Spec                 3.4
requires Getopt::Long               2.41
requires JSON::Tiny                 0.32
requires List::MoreUtils            0.33
requires MetaCPAN::API              0.43
requires Module::CoreList           2.92
requires Moo                        1.003
requires PPI                        1.215
requires PPI::XS                    0.902 if can_cc
requires Perl::MinimumVersion       1.32
requires Perl::MinimumVersion::Fast 0.1 if can_cc
requires Perl::PrereqScanner        1.016
requires Pod::Usage                 1.63
requires Scalar::Util               1.27
requires Term::ANSIColor            4.02
requires Time::Stamp                1.3
requires Try::Tiny                  0.16
requires Type::Tiny                 0.016
requires constant                   1.27
# requires lib                        0.63
requires version                    0.9902

test_requires Test::CheckDeps 0.006
test_requires Test::More      0.98
test_requires Test::Requires  0.07

recommends Test::Pod           1.48
recommends Test::Pod::Coverage 1.08

install_script midgen

homepage    https://github.com/kevindawson/App-Midgen
bugtracker  https://github.com/kevindawson/App-Midgen/issues
repository  git://github.com/kevindawson/App-Midgen.git

no_index directory  qw{ inc t xt }

