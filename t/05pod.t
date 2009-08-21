use Test::More;
use Test::WWW::Simple;
plan skip_all => "Test::Pod::Coverage 1.08 required for testing POD coverage"
   unless eval "use Test::Pod::Coverage 1.08";
all_pod_coverage_ok();
