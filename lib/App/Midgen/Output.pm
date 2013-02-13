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
# body_dsl
#######
sub body_dsl {
	my $self = shift;
	
	return;
}
#######
# footer_dsl
#######
sub footer_dsl {
	my $self = shift;

	print "\n";
	say '#ToDo you should consider completing the following';
	say "homepage\t...";
	say "bugtracker\t...";
	say "repository\t...";

	print "\n";
	if ( defined -d './share' ) {
		say 'install_share';
		print "\n";
	}

	#ToDo add script
	
	say 'no_index directory  qw{ t xt eg share inc privinc }';

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
# body_mi
#######
sub body_mi {
	my $self = shift;
	
	return;
}
#######
# footer_mi
#######
sub footer_mi {
	my $self = shift;

	print "\n";
	say 'mi footer underdevelopment';
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
# body_build
#######
sub body_build {
	my $self = shift;
	
	return;
}
#######
# footer_build
#######
sub footer_build {
	my $self = shift;

	print "\n";
	say 'build footer underdevelopment';
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
#######
# body_dzil
#######
sub body_dzil {
	my $self = shift;
	
	return;
}
#######
# footer_dzil
#######
sub footer_dzil {
	my $self = shift;

	print "\n";
	say 'dzil footer underdevelopment';
	print "\n";

	return;
}

1;

__END__

