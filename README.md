App::Midgen
==========

Generate or Check the 'requires' and 'test requires' for Makefile.PL

This started out as a way of generating the core for a Module::Install::DSL Makefile.PL, 
why DSL because it's nice and clean, so now I can generate the contents when I want, 
rather than as I add new use and require statments, and because adam kicked me :)


### Version 0.14

## Synopsis

Change to the root of the package you want to scan and run

 midgen


Now with a added Getopt --help or -?

 midgen -?

### Usage
    midgen [options]

    --help           brief help message
    --output         change format
    --core           show perl core modules
    --verbose        take a little peek as to what is going on
    --mojo           show the Mojo catch as we find them
    --noisy_children show them as we find them
    --twins          show twins as we find them
    --zero           show a 0 instead of core
    --debug          lot's of stuff very


## Description
**midgen** function is to search your Perl Module and find Includes **use** and **require** and then present them in a format which you can easily use.
Besides finding the included Modules it also finds the current version.

It try s to remove unwanted noise and duplication along the way.
* Ignores all sub modules of current Module
* Noisy Children parent A::B noisy Children A::B::C or A::B::D all with same version number.
* Twins E::F::G and E::F::H and a parent E::F and re-test for noisy children, catching triplets along the way.
* Mojolicious catch, mofphs Mojo::Base into Mojolicious

_Food for thought, if we update our Modules, don't we want our users to use the current version, so should we not by default do the same with others Modules._

## Options

    --help or -h or -?
        Print a brief help message and exits.

    --output or -o
        By default we output to STDOUT in 'dsl' format, so you can check,
        copy n paste or select an alternative format as shown below.

         midgen -o dsl          # Module::Include::DSL
         midgen -o mi           # Module::Include
         midgen -o build        # Build
         midgen -o dzil         # Dist::Zilla
         midgen -o dist         # dist.ini

    --core or -c
         * Shows modules that are in Perl core
         * some modules have a version number eg; constant, Carp
         * some have a version of 0 eg; strict, English
         * also show any recommends that we found

    --verbose or -v
        Show filename that we are checking, as we go

    --mojo or -m
        Turn on extra output to show the /Mojo/ to Mojolicious catch, as we
        find them, suggest you incorporate it with verbose for maximum
        affect

         midgen -vm

    --noisy_children or -n
        Turn on extra output to show the modules considered to be noisy
        children, as we find them

         midgen -n

    --twins or -t
        Turn on extra output to show the modules that are twins, as we find
        them, suggest you incorporate it with noisy_children for maximum
        affect

         midgen -nt

    --zero or z
        Use a '0' instead of 'core' for core module version number, suggest
        you incorporate it with core for maximum affect

         midgen -cz

    --debug or -d
        equivalent of -cnmptv and some :))

        uses Data::Printer

        suggest you consider redirecting STDERR when the debug option is
        used

         midgen -d 2>debug.txt

