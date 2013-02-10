App::Midgen
==========

generate the requires and test requires for Makefile.PL using Module::Install::DSL

Version: 0.07

Usage:
    midgen [options]

     Options:
       -help        brief help message
       -output      change format
       -core        show perl core modules
       -verbose     take a little peek as to what is going on
       -base        Don't check for base includes
       -mojo        Don't be Mojo friendly  
       -debug       lots of stuff

Options:
    --help or -h
        Print a brief help message and exits.

    --output or -o
        By default we do 'dsl' -> Module::Include::DSL

         midgen.pl -o dsl       # Module::Include::DSL
         midgen.pl -o mi        # Module::Include
         midgen.pl -o build     # Build.PL

    -core or -c
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

    --debug or -d
        equivalent of -cv and some :)
