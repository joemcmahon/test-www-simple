use Test::Tester;
use Test::More tests =>8;
use Test::WWW::Simple;

my $message;
my @results;

# look for perl on perl.org - should succeed
@results = run_tests(
    sub {
          page_like('http://perl.org', qr/The Perl Directory/, "page match")
    }
  );
ok($results[1]->{ok}, 'page_like ok as expected');
is($results[1]->{diag}, '', 'no diagnostic');

# 2. Page not like the regex
$message = <<EOF;
         got: \Q"<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Trans"...\E
      length: \\d+
    doesn't match \Q'(?-xism:Perl)'\E
EOF

@results = run_tests(
    sub {
        page_like('http://python.org', qr/Perl/, "Perl found on python.org")
    },
  );
like($results[1]->{diag}, qr/$message/, 'message about right');
ok(!$results[1]->{ok}, 'failed as expected');

# 3. invalid server
@results = run_tests(
    sub {
        page_like("http://switch-to-python.perl.org", 
                  qr/text not there/,
                  "this server doesn't exist")
    },
  );
is($results[1]->{diag}, undef, "match skipped");
ok(!$results[1]->{ok}, 'failed as expected');


# 4. bad page
@results = run_tests(
    sub {
        page_like("http://perl.org/gack", 
                  qr/text not there/,
                  "this server doesn't exist")
    },
    {
      ok => 0 # no such page should be a failure
    }
  );
is($results[1]->{diag}, undef, "match skipped");
ok(!$results[1]->{ok}, "failed as expected");
