use inc::Module::Install::DSL 1.06;

all_from lib/App::Midgen.pm
requires_from lib/App::Midgen.pm

requires Data::Printer 0.35
requires File::Slurp   9999.19
requires PPI           1.215
requires Try::Tiny     0.12


test_requires Test::More 0.98

install_script midgen

no_index directory  qw{ t xt eg share inc privinc }




__END__

use 5.006;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name     'App-Midgen';
all_from 'lib/App/Midgen.pm';
author   q{kevin dawson <bowtie@cpan.org>};
license  'perl';

perl_version 5.006;

tests_recursive('t');

resources (
   #homepage   => 'http://yourwebsitehere.com',
   #IRC        => 'irc://irc.perl.org/#App-Midgen',
   license    => 'http://dev.perl.org/licenses/',
   #repository => 'git://github.com/kevin dawson/App-Midgen.git',
   bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Midgen',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
);

requires (
   #'ABC'              => 1.6,
   #'Foo::Bar::Module' => 5.0401,
);

install_as_cpan;
auto_install;
WriteAll;
