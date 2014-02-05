package App::Midgen::Role::Eval;

use v5.10;
use Moo::Role;
requires qw( ppi_document debug format xtest _process_found_modules develop );

use version 0.9902;
use Try::Tiny 0.12;
use Data::Printer {caller_info => 1, colored => 1,};

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.27_13';
use English qw( -no_match_vars );    # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;


#######
# composed method - xtests_eval
#######
sub xtests_eval {
	my $self             = shift;
	my $storage_location = shift;

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
		my @chunks1 = @{$self->ppi_document->find('PPI::Statement')};
		foreach my $chunk (@chunks1) {
			if (
				$chunk->find(
					sub {
						$_[1]->isa('PPI::Token::Word')
							and $_[1]->content =~ m{\A(?:eval|try)\z};
					}
				)
				)
			{
				for (0 .. $#{$chunk->{children}}) {

					if ( $chunk->{children}[$_]->isa('PPI::Token::Quote::Double')
						|| $chunk->{children}[$_]->isa('PPI::Token::Quote::Single'))
					{
						my $eval_line = $chunk->{children}[$_]->content;

						$eval_line =~ s/(?:'|"|{|})//g;
						my @eval_includes = split /;/, $eval_line;

						foreach my $eval_include (@eval_includes) {

							$self->_mod_ver(\@modules, \@version_strings, $eval_include);
						}
					}

					if ($chunk->{children}[$_]->isa('PPI::Structure::Block')) {
						my @children = $chunk->{children}[$_]->children;

						foreach my $child_element (@children) {
							if ($child_element->isa('PPI::Statement::Include')) {

								my $eval_line = $child_element->content;
								my @eval_includes = split /;/, $eval_line;

								foreach my $eval_include (@eval_includes) {
									$self->_mod_ver(\@modules, \@version_strings,
										$eval_include);

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

		if ($storage_location eq 'runtime_recommends') {
			if ($self->format =~ /cpanfile|metajson/) {
				$self->_process_found_modules('runtime_recommends', \@modules);

			}
			else {
				$self->_process_found_modules('package_requires', \@modules);
			}

		}
		else {

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

=encoding UTF-8

=head1 NAME

App::Midgen::Roles::Eval - used by L<App::Midgen>

=head1 VERSION

This document describes App::Midgen::Roles version: 0.27_13

=head1 METHODS

=over 4

=item * xtests_eval

Checking for the following, extracting module name and version string.

  eval {use Test::Kwalitee::Extra 0.000007};
  eval {use Moo 1.002; 1;};
  eval { no Moose; 1; };
  eval { require Moose };
  my $HAVE_MOOSE = eval { require Moose; 1; };

  try { no Moose; 1; };
  try { require Moose };
  my $HAVE_MOOSE = try { require Moose; 1; };

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
