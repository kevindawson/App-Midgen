package App::Midgen::Role::UseModule;

use v5.10;
use Moo::Role;
requires qw( ppi_document debug format xtest _process_found_modules develop );

use PPI;

use version 0.9902;
use Data::Printer;    # caller_info => 1;
use Try::Tiny;

our $VERSION = '0.27_07';
use constant {BLANK => q{ }, TRUE => 1, FALSE => 0, NONE => q{}, TWO => 2,
	THREE => 3,};


#######
# composed method - _xtests_in_single_quote
#######
sub xtests_use_module {
	my $self = shift;
	my @modules;
	my @version_strings;


# bug out if there is no Include for Module::Runtime found
	return if $self->_is_module_runtime() eq FALSE;

##	say 'Option 1: use_module( M::N )...';

#
# use_module("Math::BigInt", 1.31)->new("1_234");
#
#PPI::Document
#  PPI::Statement
#	 PPI::Token::Whitespace  	' '
#    PPI::Token::Word  	'use_module'
#    PPI::Structure::List  	( ... )
#      PPI::Statement::Expression
#        PPI::Token::Quote::Double  	'"Math::BigInt"'
#        PPI::Token::Operator  	','
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Number::Float  	'1.31'
#    PPI::Token::Operator  	'->'
#    PPI::Token::Word  	'new'
#    PPI::Structure::List  	( ... )
#      PPI::Statement::Expression
#        PPI::Token::Quote::Double  	'"1_234"'
#    PPI::Token::Structure  	';'
#  PPI::Token::Whitespace  	'\n'

	try {
		my @chunks1 = @{$self->ppi_document->find('PPI::Statement')};

		foreach my $chunk (@chunks1) {

			if (not $chunk->find(sub { $_[1]->isa('PPI::Token::Symbol') })) {

				# test for module-runtime key-words
				if (
					$chunk->find(
						sub {
							$_[1]->isa('PPI::Token::Word')
								and $_[1]->content
								=~ m{\A(?:use_module|use_package_optimistically|require_module)\z};
						}
					)
					)
				{
					if (
						not $chunk->find(
							sub {
								$_[1]->isa('PPI::Token::Word')
									and $_[1]->content =~ m{\A(?:return)\z};
							}
						)
						)
					{

						for ( 0..$#{$chunk->{children}}) {

							# find all ppi_sl
							if ($chunk->{children}[$_]->isa('PPI::Structure::List')) {

								my $ppi_sl = $chunk->{children}[$_]
									if $chunk->{children}[$_]->isa('PPI::Structure::List');

								say 'Option 1: use_module( M::N )...' if $self->debug;
								$self->_module_names_ppi_sl(\@modules, $ppi_sl);
							}
						}
					}
				}
			}
		}
	};


##	say 'Option 2: my $q = use_module( M::N )...';


#
# my $bi = use_module("Math::BigInt", 1.31)->new("1_234");
#
#PPI::Document
#  PPI::Statement::Variable
#    PPI::Token::Word  	'my'
#    PPI::Token::Whitespace  	' '
#    PPI::Token::Symbol  	'$bi'
#    PPI::Token::Whitespace  	' '
#    PPI::Token::Operator  	'='
#    PPI::Token::Whitespace  	' '
#    PPI::Token::Word  	'use_module'
#    PPI::Structure::List  	( ... )
#      PPI::Statement::Expression
#        PPI::Token::Quote::Double  	'"Math::BigInt"'
#        PPI::Token::Operator  	','
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Number::Float  	'1.31'
#    PPI::Token::Operator  	'->'
#    PPI::Token::Word  	'new'
#    PPI::Structure::List  	( ... )
#      PPI::Statement::Expression
#        PPI::Token::Quote::Double  	'"1_234"'
#    PPI::Token::Structure  	';'
#  PPI::Token::Whitespace  	'\n'


	try {
		# let's extract all ppi_sv
		my @chunks2 = @{$self->ppi_document->find('PPI::Statement::Variable')};
		foreach my $chunk (@chunks2) {

			# test for my
			if (
				$chunk->find(
					sub {
						$_[1]->isa('PPI::Token::Word')
							and $_[1]->content =~ m{\A(?:my)\z};
					}
				)
				)
			{
				# test for module-runtime key-words
				if (
					$chunk->find(
						sub {
							$_[1]->isa('PPI::Token::Word')
								and $_[1]->content
								=~ m{\A(?:use_module|use_package_optimistically)\z};
						}
					)
					)
				{
					for ( 0..$#{$chunk->{children}}) {

						# find all ppi_sl
						if ($chunk->{children}[$_]->isa('PPI::Structure::List')) {

							my $ppi_sl = $chunk->{children}[$_]
								if $chunk->{children}[$_]->isa('PPI::Structure::List');

							say
								'Option 2: my $q = use_module( M::N )...' if $self->debug;
							$self->_module_names_ppi_sl(\@modules, $ppi_sl);

						}
					}
				}
			}
		}
	};


##	say 'Option 3: $q = use_module( M::N )...';

#
# $bi = use_module("Math::BigInt", 1.31)->new("1_234");
#
#PPI::Document
#  PPI::Statement
#    PPI::Token::Symbol  	'$bi'
#    PPI::Token::Whitespace  	' '
#    PPI::Token::Operator  	'='
#    PPI::Token::Whitespace  	' '
#    PPI::Token::Word  	'use_module'
#    PPI::Structure::List  	( ... )
#      PPI::Statement::Expression
#        PPI::Token::Quote::Double  	'"Math::BigInt"'
#        PPI::Token::Operator  	','
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Number::Float  	'1.31'
#    PPI::Token::Operator  	'->'
#    PPI::Token::Word  	'new'
#    PPI::Structure::List  	( ... )
#      PPI::Statement::Expression
#        PPI::Token::Quote::Double  	'"1_234"'
#    PPI::Token::Structure  	';'
#  PPI::Token::Whitespace  	'\n'

	try {
		my @chunks1 = @{$self->ppi_document->find('PPI::Statement')};

		foreach my $chunk (@chunks1) {

			# test for not my
			if (
				not $chunk->find(
					sub {
						$_[1]->isa('PPI::Token::Word')
							and $_[1]->content =~ m{\A(?:my)\z};
					}
				)
				)
			{

				if ($chunk->find(sub { $_[1]->isa('PPI::Token::Symbol') })) {

					if (
						$chunk->find(
							sub {
								$_[1]->isa('PPI::Token::Operator') and $_[1]->content eq '=';
							}
						)
						)
					{

						# test for module-runtime key-words
						if (
							$chunk->find(
								sub {
									$_[1]->isa('PPI::Token::Word')
										and $_[1]->content
										=~ m{\A(?:use_module|use_package_optimistically)\z};
								}
							)
							)
						{
							for ( 0..$#{$chunk->{children}}) {

								# find all ppi_sl
								if ($chunk->{children}[$_]->isa('PPI::Structure::List')) {

									my $ppi_sl = $chunk->{children}[$_]
										if $chunk->{children}[$_]->isa('PPI::Structure::List');

									say
										'Option 3: $q = use_module( M::N )...' if $self->debug;
									$self->_module_names_ppi_sl(\@modules, $ppi_sl);
								}
							}
						}
					}
				}
			}
		}
	};


##	say 'Option 4: return use_module( M::N )...';

#
# return use_module(\'App::SCS::PageSet\')->new(
# base_dir => $self->share_dir->catdir(\'pages\'),
# plugin_config => $self->page_plugin_config,
# );
#
#PPI::Document
#  PPI::Statement::Break
#    PPI::Token::Word  	'return'
#    PPI::Token::Whitespace  	' '
#    PPI::Token::Word  	'use_module'
#    PPI::Structure::List  	( ... )
#      PPI::Statement::Expression
#        PPI::Token::Quote::Single  	''App::SCS::PageSet''
#    PPI::Token::Operator  	'->'
#    PPI::Token::Word  	'new'
#    PPI::Structure::List  	( ... )
#      PPI::Token::Whitespace  	'\n'
#      PPI::Token::Whitespace  	'    '
#      PPI::Statement::Expression
#        PPI::Token::Word  	'base_dir'
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Operator  	'=>'
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Symbol  	'$self'
#        PPI::Token::Operator  	'->'
#        PPI::Token::Word  	'share_dir'
#        PPI::Token::Operator  	'->'
#        PPI::Token::Word  	'catdir'
#        PPI::Structure::List  	( ... )
#          PPI::Statement::Expression
#            PPI::Token::Quote::Single  	''pages''
#        PPI::Token::Operator  	','
#        PPI::Token::Whitespace  	'\n'
#        PPI::Token::Whitespace  	'    '
#        PPI::Token::Word  	'plugin_config'
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Operator  	'=>'
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Symbol  	'$self'
#        PPI::Token::Operator  	'->'
#        PPI::Token::Word  	'page_plugin_config'
#        PPI::Token::Operator  	','
#      PPI::Token::Whitespace  	'\n'
#      PPI::Token::Whitespace  	'  '
#    PPI::Token::Structure  	';'

	try {
		my @chunks4 = @{$self->ppi_document->find('PPI::Statement::Break')};

		for my $chunk (@chunks4) {

			if (
				$chunk->find(
					sub {
						$_[1]->isa('PPI::Token::Word')
							and $_[1]->content =~ m{\A(?:return)\z};
					}
				)
				)
			{

				if (
					$chunk->find(
						sub {
							$_[1]->isa('PPI::Token::Word')
								and $_[1]->content
								=~ m{\A(?:use_module|use_package_optimistically)\z};
						}
					)
					)
				{
					for ( 0..$#{$chunk->{children}}) {

						# find all ppi_sl
						if ($chunk->{children}[$_]->isa('PPI::Structure::List')) {
							my $ppi_sl = $chunk->{children}[$_]
								if $chunk->{children}[$_]->isa('PPI::Structure::List');
							say 'Option 4: return use_module( M::N )...' if $self->debug;
							$self->_module_names_ppi_sl(\@modules, $ppi_sl);

						}
					}
				}
			}
		}
	};

	p @modules if $self->debug;
	p @version_strings if $self->debug;

	# if we found a module, process it with the correct catogery
	if (scalar @modules > 0) {
		$self->_process_found_modules('package_requires', \@modules);
	}
	return;
}


#######
# composed method test for include Module::Runtime
#######
sub _is_module_runtime {
	my $self                         = shift;
	my $module_runtime_include_found = FALSE;

#PPI::Document
#  PPI::Statement::Include
#    PPI::Token::Word  	'use'
#    PPI::Token::Whitespace  	' '
#    PPI::Token::Word  	'Module::Runtime'

	try {
		my $includes = $self->ppi_document->find('PPI::Statement::Include');
		if ($includes) {
			foreach my $include (@{$includes}) {
				next if $include->type eq 'no';
				if (not $include->pragma) {
					my $module = $include->module;

					if ($module eq 'Module::Runtime') {
						$module_runtime_include_found = TRUE;
						p $module if $self->debug;
					}
				}
			}
		}
	};
	p $module_runtime_include_found if $self->debug;
	return $module_runtime_include_found;

}


#######
# composed method extract module name from PPI::Structure::List
#######
sub _module_names_ppi_sl {
	my ($self, $modules, $ppi_sl) = @_;


	if ($ppi_sl->isa('PPI::Structure::List')) {

#		p $ppi_sl;
		state $previous_module = undef;
		foreach my $ppi_se (@{$ppi_sl->{children}}) {
			for ( 0..$#{$ppi_se->{children}}) {

#p $ppi_se->{children}[$_];
				if ( $ppi_se->{children}[$_]->isa('PPI::Token::Quote::Single')
					|| $ppi_se->{children}[$_]->isa('PPI::Token::Quote::Double'))
				{
					my $module = $ppi_se->{children}[$_]->content;
					$module =~ s/(?:['|"])//g;
					if ($module =~ m/\A[A-Z]/) {
						warn 'found module - ' . $module if $self->debug;
						push @$modules, $module;
#						p $module;
						p @$modules if $self->debug;
						$previous_module = $module;
					}
				}
				if ( $ppi_se->{children}[$_]->isa('PPI::Token::Number::Float')
					|| $ppi_se->{children}[$_]->isa('PPI::Token::Number::Version')
					|| $ppi_se->{children}[$_]->isa('PPI::Token::Quote::Single')
					|| $ppi_se->{children}[$_]->isa('PPI::Token::Quote::Double'))
				{
					my $version_string = $ppi_se->{children}[$_]->content;
					$version_string =~ s/(?:['|"])//g;
					next if $version_string !~ m/\A[\d|v]/;


					try {
						version->parse($version_string)->is_lax;
					}
					catch {
						$version_string = 0 if $_;
					};

					warn 'found version_string - ' . $version_string if $self->debug;
					try {
						$self->{found_version}{$previous_module}
							= $version_string if $previous_module;
#						p $version_string;
						$previous_module = undef;
					};
				}
			}
		}
	}


}


no Moo::Role;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Midgen::Roles::UseModule - extra checks for test files, looking
for methods in use_ok in BEGIN blocks, used by L<App::Midgen>

=head1 VERSION

version: 0.27_07

=head1 DESCRIPTION

This scanner will look for the following formats or variations there in,
inside BEGIN blocks in test files:

=begin :list

* use_module( 'Fred::BloggsOne', '1.01' );

* use_module( "Fred::BloggsTwo", "2.02" );

* use_module( 'Fred::BloggsThree', 3.03 );

=end :list

=head1 METHODS

=over 4

=item * xtests_use_module 

Checking for the following, extracting module name only.

 BEGIN {
   use_ok( 'Term::ReadKey', '2.30' );
   use_ok( 'Term::ReadLine', '1.10' );
   use_ok( 'Fred::BloggsOne', '1.01' );
   use_ok( "Fred::BloggsTwo", "2.02" );
   use_ok( 'Fred::BloggsThree', 3.03 );
 }

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
