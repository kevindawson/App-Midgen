App::Midgen
==========

Generate or Check the 'requires' and 'test requires' for Makefile.PL

This started out as a way of generating the core for a Module::Install::DSL Makefile.PL, 
why DSL because it's nice and clean, so now I can generate the contents when I want, 
rather than as I add new use and require statments, and because adam kicked me :)


### Version 0.10

## Synopsis

Change to the root of the package you want to scan and run

 midgen


Now with a added Getopt --help or -?

 midgen -?

### Usage
    midgen [options]

       --help        brief help message
       --output      change format
       --core        show perl core modules
       --verbose     take a little peek as to what is going on
       --base        Don't check for base includes
       --mojo        Don't be Mojo friendly
       --debug       lots of stuff


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
        By default we do 'dsl' -> Module::Include::DSL

         midgen -o dsl      # Module::Include::DSL
         midgen -o mi       # Module::Include
         midgen -o build    # Build.PL
         midgen -o dzil     # Dist::Zilla
         midgen -o dist		# dist.ini

    --core or -c
         * Shows modules that are in Perl core
         * some modules have a version number eg; constant, Carp
         * some have a version of 0 eg; strict, English

    --verbose or -v
        Show file that are being checked

        also show contents of base|parent check

    --parent or -p
        alternative --base or -b

        Turn Off - try to include the contents of base|parent modules as
        well

    --mojo or -m
        Turn Off - the /Mojo/ to Mojolicious catch

    --noisy_children or -n
         * Show a required modules noisy children, as we find them
         
    --twins or -t
         * Show a modules that are twins as we find them, and ajust for there parient instead

    --debug or -d
        equivalent of -cv and some :)
