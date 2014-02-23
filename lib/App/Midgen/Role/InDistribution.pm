package App::Midgen::Role::InDistribution;

use v5.10;
use Types::Standard qw( Bool );
use Moo::Role;
requires qw( ppi_document debug );

our $VERSION = '0.29_09';
$VERSION = eval $VERSION; ## no critic

# turn off experimental warnings
no if $] > 5.017010, warnings => 'experimental::smartmatch';

use constant { TWO => 2, TRUE => 1, FALSE => 0,};

########
# is this a perl file
########
sub is_perlfile {
	my $self      = shift;
	my $filename  = $_;

	given ($filename) {
		when (m/[.]pm$/) {
			say 'looking for requires in (.pm)-> ' . $filename
				if $self->verbose >= TWO;
		}
		when (m/[.]t$/) {
			say 'looking for requires in (.t)-> ' . $filename
				if $self->verbose >= TWO;
		}
		when (m/[.]psgi$/) {
			say 'looking for requires in (.psgi)-> ' . $filename
				if $self->verbose >= TWO;
		}
		when (m/[.]\w{2,4}$/) {
			say 'rejecting ' . $filename if $self->verbose >= TWO;
			return FALSE;
		}
		default {
			return $self->_confirm_perlfile($filename);
		}
	}
	return TRUE;
}

########
# confirm if this a perl file
#######
sub _confirm_perlfile {
	my $self     = shift;
	my $filename = shift;

	$self->_set_ppi_document(PPI::Document->new($filename));
	my $ppi_tc = $self->ppi_document->find('PPI::Token::Comment');

	my $a_pl_file = 0;

	if ($ppi_tc) {

		# check first token-comment for a she-bang
		$a_pl_file = 1 if $ppi_tc->[0]->content =~ m/^#!.*perl.*$/;
	}

	if ($self->ppi_document->find('PPI::Statement::Package') || $a_pl_file) {
		if ($self->verbose >= TWO) {

			print "looking for requires in (package) -> "
				if $self->ppi_document->find('PPI::Statement::Package');
			print "looking for requires in (shebang) -> "
				if $ppi_tc->[0]->content =~ /perl/;
			say $filename ;
		}
		return TRUE;
	}
	else {
		return FALSE;
	}

}

no Moo::Role;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Midgen::Roles::InDistribution - used by L<App::Midgen>

=head1 VERSION

version: 0.29_09

=head1 METHODS

=over 4

=item * is_perlfile

Used to find perl files in your distribution to scan.

=back

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










