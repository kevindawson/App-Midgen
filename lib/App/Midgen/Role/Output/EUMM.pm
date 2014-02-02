package App::Midgen::Role::Output::EUMM;

use v5.10;
use Moo::Role;
requires qw( verbose );

# turn off experimental warnings
no if $] > 5.017010, warnings => 'experimental::smartmatch';

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.27_07';
use English qw( -no_match_vars );    # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Term::ANSIColor qw( :constants colored );
use Data::Printer {caller_info => 1, colored => 1,};
use constant {
	BLANK  => q{ },
	NONE   => q{},
	THREE  => q{   },
	SIX    => q{      },
	NINE   => q{         },
	TWELVE => q{            },
};
use File::Spec;

#######
# header_eumm
#######
sub header_eumm {
	my $self = shift;
	my $package_name = shift // NONE;

	if ($package_name ne NONE) {
		print "\n";

		say 'use strict;';
		say 'use warnings;';
		say 'use ExtUtils::MakeMaker 0.68;';
		print "\n";
		say 'WriteMakefile(';

		say THREE. "'NAME' => '$package_name',";
		$package_name =~ s{::}{/}g;
		say THREE. "'VERSION_FROM' => 'lib/$package_name.pm',";
		say THREE. "'ABSTRACT_FROM' => 'lib/$package_name.pm',";

		print BRIGHT_BLACK;
		say THREE. "'AUTHOR' => '...',";
		say THREE. "'LICENSE' => 'perl_5',";
		print CLEAR;
## 6.64 f***** RT#85406
		say THREE. "'BUILD_REQUIRES' => {";
		say SIX. "'ExtUtils::MakeMaker' => '6.68'";
		say THREE. "},";
		say THREE. "'CONFIGURE_REQUIRES' => {";
		say SIX. "'ExtUtils::MakeMaker' => '6.68'";
		say THREE. "},";
	}

	return;
}
#######
# body_eumm
#######
sub body_eumm {
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift;

	my $pm_length = 0;
	foreach my $module_name (sort keys %{$required_ref}) {
		if (length $module_name > $pm_length) {
			$pm_length = length $module_name;
		}
	}

	say THREE. "'MIN_PERL_VERSION' => '$App::Midgen::Min_Version',"
		if $title eq 'requires';

	return if not %{$required_ref} and $title =~ m{(?:requires)\z};

	given ($title) {
		when ('requires')      { say THREE. "'PREREQ_PM' => {"; }
		when ('test_requires') { say THREE. "'TEST_REQUIRES' => {"; }
		when ('recommends')    { $self->_recommends($required_ref); return; }
	}

	foreach my $module_name (sort keys %{$required_ref}) {

		my $sq_key = q{'} . $module_name . q{'};
		printf SIX. " %-*s => '%s',\n", $pm_length + 2, $sq_key,
			$required_ref->{$module_name};
	}
	say THREE. "},";

	return;
}

sub _recommends {
	my $self         = shift;
	my $required_ref = shift;

	my $pm_length = 0;
	foreach my $module_name (sort keys %{$required_ref}) {
		if (length $module_name > $pm_length) {
			$pm_length = length $module_name;
		}
	}
	say THREE. "'META_MERGE' => {";
	say SIX. "'meta-spec' => { 'version' => '2' },";
	return if not %{$required_ref};
	say SIX. "'prereqs' => {";
	say NINE. "'test' => {";
	say TWELVE. "'suggests' => {";
	foreach my $module_name (sort keys %{$required_ref}) {

		my $sq_key = q{'} . $module_name . q{'};
		printf "%-15s %-*s => '%s',\n", BLANK, $pm_length + 2, $sq_key,
			$required_ref->{$module_name};
	}
	say TWELVE. "}";
	say NINE. "}";
	say SIX. "},";

}


#######
# footer_eumm
#######
sub footer_eumm {
	my $self = shift;
	my $package_name = shift // NONE;
	$package_name =~ s{::}{-}g;

	if ($self->verbose > 0) {
		print BRIGHT_BLACK;

		say SIX. "'resources' => {";

		say NINE. "'bugtracker' => {";
		say TWELVE. "'web' => 'https://github.com/.../$package_name/issues',";
		say NINE. "},";

		say NINE. "'homepage' => 'https://github.com/.../$package_name',";

		say NINE. "'repository' => {";
		say TWELVE. "'type' => 'git',";
		say TWELVE. "'url' => 'git://github.com/.../$package_name.git',";
		say TWELVE. "'web' => 'https://github.com/.../$package_name',";
		say NINE. "},";
		say SIX. "},";

		say SIX. "'x_contributors' => [";
		say NINE. "'brian d foy (ADOPTME) <brian.d.foy\@gmail.com>',";
		say NINE. "'Fred Bloggs <fred\@bloggs.org>',";
		say SIX. "],";

		print CLEAR;
		say THREE. '},';

	}

# todo sort out below
	if (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'script')) {
		say THREE."'EXE_FILES' => [ (";
		say SIX. "'script/...'";
		say THREE.') ],';
#		print "\n";
	}
	elsif (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'bin')) {
		say THREE."'EXE_FILES' => [qw(";
		say SIX. "bin/...";
		say THREE.')],';
#		print "\n";
	}

	say ')'."\n";

	return;
}

no Moo;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Role::Output::EUMM - Output Format - ExtUtils::MakeMaker,
used by L<App::Midgen>

=head1 VERSION

version: 0.27_07

=head1 DESCRIPTION

The output format uses colour to add visualization of module version number
types, be that mcpan, dual-life or added distribution.

=head1 METHODS

=over 4

=item * header_eumm

=item * body_eumm

=item * footer_eumm

=back

=head1 DEPENDENCIES

L<Term::ANSIColor>

=head1 SEE ALSO

L<App::Midgen>

=head1 AUTHOR

See L<App::Midgen>

=head2 CONTRIBUTORS

See L<App::Midgen>

=head1 COPYRIGHT

See L<App::Midgen>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

