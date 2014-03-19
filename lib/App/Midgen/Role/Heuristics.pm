package App::Midgen::Role::Heuristics;

our $VERSION = '0.31_01';
$VERSION = eval $VERSION;    ## no critic

use constant {TRUE => 1, FALSE => 0,};

use Types::Standard qw( Bool );
use Moo::Role;
requires qw( debug );

use Try::Tiny;
use Data::Printer {caller_info => 1, colored => 1,};


#######
# composed method degree of separation
# double-bubble
#######
sub double_bubble {
	my $self           = shift;
	my $requires_ref   = shift || return;
	my $recommends_ref = shift || return;

	#extract module names to check from RuntimeRecommends bucket
	my @runtime_recommends;
	foreach my $current_recommends (sort keys %{$recommends_ref}) {
		push @runtime_recommends, $current_recommends;
	}

	foreach my $module (@runtime_recommends) {

		try {
			unless ($self->{modules}{$module}{dual_life}
				or $self->{modules}{$module}{corelist} == 1
				or $self->{modules}{$module}{version} eq '!mcpan'
				or $self->{modules}{$module}{count} == 1)
			{
				if ($self->shuffle($module, $self->{modules}{$module}{infiles})) {

					# add to RuntimeRequires
					$requires_ref->{$module} = $recommends_ref->{$module};

					# delete from RuntimeRecommends
					delete $recommends_ref->{$module};

					# update infiles
					$self->{modules}{$module}{prereqs} = 'RuntimeRequires';

					p $self->{modules}{$module} if $self->debug;
				}
			}
		};
	}

	return;
}

## this may help for future hacking
#    [0] "/lib/Module/Install/Admin/Metadata.pm",
#    [1] 0,
#    [2] "Perl::PrereqScanner",
#    [3] "RuntimeRequires"


#######
# composed method
#######
sub shuffle {
	my $self = shift;
	my ($module, $infile) = @_;

	foreach my $index (0 .. $#{$infile}) {

		# next if in a test dir
		next if $infile->[$index][0] =~ m/\A\/x?t/;
		next if $infile->[$index][3] eq 'RuntimeRecommends';

		if ($infile->[$index][3] eq 'RuntimeRequires'
			and ($infile->[$index][0] ne $infile->[$index - 1][0]))
		{
			p $module if $self->debug;
			p $infile->[$index] if $self->debug;

			return TRUE;
		}
	}

	return FALSE;
}


no Moo::Role;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Midgen::Roles::Heuristics - used by L<App::Midgen>

=head1 VERSION

version: 0.31_01

=head1 METHODS

=over 4

=item * degree_separation

now a separate Method, returns an integer.

=item * remove_noisy_children

Parent A::B has noisy Children A::B::C and A::B::D all with same version number.

=item * remove_twins

Twins E::F::G and E::F::H  have a parent E::F with same version number,
 so we add a parent E::F and re-test for noisy children,
 catching triplets along the way.

=item * run

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










