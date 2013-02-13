package App::Midgen::Output;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.08';
use English qw( -no_match_vars ); # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Moo;
use Carp;
use CPAN;
use Data::Printer {
	caller_info => 1,
	colored     => 1,
};

#######
# header_dsl
#######
sub header_dsl {
	my $self         = shift;
	my $package_name = shift;

	# Let's get the current version of Module::Install::DSL
	my $mod = CPAN::Shell->expand( 'Module', 'inc::Module::Install::DSL' );
	$package_name =~ s{::}{/};

	print "\n";
	say 'use inc::Module::Install::DSL ' . $mod->cpan_version . ';';
	print "\n";
	say 'all_from lib/' . $package_name . '.pm';
	say 'requires_from lib/' . $package_name . '.pm';

	return;
}
#######
# header_mi
#######
sub header_mi {
	my $self         = shift;
	my $package_name = shift;

	print "\n";
	say 'mi header underdevelopment';
	print "\n";

	return;
}
#######
# header_build
#######
sub header_build {
	my $self         = shift;
	my $package_name = shift;

	print "\n";
	say 'build header underdevelopment';
	print "\n";
	
	return;
}
#######
# header_dzil
#######
sub header_dzil {
	my $self         = shift;
	my $package_name = shift;
	
	print "\n";
	say 'dzil header underdevelopment';
	print "\n";

	return;
}


1;
