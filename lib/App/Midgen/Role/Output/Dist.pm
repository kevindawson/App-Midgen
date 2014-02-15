package App::Midgen::Role::Output::Dist;

use v5.10;
use Moo::Role;
requires qw( no_index verbose );

# turn off experimental warnings
no if $] > 5.017010, warnings => 'experimental::smartmatch';

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.29_07';
use English qw( -no_match_vars );    # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Term::ANSIColor qw( :constants colored );
use Data::Printer {caller_info => 1, colored => 1,};
use constant {BLANK => q{ }, NONE => q{}, THREE => 3,};
use File::Spec;

#######
# header_dist
#######
sub header_dist {
  my $self = shift;
  my $package_name = shift // NONE;

  if ($package_name ne NONE) {
    print "\n";
    $package_name =~ s{::}{-}g;
    say 'name        = ' . $package_name;
    $package_name =~ tr{-}{/};
    say "main_module = lib/$package_name.pm";
    print "\n";
  }

  return;
}

#######
# body_dist
#######
sub body_dist {
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
    when ('requires') {
      say '[Prereqs]';
      printf "%-*s = %s\n", $pm_length, 'perl', $App::Midgen::Min_Version;
    }
    when ('test_requires') { say '[Prereqs / TestRequires]'; }
    when ('recommends')    { say '[Prereqs / RuntimeRecommends]'; }
  }

  foreach my $module_name (sort keys %{$required_ref}) {

    # my $sq_key = '"' . $module_name . '"';
    printf "%-*s = %s\n", $pm_length, $module_name,
      $required_ref->{$module_name};

  }

  return;
}

#######
# footer_dist
#######
sub footer_dist {
  my $self = shift;
  my $package_name = shift // NONE;
  $package_name =~ s{::}{-}g;

  print "\n";
  my @no_index = $self->no_index;
  if (@no_index) {
    say '[MetaNoIndex]';
    foreach (@no_index) {
      say "directory = $_" if $_ ne 'inc';
    }
    print "\n";
  }

  if (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'share')) {
    say '[ShareDir]';
    say 'dir = share';
    print "\n";
  }

  if (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'script')) {
    say '[ExecDir]';
    say 'dir = script';
    print "\n";
  }
  elsif (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'bin')) {
    say '[ExecDir]';
    say 'dir = bin';
    print "\n";
  }

  if ($self->verbose > 0) {
    say BRIGHT_BLACK '# ToDo you should consider the following';
    say '[MetaResources]';
    say "homepage          = https://github.com/.../$package_name";
    say "bugtracker.web    = https://github.com/.../$package_name/issues";
    say 'bugtracker.mailto = ...';
    say "repository.url    = git://github.com/.../$package_name.git";
    say 'repository.type   = git';
    say "repository.web    = https://github.com/.../$package_name";
    print "\n";

    say '[Meta::Contributors]';
    say 'contributor = brian d foy (ADOPTME) <brian.d.foy@gmail.com>';
    say 'contributor = Fred Bloggs <fred@bloggs.org>';
    print CLEAR "\n";
  }

  return;
}


no Moo;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Midgen::Role::Output::Dist - Output Format - dist.ini,
used by L<App::Midgen>

=head1 VERSION

version: 0.29_07

=head1 DESCRIPTION

The output format uses colour to add visualization of module version number
types, be that mcpan, dual-life or added distribution.

=head1 METHODS

=over 4

=item * header_dist

=item * body_dist

=item * footer_dist

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

