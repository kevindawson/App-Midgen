package App::Midgen::Role::Output::MIdsl;

use v5.10;
use Moo::Role;
requires qw( no_index verbose );

# turn off experimental warnings
no if $] > 5.017010, warnings => 'experimental::smartmatch';

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.29_09';
$VERSION = eval $VERSION; ## no critic

use English qw( -no_match_vars );    # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Term::ANSIColor qw( :constants colored );
use Data::Printer {caller_info => 1, colored => 1,};
use constant {BLANK => q{ }, NONE => q{}, THREE => 3,};
use File::Spec;

#######
# header_dsl
#######
sub header_dsl {
  my $self         = shift;
  my $package_name = shift // NONE;
  my $mi_ver       = shift // NONE;

  $package_name =~ s{::}{/}g;

  print "\n";
  say 'use inc::Module::Install::DSL ' . colored($mi_ver, 'yellow') . q{;};
  print "\n";
  if ($package_name ne NONE) {
    say 'all_from lib/' . $package_name . '.pm';
    say 'requires_from lib/' . $package_name . '.pm';
  }

  print "\n";
  return;
}
#######
# body_dsl
#######
sub body_dsl {
  my $self         = shift;
  my $title        = shift;
  my $required_ref = shift || return;
  say 'perl_version ' . $App::Midgen::Min_Version if $title eq 'requires';
  print "\n";

  my $pm_length = 0;
  foreach my $module_name (sort keys %{$required_ref}) {
    if (length $module_name > $pm_length) {
      $pm_length = length $module_name;
    }
  }

  foreach my $module_name (sort keys %{$required_ref}) {

    if ($module_name =~ /^Win32/sxm) {
      printf "%s %-*s %s %s\n", $title, $pm_length, $module_name,
        $required_ref->{$module_name}, colored('if win32', 'bright_green');
    }
    else {
      printf "%s %-*s %s\n", $title, $pm_length, $module_name,
        $required_ref->{$module_name};
    }
  }
  return;
}
#######
# footer_dsl
#######
sub footer_dsl {
  my $self = shift;
  my $package_name = shift // NONE;
  $package_name =~ s{::}{-}g;

  if ($self->verbose > 0) {
    print BRIGHT_BLACK "\n";
    say '# ToDo you should consider the following';
    say "homepage    https://github.com/.../$package_name";
    say "bugtracker  https://github.com/.../$package_name/issues";
    say "repository  git://github.com/.../$package_name.git";
    print CLEAR "\n";
  }
  if (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'share')) {
    say 'install_share';
    print "\n";
  }

  if (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'script')) {
    say 'install_script ...';
    print "\n";
  }
  elsif (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'bin')) {
    say 'install_script bin/...';
    print "\n";
  }

  my @no_index = $self->no_index;
  if (@no_index) {
    say "no_index directory qw{ @no_index }";
    print "\n";
  }

  #	print "\n";

  return;
}

no Moo;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Midgen::Role::Output::MIdsl Output Format - Module::Install::DSL,
used by L<App::Midgen>

=head1 VERSION

version: 0.29_09

=head1 DESCRIPTION

The output format uses colour to add visualization of module version number
types, be that mcpan, dual-life or added distribution.

=head1 METHODS

=over 4

=item * header_dsl

=item * body_dsl

=item * footer_dsl

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
