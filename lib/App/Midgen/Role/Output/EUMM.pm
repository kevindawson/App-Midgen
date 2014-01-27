package App::Midgen::Role::Output::EUMM;

use v5.10;
use Moo::Role;
requires qw( verbose );

# turn off experimental warnings
no if $] > 5.017010, warnings => 'experimental::smartmatch';

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.27_05';
use English qw( -no_match_vars );    # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Term::ANSIColor qw( :constants colored );
use Data::Printer {caller_info => 1, colored => 1,};
use constant {BLANK => q{ }, NONE => q{}, THREE => 3,};
use File::Spec;

#######
# header_eumm
#######
sub header_eumm {
  my $self = shift;
  my $package_name = shift // NONE;

  if ($package_name ne NONE) {
    print "\n";
#    say "'NAME' => '$package_name'";
#    $package_name =~ s{::}{/}g;
#    say "'VERSION_FROM' => 'lib/$package_name.pm'";

say 'use ExtUtils::MakeMaker;';
print "\n"; 
say 'WriteMakefile(';
    
    say "\t'NAME' => '$package_name',";
    $package_name =~ s{::}{/}g;
    say "\t'VERSION_FROM' => 'lib/$package_name.pm',";
print BRIGHT_BLACK "\n";
say "\t'CONFIGURE_REQUIRES' => {";
say "\t\t'ExtUtils::MakeMaker' => '6.64'";
say "\t},";
print CLEAR "\n";
#    print "\n";
  }

  return;
}
#######
# body_eumm
#######
sub body_eumm {
  my $self         = shift;
  my $title        = shift;
  my $required_ref = shift || return;
  print "\n";

  my $pm_length = 0;
  foreach my $module_name (sort keys %{$required_ref}) {
    if (length $module_name > $pm_length) {
      $pm_length = length $module_name;
    }
  }

  say "\t'MIN_PERL_VERSION' => '$App::Midgen::Min_Version',\n" if $title eq 'requires';
#  print "\n";

  given ($title) {
    when ('requires')      { say "\t'PREREQ_PM' => {"; }
    when ('test_requires') { say "\t'TEST_REQUIRES' => {"; }
    when ('recommends')    { return; }
  }

  foreach my $module_name (sort keys %{$required_ref}) {

    my $sq_key = q{'} . $module_name . q{'};
    printf "\t\t %-*s => '%s',\n", $pm_length + 2, $sq_key,
      $required_ref->{$module_name};
  }
  say "\t},";

  return;
}
#######
# footer_eumm
#######
sub footer_eumm {
  my $self = shift;
  my $package_name = shift // NONE;
  $package_name =~ s{::}{-}g;

  if ($self->verbose > 0) {
    print BRIGHT_BLACK "\n";
    say '# ToDo you should consider the following';
    say "\tMETA_MERGE => {";
	say "\t\t'meta-spec' => { version => 2 },";
    say "\t\t'resources' => {";
    say "\t\t\t'homepage' => 'https://github.com/.../$package_name',";
    say "\t\t\t'repository' => 'git://github.com/.../$package_name.git',";
    say "\t\t\t'bugtracker' => 'https://github.com/.../$package_name/issues',";
    say "\t\t},";
    say "\t\t'x_contributors' => [";
    say "\t\t\t'brian d foy (ADOPTME) <brian.d.foy\@gmail.com>',";
    say "\t\t\t'Fred Bloggs <fred\@bloggs.org>',";
    say "\t\t],";
    say "\t},";
    print CLEAR "\n";
  }

  if (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'script')) {
    say "\t'EXE_FILES' => [qw(";
    say "\t\tscript/...";
    say "\t)],";
    print "\n";
  }
  elsif (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'bin')) {
    say "\t'EXE_FILES' => [qw(";
    say "\t\ttbin/...";
    say "\t)],";
    print "\n";
  }

  say '},';
  print "\n";

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

version: 0.27_05

=head1 DESCRIPTION

The output format uses colour to add visualization of module version number
types, be that mcpan, dual-life or added distribution.

=head1 METHODS

=over 4

=item * header_dzil

=item * body_dzil

=item * footer_dzil

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

