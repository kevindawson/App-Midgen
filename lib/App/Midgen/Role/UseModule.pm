package App::Midgen::Role::UseModule;

use v5.10;
use Moo::Role;
requires qw( ppi_document debug format xtest _process_found_modules develop );

use PPI;
use Data::Printer;    # caller_info => 1;
use Try::Tiny;

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
		my @chunks1 =

			map { [$_->schildren] } grep {
			$_->{children}[0]->content
				=~ m{\A(?:use_module|use_package_optimistically|require_module)\z}
			} grep { $_->child(0)->isa('PPI::Token::Word') }

			@{$self->ppi_document->find('PPI::Statement') || []};

		if (@chunks1) {
			say 'Option 1: use_module( M::N )...';

#	p @chunks1;
			push @modules, $self->_module_names_psi(@chunks1);
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
p @chunks2;
		foreach my $chunk (@chunks2) {
p $chunk;
			# test for my
			if (
				$chunk->find(
					sub {
p $_[1];
						$_[1]->isa('PPI::Token::Word')
							and $_[1]->content =~ m{\A(?:my)\z};
					}
				)
				)
			{
				# test for module-runtime key-word
				if (
					$chunk->find(
						sub {
p $_[1];
							$_[1]->isa('PPI::Token::Word')
								and $_[1]->content
								=~ m{\A(?:use_module|use_package_optimistically)\z};
						}
					)
					)
				{
p $chunk;
					foreach (keys $chunk->{children}) {

						# find all ppi_sl
						if ($chunk->{children}[$_]->isa('PPI::Structure::List')) {

							my $ppi_sl = $chunk->{children}[$_]
								if $chunk->{children}[$_]->isa('PPI::Structure::List');

							foreach my $ppi_se (@{$ppi_sl->{children}}) {
p $ppi_se;



#								if ($ppi_se->isa('PPI::Statement::Expression')) {
#
#									foreach my $element (@{$ppi_se->{children}}) {
#											my $module = $element->string;
#											if ($module =~ m/\A[A-Z]/) {
#												push @modules, $module;
#												p @modules if $self->debug;
#											}
#									}
#								}



								foreach (keys $ppi_se->{children}) {
p $ppi_se->{children}[$_];									
									if (
										$ppi_se->{children}[$_]->isa('PPI::Token::Quote::Single')
										|| $ppi_se->{children}[$_]
										->isa('PPI::Token::Quote::Double'))
									{

										my $module = $ppi_se->{children}[$_]->content;
										$module =~ s/^['|"]//;
										$module =~ s/['|"]$//;
										if ($module =~ m/\A[A-Z]/) {
											warn 'found module - ' . $module if $self->debug;
p $module;
											say 'Option 2: my $q = use_module( M::N )...';
											push @modules, $module;
										}

									}


									if (
										$ppi_se->{children}[$_]->isa('PPI::Token::Number::Float')
										|| $ppi_se->{children}[$_]
										->isa('PPI::Token::Quote::Single')
										|| $ppi_se->{children}[$_]
										->isa('PPI::Token::Quote::Double'))
									{
										my $version_string = $ppi_se->{children}[$_]->content;
										$version_string =~ s/^['|"]//;
										$version_string =~ s/['|"]$//;
										next if $version_string !~ m/\A[\d|v]/;
										if ($version_string =~ m/\A[\d|v]/) {

											push @version_strings, $version_string;
											say 'found version_string - '
												. $version_string;    # if $self->debug;
										}
									}
								}
							}
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
		my @chunks3 =

			map { [$_->schildren] }

			grep {
			$_->{children}[4]->content
				=~ m{\A(?:use_module|use_package_optimistically)\z}
			} grep { $_->child(4)->isa('PPI::Token::Word') }

			grep { $_->child(2)->content eq '=' }
			grep { $_->child(2)->isa('PPI::Token::Operator') }

			grep { $_->child(0)->isa('PPI::Token::Symbol') }

			@{$self->ppi_document->find('PPI::Statement') || []}
			;    # need for pps remove in midgen -> || {}

		if (@chunks3) {
			say 'Option 3: $q = use_module( M::N )...';

#	p @chunks3;
			push @modules, $self->_module_names_psi(@chunks3);
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

#					say 'Option 4: return use_module( M::N )...';

					foreach (keys $chunk->{children}) {

						# find all ppi_sl
						if ($chunk->{children}[$_]->isa('PPI::Structure::List')) {


							my $ppi_sl = $chunk->{children}[$_]
								if $chunk->{children}[$_]->isa('PPI::Structure::List');

#					p $ppi_sl;
							if ($ppi_sl->isa('PPI::Structure::List')) {

#						p $ppi_sl;
								foreach my $ppi_se (@{$ppi_sl->{children}}) {
									foreach (keys $ppi_se->{children}) {

#							p $ppi_se;
#							if ($ppi_se->isa('PPI::Statement::Expression')) {
#								foreach my $element (@{$ppi_se->{children}}) {
										if ($ppi_se->{children}[$_]
											->isa('PPI::Token::Quote::Single')
											|| $ppi_se->{children}[$_]
											->isa('PPI::Token::Quote::Double'))
										{
#										p $element;
#										p $element->content;
#										p $element->string;
											my $module = $ppi_se->{children}[$_]->content;
											$module =~ s/^['|"]//;
											$module =~ s/['|"]$//;
											if ($module =~ m/\A[A-Z]/) {
												warn 'found module - ' . $module if $self->debug;
												say 'Option 4: return use_module( M::N )...';
												push @modules, $module;
												p @modules if $self->debug;
											}
										}


										if ($ppi_se->{children}[$_]
											->isa('PPI::Token::Number::Float')
											|| $ppi_se->{children}[$_]
											->isa('PPI::Token::Quote::Single')
											|| $ppi_se->{children}[$_]
											->isa('PPI::Token::Quote::Double'))
										{
											my $version_string = $ppi_se->{children}[$_]->content;
											$version_string =~ s/^['|"]//;
											$version_string =~ s/['|"]$//;
											next if $version_string !~ m/\A[\d|v]/;
											if ($version_string =~ m/\A[\d|v]/) {

												push @version_strings, $version_string;
												say 'found version_string - '
													. $version_string;    # if $self->debug;
											}
										}

									}
								}

#						}
#}
							}    #
						}
					}
				}
			}
		}
	};


	p @modules;      #       if $self->debug;
	p @version_strings if $self->debug;

	# if we found a module, process it with the correct catogery
	if (scalar @modules > 0) {

#		if ( $self->format =~ /cpanfile|metajson/ ) {
#			if ( $self->xtest eq 'test_requires' ) {
#				$self->_process_found_modules( 'test_requires', \@modules );
#			} elsif ( $self->develop && $self->xtest eq 'test_develop' ) {
#				$self->_process_found_modules( 'test_develop', \@modules );
#			}
#		} else {
		$self->_process_found_modules('package_requires', \@modules);

#		}
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

#					p $module;
					if ($module eq 'Module::Runtime') {
						$module_runtime_include_found = TRUE;
						p $module;    # if $self->debug;
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
sub _module_names_psi {
	my $self   = shift;
	my @chunks = @_;
	my @modules_psl;

#	p @chunks;

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
		foreach my $hunk (@chunks) {

#			p $hunk;

			# looking for use Module::Runtime ...;
			if (grep { $_->isa('PPI::Structure::List') } @$hunk) {

#			say 'found Module::Runtime';

				# hack for List
				my @hunkdata = @$hunk;

				foreach my $ppi_sl (@hunkdata) {
					if ($ppi_sl->isa('PPI::Structure::List')) {

#					p $ppi_sl;
						foreach my $ppi_se (@{$ppi_sl->{children}}) {
							if ($ppi_se->isa('PPI::Statement::Expression')) {
								foreach my $element (@{$ppi_se->{children}}) {
									if ( $element->isa('PPI::Token::Quote::Single')
										|| $element->isa('PPI::Token::Quote::Double'))
									{
										my $module = $element;
										$module =~ s/^['|"]//;
										$module =~ s/['|"]$//;
										if ($module =~ m/\A[A-Z]/) {
											push @modules_psl, $module;
											p @modules_psl if $self->debug;
										}
									}

								}
							}
						}
					}
				}
			}
		}
	};

	return @modules_psl;

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

version: 0.26

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

=item * xtests_use_ok

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
