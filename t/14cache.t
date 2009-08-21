use Test::More;

eval "require HTTP::Daemon";
if( $@ ) {
    plan skip_all => 'HTTP::Daemon unavailable';
}
else {
    plan tests => 9;
}

use Test::WWW::Simple;

$SIG{PIPE} = sub {};

my $pid = fork;
if ($pid == 0) {
  my @values = qw(aaaaa bbbbb ccccc ddddd eeeee fffff ggggg);
  my $index = 0;
  diag "Starting test webserver";
  my $daemon = HTTP::Daemon->new(LocalPort=>9980, ReuseAddr=>1) 
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
  no_cache;
  page_like('http://localhost:9980', qr/aaaaa/, 'initial value as expected');
  page_like('http://localhost:9980', qr/bbbbb/, 'reaccessed as expected');
  cache;
  page_like('http://perl.org', qr/perl/i,   'intervening page');
  page_like('http://localhost:9980', qr/bbbbb/, 'cached from last get');
  page_like('http://localhost:9980', qr/bbbbb/, 'remains cached');
  no_cache "turned off again";
  page_like('http://localhost:9980', qr/ccccc/, 'reaccessed again as expected');
  page_like('http://perl.org', qr/perl/i,   'intervening page');
  cache "back on again";
  page_like('http://localhost:9980', qr/ccccc/, 'return to last cached value');
  no_cache;
  page_like('http://localhost:9980', qr/ddddd/, 'now a new value');
  
  diag "Shutting down test webserver";
  kill 9,$pid;
}
