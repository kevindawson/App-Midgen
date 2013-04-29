package App::Midgen::Role::TestRequires;

use v5.10;
use Moo::Role;
#use MooX::Types::MooseLike::Base qw(:all);
use Data::Printer { caller_info => 1, colored => 1, };

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.21_08';
use constant {BLANK => q{ }, NONE => q{}, TWO => 2, THREE => 3,};


#######
# composed method - _xtests_test_requires
#######
sub _xtests_test_requires {
  my $self = shift;

#  PPI::Statement::Include
#    PPI::Token::Word  	'use'
#    PPI::Token::Whitespace  	' '
#    PPI::Token::Word  	'Test::Requires'
#    PPI::Token::Whitespace  	' '
#    PPI::Structure::Constructor  	{ ... }
#      PPI::Token::Whitespace  	' '
#      PPI::Statement
#        PPI::Token::Quote::Single  	''Test::Pod''
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Operator  	'=>'
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Number::Float  	'1.46'
#      PPI::Token::Whitespace  	' '
#    PPI::Token::Structure  	';'
  my @modules;
  my @version_strings;
  my @chunks =

    map { [$_->schildren] }

    grep { $_->child(2)->literal =~ m{\A(?:Test::Requires)\z} }
    grep { $_->child(2)->isa('PPI::Token::Word') }

    grep { $_->child(0)->literal =~ m{\A(?:use)\z} }
    grep { $_->child(0)->isa('PPI::Token::Word') }
    @{$self->ppi_document->find('PPI::Statement::Include') || []};

#  p @chunks;

# 0    PPI::Token::Word  	'use'
# 1    PPI::Token::Word  	'Test::Requires'
# 2    PPI::Structure::Constructor  	{ ... }
#        PPI::Token::Whitespace  	' '
#        PPI::Statement
#          PPI::Token::Quote::Single  	''Test::Pod''
#          PPI::Token::Whitespace  	' '
#          PPI::Token::Operator  	'=>'
#          PPI::Token::Whitespace  	' '
#          PPI::Token::Number::Float  	'1.46'
#        PPI::Token::Whitespace  	' '
#      PPI::Token::Structure  	';'

  foreach my $hunk (@chunks) {

	# looking for use Test::Requires { 'Test::Pod' => 1.46 };
    if (grep { $_->isa('PPI::Structure::Constructor') } @$hunk) {

      # hack for List
      my @hunkdata = @$hunk;

      # now we have an array
#      p @hunkdata;

      foreach my $ppi_sc (@hunkdata) {
        if ($ppi_sc->isa('PPI::Structure::Constructor')) {

#          p $ppi_sc;
#          say $ppi_sc;

#          p $ppi_sc->{children};

          foreach my $ppi_s (@{$ppi_sc->{children}}) {
            if ($ppi_s->isa('PPI::Statement')) {
              p $ppi_s if $self->debug;


              foreach my $element (@{$ppi_s->{children}}) {
                if ( $element->isa('PPI::Token::Quote::Single')
                  || $element->isa('PPI::Token::Quote::Double'))
                {


                  my $module = $element;

                  $module =~ s/^['|"]//;
                  $module =~ s/['|"]$//;
                  if ($module =~ m/\A[A-Z]/) {
                    say 'found module - ' . $module if $self->debug;
                    push @modules, $module;    # if $module =~ m/\A[A-Z]/;
                  }

                }

                if ( $element->isa('PPI::Token::Number::Float')
                  || $element->isa('PPI::Token::Quote::Single')
                  || $element->isa('PPI::Token::Quote::Double'))
                {
                  my $version_string = $element;

                  #                 p $version_string;
                  $version_string =~ s/^['|"]//;
                  $version_string =~ s/['|"]$//;
                  next if $version_string !~ m/\A[\d|v]/;
                  if ($version_string =~ m/\A[\d|v]/) {

                    push @version_strings,
                      $version_string;    # if =~ m/\A[\d|v]/;


                    say 'found version_string - ' . $version_string
                      if $self->debug;
                  }

                }
              }
            }
          }
        }
      }
    }

# looking for use Test::Requires qw(MIME::Types);
if (grep { $_->isa('PPI::Token::QuoteLike::Words') } @$hunk) {

  # hack for List
  my @hunkdata = @$hunk;

  # now we have an array
#  p @hunkdata;

  foreach my $ppi_tqw (@hunkdata) {
    if ($ppi_tqw->isa('PPI::Token::QuoteLike::Words')) {

#      p $ppi_tqw;
#     p $ppi_tqw->{content};
#      p $ppi_tqw->{operator};
      my $operator = $ppi_tqw->{operator};

#      p $ppi_tqw->{sections}->[0]->{type};

      my @type = split(//, $ppi_tqw->{sections}->[0]->{type});
#      p @type;

      my $module = $ppi_tqw->{content};
      $module =~ s/$operator//; 
#	  $module =~ s/\A$ppi_tqw->{operator}//;

#      p $module;

# my $type_open = "$type[0]";
      my $type_open = '\A\\' . $type[0];
#      p $type_open;
      $module =~ s{$type_open}{};
      my $type_close = '\\' . $type[1] . '\Z';
#      p $type_close;
      $module =~ s{$type_close}{};
#      p $module;
#      push @modules, $module;
      push @modules, split(BLANK, $module);

    }

  }

}



  }
  p @modules if $self->debug;
  p @version_strings if $self->debug;

  # if we found a module, process it
  if (scalar @modules > 0) {

    if ($self->format eq 'cpanfile') {

      if ($self->xtest eq 'test_requires') {
        $self->_process_found_modules('recommends', \@modules);
      }
      elsif ($self->xtest eq 'test_requires') {
        $self->_process_found_modules('test_requires', \@modules);
      }
      elsif ($self->develop && $self->xtest eq 'test_develop') {
        $self->_process_found_modules('test_develop', \@modules);
      }
    }
    else {
      $self->_process_found_modules('recommends', \@modules);
    }


#    if ($self->develop && $self->xtest eq 'test_develop') {
#      $self->_process_found_modules('recommends', \@modules);
#    }
#    else {
#      $self->_process_found_modules('test_requires', \@modules);
#    }

  }

	return;
}






no Moo::Role;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Roles - Package Options and Attributes used by L<App::Midgen>

=head1 VERSION

This document describes App::Midgen::Roles version: 0.21_08

=head1 METHODS

none as such, but we do have

=head2 OPTIONS

=over 4

=item * core

=item * debug

=item * dual_life

=item * experimental

=item * quiet

=item * format

=item * verbose

0 -> off
1 -> default
2 -> show files

=item * zero

=back

for more info see L<midgen>

=head2 ACCESSORS

=over 4

=item * found_twins

Used as a flag to re-run noisy children after discovery of twins

=item * mcpan

accessor to MetaCPAN::API object

=item * output

accessor to App::Midgen::Output object

=item * package_name

Our best guess as to this packages name

=item * package_names

Some package names we found along the way

=item * ppi_document

I encapsulated this and got a nifty speed increase

=item * recommends

Some where to store recommend modules and version info in

=item * requires

Some where to store required modules and version info in

=item * scanner

accessor to Perl::PrereqScanner object

=item * test_requires

Some where to store test_required modules and version info in


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
