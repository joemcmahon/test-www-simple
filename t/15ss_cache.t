#!/usr/local/bin/perl
use Test::More;

eval "require HTTP::Daemon";
if( $@ ) {
    plan skip_all => 'HTTP::Daemon unavailable';
}
else {
    plan tests => 1;
}

use Test::WWW::Simple;

$SIG{PIPE} = sub {};

my $pid = fork;

if ($pid == 0) {
  my @values = qw(aaaaa bbbbb ccccc ddddd eeeee fffff ggggg);
  my $index = 0;
  diag "Starting test webserver";
  my $daemon = HTTP::Daemon->new(LocalPort=>9981, ReuseAddr=>1) 
   || die "Bail out! Can't run daemon: $!";
  while (my $connection = $daemon->accept) {
    while (my $request = $connection->get_request) {
      $connection->send_response($values[$index]);
      $index++;
    }
    $connection ->close;
    undef $connection;
  }
}
else {
  diag "Waiting for test webserver to spin up";
  sleep 5;
  # actual tests go here
  @output = `perl -Iblib/lib examples/simple_scan<examples/ss_cache.in`;
  @expected = map {"$_\n"} split /\n/,<<EOF;
1..7
ok 1 - initial value OK [http://localhost:9981/]
ok 2 - reaccessed as expected [http://localhost:9981/]
ok 3 - cached from last get [http://localhost:9981/]
ok 4 - still cached [http://localhost:9981/]
ok 5 - reaccessed as expected [http://localhost:9981/]
ok 6 - return to last cached value [http://localhost:9981/]
ok 7 - now a new value [http://localhost:9981/]
EOF
  is_deeply(\@output, \@expected, "working output as expected");

  # shut down webserver
  diag "Shutting down test webserver";
  kill 9,$pid;
}
