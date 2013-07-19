package App::Midgen::Role::Output::Dzil;

use v5.10;
use Moo::Role;
requires qw( verbose );

# turn off experimental warnings
no if $] > 5.017010, warnings => 'experimental::smartmatch';

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.25_09';
use English qw( -no_match_vars );    # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Term::ANSIColor qw( :constants colored );
use Data::Printer {caller_info => 1, colored => 1,};
use constant {BLANK => q{ }, NONE => q{}, THREE => 3,};
use File::Spec;

#######
# header_dzil
#######
sub header_dzil {
  my $self = shift;
  my $package_name = shift // NONE;

  if ($package_name ne NONE) {
    print "\n";
    say "'NAME' => '$package_name'";
    $package_name =~ s{::}{/}g;
    say "'VERSION_FROM' => 'lib/$package_name.pm'";
    print "\n";
  }

  return;
}
#######
# body_dzil
#######
sub body_dzil {
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

  given ($title) {
    when ('requires')      { say '\'PREREQ_PM\' => {'; }
    when ('test_requires') { say '\'BUILD_REQUIRES\' => {'; }
    when ('recommends')    { return; }
  }

  foreach my $module_name (sort keys %{$required_ref}) {

    my $sq_key = q{"} . $module_name . q{"};
    printf "\t %-*s => '%s',\n", $pm_length + 2, $sq_key,
      $required_ref->{$module_name};

  }
  say '},';

  return;
}
#######
# footer_dzil
#######
sub footer_dzil {
  my $self = shift;
  my $package_name = shift // NONE;
  $package_name =~ s{::}{-}g;

  if ($self->verbose > 0) {
    print BRIGHT_BLACK "\n";
    say '# ToDo you should consider the following';
    say '\'META_MERGE\' => {';
    say "\t'resources' => {";
    say "\t\t'homepage' => 'https://github.com/.../$package_name',";
    say "\t\t'repository' => 'git://github.com/.../$package_name.git',";
    say "\t\t'bugtracker' => 'https://github.com/.../$package_name/issues',";
    say "\t},";
    say "\t'x_contributors' => [";
    say "\t\t'brian d foy (ADOPTME) <brian.d.foy\@gmail.com>',";
    say "\t\t'Fred Bloggs <fred\@bloggs.org>',";
    say "\t],";
    say '},';
    print CLEAR "\n";
  }

  if (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'script')) {
    say '\'EXE_FILES\' => [qw(';
    say "\tscript/...";
    say ')],';
    print "\n";
  }
  elsif (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'bin')) {
    say '\'EXE_FILES\' => [qw(';
    say "\tbin/...";
    say ')],';
    print "\n";
  }

  return;
}

no Moo;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Role::Output::Dzil - Output Format - Dist::Zilla,
used by L<App::Midgen>

=head1 VERSION

version: 0.25_09

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

See L<App::Midgen>

=cut

