use Test::More tests => 2;
use Test::WWW::Simple;

# Test::WWW::Simple should have imported page_like and page_unlike

ok(defined \&page_like, "page_like imported");
ok(defined \&page_unlike, "page_unlike imported");

