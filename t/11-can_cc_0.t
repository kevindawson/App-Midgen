use strict;
use warnings FATAL => 'all';

use English qw( -no_match_vars );
local $OUTPUT_AUTOFLUSH = 1;

use Test::More;
use Test::Requires {'Class::XSAccessor' => 1.18};
ok($Class::XSAccessor::VERSION >= 1.18, 'Class::XSAccessor is loaded');


done_testing();

__END__
