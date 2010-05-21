use Test::Tester;
use Test::More tests =>16;
use Test::WWW::Simple;

my ($message1, $message2, $message3);
my @results;

# look for perl on perl.org - should succeed
@results = run_tests(
    sub {
          page_like('http://perl.org', qr/The Perl Programming Language - www.perl.org/, "page match")
    }
  );
ok($results[1]->{ok}, 'page_like ok as expected');
is($results[1]->{diag}, '', 'no diagnostic');

# 2. Page not like the regex
$message1 = qr|\s+got: "<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Trans"...\n|;
$message2 = qr|\s+length: \d+\n|;
$message3 = qr|\s+doesn't match '\(\?-xism:Perl\)'\n|;

@results = run_tests(
    sub {
        page_like('http://python.org', qr/Perl/, "Perl found on python.org")
    },
  );
like($results[1]->{diag}, qr/$message1$message2$message3/, 'message about right');
ok(!$results[1]->{ok}, 'failed as expected');

# 3. invalid server
@results = run_tests(
    sub {
        page_like("http://switch-to-python.perl.org", 
                  qr/text not there/,
                  "this server doesn't exist")
    },
  );
is($results[1]->{diag}, '', "match skipped");
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
is($results[1]->{diag}, '', "match skipped");
ok(!$results[1]->{ok}, "failed as expected");

# look for perl on perl.org - should succeed
@results = run_tests(
    sub {
          page_like_full('http://perl.org', qr/The Perl Programming Language at Perl.org./, "page match")
    }
  );
ok($results[1]->{ok}, 'page_like ok as expected');
is($results[1]->{diag}, '', 'no diagnostic');

# 2. Page not like the regex
$message1 = qr|                  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">\n|;
$message2 = qr|.*?|s;
$message3 = qr|    doesn't match '\(\?-xism:Perl\)'$|;

@results = run_tests(
    sub {
        page_like_full('http://python.org', qr/Perl/, "Perl found on python.org")
    },
  );
like($results[1]->{diag}, qr/$message1$message2$message3/, 'message about right');
ok(!$results[1]->{ok}, 'failed as expected');

# 3. invalid server
@results = run_tests(
    sub {
        page_like_full("http://switch-to-python.perl.org",
                  qr/text not there/,
                  "this server doesn't exist")
    },
  );
is($results[1]->{diag}, '', "match skipped");
ok(!$results[1]->{ok}, 'failed as expected');


# 4. bad page
@results = run_tests(
    sub {
        page_like_full("http://perl.org/gack",
                  qr/text not there/,
                  "this server doesn't exist")
    },
    {
      ok => 0 # no such page should be a failure
    }
  );
is($results[1]->{diag}, '', "match skipped");
ok(!$results[1]->{ok}, "failed as expected");

