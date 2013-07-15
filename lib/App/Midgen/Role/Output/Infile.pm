package App::Midgen::Role::Output::Infile;

use v5.10;
use Moo::Role;
requires qw( core dual_life );

# turn off experimental warnings
no if $] > 5.017010, warnings => 'experimental::smartmatch';

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.25_05';
use English qw( -no_match_vars );
local $OUTPUT_AUTOFLUSH = 1;

use Term::ANSIColor qw( :constants colored );
use Data::Printer {caller_info => 1, colored => 1,};
use constant {BLANK => q{ }, NONE => q{}, THREE => 3, EIGHT => 8};
use File::Spec;

#######
# header_infile
#######
sub header_infile {
  my $self = shift;

  print qq{\n};

  return;
}
#######
# body_infile
#######
sub body_infile {
  my $self = shift;

  return;
}
#######
# footer_infile
#######
sub footer_infile {
  my $self = shift;

#p $self->{modules};

  # Let's work out our padding
  my $pm_length  = 0;
  my $dir_length = 0;
  foreach my $module_name (sort keys %{$self->{modules}}) {

    if (length $module_name > $pm_length) {
      $pm_length = length $module_name;
    }

    foreach my $foundin (sort @{$self->{modules}{$module_name}{infiles}}) {
      if (length $foundin->[0] > $dir_length) {
        $dir_length = length $foundin->[0];
      }
    }

  }

  say "  " . "-" x EIGHT . "-" x $pm_length . "-" x $dir_length . "-" x EIGHT;

  printf " | %-*s | %-*s | %-*s |\n", $pm_length, 'Module', EIGHT, 'Version ',
    $dir_length, 'Found in';
  say "  " . "-" x EIGHT . "-" x $pm_length . "-" x $dir_length . "-" x EIGHT;


  foreach my $module_name (sort keys %{$self->{modules}}) {

    # honnor options dual-life and core module display
    if ($self->core) {

      # do nothing
    }
    elsif ($self->dual_life) {
      next
        if ($self->{modules}{$module_name}{corelist}
        and not $self->{modules}{$module_name}{dual_life});
    }
    else {
      next if $self->{modules}{$module_name}{corelist};
    }


    foreach my $foundin (sort @{$self->{modules}{$module_name}{infiles}}) {
      printf " | %-*s | %-*s | %-*s |\n", $pm_length, $module_name, EIGHT,
        $foundin->[1], $dir_length, $foundin->[0],;
    }
  }

  say "  " . "-" x EIGHT . "-" x $pm_length . "-" x $dir_length . "-" x EIGHT;

  print qq{\n};

  return;
}

no Moo;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Role::Output::Infile; - A collection of output orientated methods used by L<App::Midgen>

=head1 VERSION

version: 0.25_05

=head1 DESCRIPTION

This output format list modules found against the files they were Included in.

=head1 METHODS

=over 4

=item * header_infile

=item * body_infile

=item * footer_infile

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
