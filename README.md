App::Midgen
==========

Generate or Check the 'requires' and 'test requires' for Makefile.PL

This is an aid to show you a packages module requirements by scanning the package, 
then display in a familiar format with the current version number from MetaCPAN.

This started as a way of generating the formatted contents for a 
Module::Install::DSL Makefile.PL, which has now grown to support other output 
formats, as well as the ability to show **dual-life** and **perl core** modules, 
This enables you to see which modules you have used,

All output goes to STDOUT, so you can use it as you see fit.

### Version 0.21

## Synopsis

Change to the root of the package you want to scan and run

    midgen

Now with a added Getopt --help or -?

    midgen -?

### Usage
midgen [options]

    --help           brief help message
    --format         change output format
    --dual_life      show dual-life modules
    --core           show all perl core modules
    --verbose        take a little peek as to what is going on
    --experimental   this feature under development
    --zero           show a 0 instead of core
    --debug          provides vast amount of output, re self development


## Description
**midgen** function is to search your Perl Module and find Includes **use** and **require** and then present them 
in a format which you can easily use. Besides finding the included Modules it also finds the current version.

It try s to remove unwanted noise and duplication along the way.
* Ignores all sub modules of current Module
* Noisy Children parent A::B noisy Children A::B::C or A::B::D all with same version number.
* Twins E::F::G and E::F::H and a parent E::F and re-test for noisy children, catching triplets along the way.


_Food for thought, if we update our Modules, don't we want our users to use the current version, so should we not by default do the same with others Modules._

## Options

####--help or -h or -?
Print a brief help message and exits.

    midgen -?

####--format or -f
By default we output to STDOUT in 'dsl' format, so you can check, copy n paste or select an alternative format as shown below.

    midgen -f dsl          # Module::Include::DSL
    midgen -f mi           # Module::Include
    midgen -f build        # Build
    midgen -f dzil         # Dist::Zilla
    midgen -f dist         # dist.ini
    midgen -f cpanfile     # cpanfile prereqs

####--dual_life or -l
Shows modules that are in Perl core and CPAN, some modules have a
version number eg; constant, Carp

    midgen -l

####--core or -c
Shows all modules that are in Perl core, including dual-life, some have a version of 0 eg; strict, English

    midgen -c

####--verbose or -v
Show file names that we are checking, as we go

    midgen -v

####--experimental or -x
This experimental feature turns on extra passing, that removes twins and noisy_children, 
replacing them with there parent(dist), giving a minimalist output, you might conceive this as controversial, 
if so don't enable it.

    midgen -x

####--zero or z
Use a '0' instead of 'core' for core module version number, suggest you incorporate it with core for maximum affect

    midgen -cz

####--write or -w
You can now write your current options to ~/.midgenrc in JSON format (core, dual_life, format, zero), to be used again. 
I you want to edit your ~./midgenrc file, you could use the Getopt --no-option to negate an option, 
or you can edit/delete the file, your choice.

    midgen --no-z -w

####--debug or -d
Provides a vast amount of output, relevant to development also enables (core, verbose)

uses Data::Printer

Suggest you consider redirecting STDERR when the debug option is used

    midgen -d 2>debug.txt
