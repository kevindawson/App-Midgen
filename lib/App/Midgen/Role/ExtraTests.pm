package App::Midgen::Role::ExtraTests;

use v5.10;
use Moo::Role;
#use MooX::Types::MooseLike::Base qw(:all);
use Data::Printer { caller_info => 1, colored => 1, };

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.22';




#######
# composed method - _xtests_in_single_quote
#######
sub _xtests_in_single_quote {
  my $self = shift;

  # Hack for use_ok in test files, Ouch!
  # Now lets double check the ptq-Single hidden in a test file
  my $ppi_tqs = $self->ppi_document->find('PPI::Token::Quote::Single');
  if ($ppi_tqs) {

    foreach my $include (@{$ppi_tqs}) {
      my $module = $include->content;
      $module =~ s/^[']//;
      $module =~ s/[']$//;

      p $module if $self->debug;

      $self->_xtests_includes($module);
    }
  }
  return;
}
#######
# composed method - _xtests_in_double_quote
#######
sub _xtests_in_double_quote {
  my $self = shift;

# Now lets double check the ptq-Doubles hidden in a test file - why O why - rtfm pbp
  my $ppi_tqd = $self->ppi_document->find('PPI::Token::Quote::Double');
  if ($ppi_tqd) {

    # my @modules;
    foreach my $include (@{$ppi_tqd}) {
      my $module = $include->content;
      $module =~ s/^["]//;
      $module =~ s/["]$//;

      p $module if $self->debug;

      $self->_xtests_includes($module);
    }
  }
  return;
}


#######
# composed method - _xtests_includes
#######
sub _xtests_includes {
  my $self   = shift;
  my $module = shift;
  my @modules;

  if ($module =~ /::/ && $module !~ /main/ && !$module =~ /use/) {

    $module =~ s/(\s[\w|\s]+)$//;
    p $module if $self->debug;

    # if we have found it already ignore it - or - contains ;|=
    if (not defined $self->{modules}{$module}{location} and $module !~ /[;|=]/)
    {
      push @modules, $module;
    }

  }
  elsif ($module =~ /::/ && $module =~ /^[use|require]/) {

    $module =~ s/^(use|require)\s+//;
    $module =~ s/(\s[\s|\w|\n|.|;]+)$//;
    $module =~ s/\s+([\$|\w|\n]+)$//;
    $module =~ s/\s+$//;
    p $module if $self->debug;

    # if we have found it already ignore it - or - contains ;|=
    if (not defined $self->{modules}{$module}{location} and $module !~ /[;|=]/)
    {
      push @modules, $module;
    }
  }

  # lets catch -> use Test::Requires { 'Test::Pod' => 1.46 };
#  elsif ($module =~ /^\w+::\w+/) {
#    $module =~ s/(\s.+)$//;
#    p $module if $self->debug;
#
#    if (not defined $self->{modules}{$module}{location} and $module !~ /[;|=]/)
#    {
#      push @modules, $module;
#      if ($self->xtest eq 'test_requires') {
#        $self->xtest('recommends');
#      }
#    }
#  }


  # if we found a module, process it
#  if (scalar @modules > 0) {
#    if ($self->xtest eq 'test_requires') {
#      $self->_process_found_modules('test_requires', \@modules);
#    }
#    elsif ($self->develop && $self->xtest eq 'test_develop') {
#      $self->_process_found_modules('test_develop', \@modules);
#    }
#    else {
#      $self->_process_found_modules('recommends', \@modules);
#    }
#  }

	# if we found a module, process it with the correct catogery
	if ( scalar @modules > 0 ) {

		if ( $self->format eq 'cpanfile' ) {
			# $self->xtest eq 'test_requires' -> t/
			# $self->xtest eq 'test_develop' -> xt/

			if ( $self->xtest eq 'test_requires' ) {
				$self->_process_found_modules( 'recommends', \@modules );
			} 
			elsif ( $self->develop && $self->xtest eq 'test_develop' ) {
				$self->_process_found_modules( 'test_develop', \@modules );
			}
		} else {
			$self->_process_found_modules( 'recommends', \@modules );
		}
	}


  return;
}





no Moo::Role;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Roles::ExtraTests - used by L<App::Midgen>

=head1 VERSION

This document describes App::Midgen::Roles version: 0.22

=head1 METHODS

none as such, but we do have

=head2 OPTIONS

=over 4

=item * ToDo


=back

=head1 SEE ALSO

L<App::Midgen>,

=head1 AUTHOR

See L<App::Midgen>

=head2 CONTRIBUTORS

See L<App::Midgen>

=head1 COPYRIGHT

See L<App::Midgen>

=head1 LICENSE

See L<App::Midgen>

=cut
