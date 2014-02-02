package App::Midgen::Role::Eval;

use v5.10;
use Moo::Role;
requires qw( ppi_document debug format xtest _process_found_modules develop );

use version 0.9902;
use Try::Tiny 0.12;
use Data::Printer {caller_info => 1, colored => 1,};

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.27_09';


#######
# composed method - _xtests_eval
#######
sub _xtests_eval {
	my $self = shift;

	#PPI::Document
	#  PPI::Statement
	#    PPI::Token::Word  	'eval'
	#    PPI::Token::Whitespace  	' '
	#    PPI::Token::Quote::Double  	'"require Test::Kwalitee::Extra $mod_ver"'
	#    PPI::Token::Structure  	';'
	#
	my @modules;
	my @version_strings;
	try {
		my @chunks
			= map { [$_->schildren] }
			grep  { $_->child(0)->literal =~ m{\A(?:eval|try)\z} }
			grep  { $_->child(0)->isa('PPI::Token::Word') }
			@{$self->ppi_document->find('PPI::Statement') || []};

		foreach my $hunk (@chunks) {

			if (
				grep {
					     $_->isa('PPI::Token::Quote::Double')
						|| $_->isa('PPI::Token::Quote::Single')
						|| $_->isa('PPI::Structure::Block')
				} @$hunk
				)
			{

				# hack for List
				my @hunkdata = @$hunk;
				foreach my $element (@hunkdata) {
					if ( $element->isa('PPI::Token::Quote::Double')
						|| $element->isa('PPI::Token::Quote::Single'))
					{

						my $eval_line = $element->content;
						$eval_line =~ s/(?:'|"|{|})//g;
						my @eval_includes = split /;/, $eval_line;

						foreach my $eval_include (@eval_includes) {

							$self->_mod_ver(\@modules, \@version_strings, $eval_include);

						}
					}
				}

				foreach my $element_block (@hunkdata) {
					if ($element_block->isa('PPI::Structure::Block')) {

						my @children = $element_block->children;

						foreach my $child_element (@children) {
							if ($child_element->isa('PPI::Statement::Include')) {

								my $eval_line = $child_element->content;
								my @eval_includes = split /;/, $eval_line;

								foreach my $eval_include (@eval_includes) {

									$self->_mod_ver(\@modules, \@version_strings, $eval_include);

								}
							}
						}
					}
				}

			}
		}
	};


#######
# my $HAVE_MOOSE = eval { require Moose };
# # my $HAVE_MOOSE = eval '|" require Moose '|";
#######
	try {
		my @chunk2
			= map { [$_->schildren] }
			grep  { $_->child(6)->literal =~ m{\A(?:eval|try)\z} }
			grep  { $_->child(6)->isa('PPI::Token::Word') }
			@{$self->ppi_document->find('PPI::Statement::Variable') || []};

		foreach my $hunk2 (@chunk2) {

			if (
				grep {
					     $_->isa('PPI::Token::Quote::Double')
						|| $_->isa('PPI::Token::Quote::Single')
						|| $_->isa('PPI::Structure::Block')
				} @$hunk2
				)
			{

				# hack for List
				my @hunkdata = @$hunk2;
				foreach my $element (@hunkdata) {
					if ( $element->isa('PPI::Token::Quote::Double')
						|| $element->isa('PPI::Token::Quote::Single'))
					{

						my $eval_line = $element->content;
						$eval_line =~ s/(?:'|"|{|})//g;
						my @eval_includes = split /;/, $eval_line;

						foreach my $eval_include (@eval_includes) {

							$self->_mod_ver(\@modules, \@version_strings, $eval_include);
						}
					}
				}

				foreach my $element_block (@hunkdata) {
					if ($element_block->isa('PPI::Structure::Block')) {

						my @children = $element_block->children;

						foreach my $child_element (@children) {
							if ($child_element->isa('PPI::Statement::Include')) {

								my $eval_line = $child_element->content;
								my @eval_includes = split /;/, $eval_line;

								foreach my $eval_include (@eval_includes) {

									$self->_mod_ver(\@modules, \@version_strings, $eval_include);
								}
							}
						}
					}
				}

			}
		}
	};


	p @modules         if $self->debug;
	p @version_strings if $self->debug;

	# if we found a module, process it with the correct catogery
	if (scalar @modules > 0) {

		if ($self->format =~ /cpanfile|metajson/) {

			if ($self->xtest eq 'test_requires') {
				$self->_process_found_modules('recommends', \@modules);
			}
			elsif ($self->develop && $self->xtest eq 'test_develop') {
				$self->_process_found_modules('test_develop', \@modules);
			}
		}
		else {
			$self->_process_found_modules('recommends', \@modules);
		}
	}

	return;
}


#######
# composed Method
#######
sub _mod_ver {
	my ($self, $modules, $version_strings, $eval_include) = @_;

	if ($eval_include =~ /^\s*[use|require|no]/) {

		$eval_include =~ s/^\s*(?:use|require|no)\s*//;

		my $module_name = $eval_include;

		$module_name =~ s/(?:\s[\s|\w|\n|.|;]+)$//;
		$module_name =~ s/\s+(?:[\$|\w|\n]+)$//;
		$module_name =~ s/\s+$//;

		# check for first char upper in module name
		push @{$modules}, $module_name if $module_name =~ m/\A(?:[A-Z])/;

		my $version_number = $eval_include;
		$version_number =~ s/$module_name\s*//;
		$version_number =~ s/\s*$//;
		$version_number =~ s/[A-Z_a-z]|\s|\$|s|:|;//g;

		try {
			version->parse($version_number)->is_lax;
		}
		catch {
			$version_number = 0 if $_;
		};
		$self->{found_version}{$module_name} = $version_number;
	}

	return;
}

no Moo::Role;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Roles::Eval - used by L<App::Midgen>

=head1 VERSION

This document describes App::Midgen::Roles version: 0.27_09

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

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
