package App::Midgen::Role::TestRequires;

use v5.10;
use Moo::Role;
requires qw( ppi_document develop debug format xtest _process_found_modules );

use PPI;

use version 0.9902;
use Try::Tiny 0.12;
use Data::Printer {caller_info => 1, colored => 1,};

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.27_09';
use constant {BLANK => q{ }, NONE => q{}, TWO => 2, THREE => 3,};


#######
# composed method - xtests_test_requires
#######
sub xtests_test_requires {
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

	try {
		my @chunks
			= @{$self->ppi_document->find('PPI::Statement::Include') || []};

		foreach my $hunk (@chunks) {

			# test for use
			if (
				$hunk->find(
					sub {
						$_[1]->isa('PPI::Token::Word')
							and $_[1]->content =~ m{\A(?:use)\z};
					}
				)
				)
			{

				# test for Test::Requires
				if (
					$hunk->find(
						sub {
							$_[1]->isa('PPI::Token::Word')
								and $_[1]->content =~ m{\A(?:Test::Requires)\z};
						}
					)
					)
				{

					foreach ( 0 .. $#{$hunk->{children}}) {

						# looking for use Test::Requires { 'Test::Pod' => '1.46' };
						if ($hunk->{children}[$_]->isa('PPI::Structure::Constructor')) {

							my $ppi_sc = $hunk->{children}[$_]
								if $hunk->{children}[$_]->isa('PPI::Structure::Constructor');

							foreach ( 0 .. $#{$ppi_sc->{children}}) {

								if ($ppi_sc->{children}[$_]->isa('PPI::Statement')) {

									my $ppi_s = $ppi_sc->{children}[$_]
										if $ppi_sc->{children}[$_]->isa('PPI::Statement');

									foreach my $element (@{$ppi_s->{children}}) {

										# extract module name
										if ( $element->isa('PPI::Token::Quote::Double')
											|| $element->isa('PPI::Token::Quote::Single')
											|| $element->isa('PPI::Token::Word'))
										{
											my $module_name = $element->content;
											$module_name =~ s/(?:'|")//g;
											if ($module_name =~ m/\A(?:[A-Z])/) {
												warn 'found module - ' . $module_name if $self->debug;
												push @modules, $module_name;
											}

#										push @modules, $module_name
#											if $module_name =~ m/\A(?:[A-Z])/;
										}

										# extract version string
										if ( $element->isa('PPI::Token::Number::Float')
											|| $element->isa('PPI::Token::Quote::Double')
											|| $element->isa('PPI::Token::Quote::Single'))
										{
											my $version_number = $element->content;
											$version_number =~ s/(?:'|")//g;
											if ($version_number =~ m/\A(?:[0-9])/) {

												try {
													version->parse($version_number)->is_lax;
												}
												catch {
													$version_number = 0 if $_;
												};
												warn 'found version string - ' . $version_number
													if $self->debug;
												$self->{found_version}{$modules[$#modules]}
													= $version_number;
											}
										}
									}
								}
							}
						}

						# looking for use Test::Requires qw(MIME::Types);
						if ($hunk->{children}[$_]->isa('PPI::Token::QuoteLike::Words')) {

							my $ppi_tqw = $hunk->{children}[$_]
								if $hunk->{children}[$_]->isa('PPI::Token::QuoteLike::Words');

							my $operator = $ppi_tqw->{operator};
							my @type = split(//, $ppi_tqw->{sections}->[0]->{type});

							my $module = $ppi_tqw->{content};
							$module =~ s/$operator//;
							my $type_open = '\A\\' . $type[0];

							$module =~ s{$type_open}{};
							my $type_close = '\\' . $type[1] . '\Z';

							$module =~ s{$type_close}{};
							push @modules, split(BLANK, $module);

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

no Moo::Role;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Role::TestRequires - extra checks for test files, looking
for methods in use L<Test::Requires> blocks, used by L<App::Midgen>

=head1 VERSION

version: 0.27_09

=head1 METHODS

=over 4

=item * xtests_test_requires

Checking for the following, extracting module name only.

 use Test::Requires { 'Test::Pod' => 1.46 };
 use Test::Requires { 'Test::Extra' => 1.46 };
 use Test::Requires qw[MIME::Types];
 use Test::Requires qw(IO::Handle::Util LWP::Protocol::http10);
 use Test::Requires {
   "Test::Test1" => '1.01',
   'Test::Test2' => 2.02,
 };

Used to check files in t/ and xt/ directories.

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
