use Test::Tester;
use Test::More tests =>8;
use Test::WWW::Simple;

my ($message1, $message2, $message3);
my @results;

# look for perl on perl.org - should succeed
@results = run_tests(
    sub {
          text_like('http://perl.org', qr/Perl 5, Perl 6, Parrot, bugs/, "page match")
    }
  );
ok($results[1]->{ok}, 'text_like ok as expected');
is($results[1]->{diag}, '', 'no diagnostic');

# 2. Page not like the regex
$message1 = qr|         got: "The Perl Directory - perl.orgThe Perl Directory at"...\n|;
$message2 = qr|      length: \d+\n|;
$message3 = qr|    doesn't match '\(\?-xism:Python\)'\n|;

@results = run_tests(
    sub {
        text_like('http://perl.org', qr/Python/, "python found on perl.org")
    },
  );
like($results[1]->{diag}, qr/$message1$message2$message3/, 'message about right');
ok(!$results[1]->{ok}, 'failed as expected');

# 3. invalid server
@results = run_tests(
    sub {
        text_like("http://switch-to-python.perl.org", 
                  qr/500 Can't connect to switch-to-python.perl.org:80 /,
                  "this server doesn't exist")
    },
  );
is($results[1]->{diag}, '', "match skipped");
ok(!$results[1]->{ok}, 'worked as expected');


# 4. bad page
@results = run_tests(
    sub {
        text_like("http://perl.org/gack", 
                  qr/Error 404 - Error 404404 - File not foundSorry, we/,
                  "this page doesn't exist")
    },
    {
      ok => 0 # no such page should be a failure
    }
  );
is($results[1]->{diag}, '', "match skipped");
ok(!$results[1]->{ok}, "worked as expected");
