use strict;
use warnings FATAL => 'all';

use English qw( -no_match_vars );
local $OUTPUT_AUTOFLUSH = 1;

use Test::More;
use Test::Requires {'Perl::MinimumVersion::Fast' => 0.1};
ok($Perl::MinimumVersion::Fast::VERSION >= 0.1, 'Perl::MinimumVersion::Fast is loaded');


done_testing();

__END__
