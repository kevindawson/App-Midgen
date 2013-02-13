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
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift;
	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}

	foreach my $module_name ( sort keys %{$required_ref} ) {

		if ( $module_name =~ /^Win32/sxm ) {
			printf "%s %-*s %s if win32\n", $title, $pm_length, $module_name, $required_ref->{$module_name};
		} else {
			printf "%s %-*s %s\n", $title, $pm_length, $module_name, $required_ref->{$module_name};
		}
	}
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
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift;
	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}

	foreach my $module_name ( sort keys %{$required_ref} ) {

		if ( $module_name =~ /^Win32/sxm ) {
			my $sq_key = "'$module_name'";
			printf "%s %-*s => '%s' if win32;\n", $title, $pm_length + 2, $sq_key, $required_ref->{$module_name};
		} else {
			my $sq_key = "'$module_name'";
			printf "%s %-*s => '%s';\n", $title, $pm_length + 2, $sq_key, $required_ref->{$module_name};
		}

	}

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
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift;
	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}

	say $title . ' => {';

	foreach my $module_name ( sort keys %{$required_ref} ) {

		my $sq_key = "'$module_name'";
		printf "\t %-*s => '%s',\n", $pm_length + 2, $sq_key, $required_ref->{$module_name};

	}
	say '},';
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
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift;
	print "\n";

	my $pm_length = 0;
	foreach my $module_name ( sort keys %{$required_ref} ) {
		if ( length $module_name > $pm_length ) {
			$pm_length = length $module_name;
		}
	}
	if ( $title eq 'requires' ) {
		say '"PREREQ_PM" => {';
	} else {
		say '"BUILD_REQUIRES" => {';
	}

	foreach my $module_name ( sort keys %{$required_ref} ) {

		my $sq_key = '"' . $module_name . '"';
		printf "\t %-*s => '%s',\n", $pm_length + 2, $sq_key, $required_ref->{$module_name};

	}
	say '},';
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

=pod

=encoding utf8

=head1 NAME

App::Midgen::Output - A selection of output orinated methods used by L<App::Midgen>

=head1 VERSION

This document describes App::Midgen::Output version 0.08

=head1 METHODS

=over 4

=item * header_dsl

=item * body_dsl

=item * footer_dsl

=item * header_mi

=item * body_mi

=item * footer_mi

=item * header_build

=item * body_build

=item * footer_build

=item * header_dzil

=item * body_dzil

=item * footer_dzil

=back


=head1 AUTHOR

Kevin Dawson E<lt>bowtie@cpan.orgE<gt>

=head2 CONTRIBUTORS

none at present

=head1 COPYRIGHT

Copyright E<copy> 2013 AUTHOR and CONTRIBUTORS as listed above.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl 5 itself.

=head1 SEE ALSO

L<App::Midgen>,

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut