#!/usr/local/bin/perl
use Test::More tests=>1;

@output = `examples/simple_scan<examples/ss.in`;
@expected = map {"$_\n"} split /\n/,<<EOF;
1..4
ok 1 - No python on perl.org [http://perl.org/]
ok 2 - No perl on python.org [http://python.org/]
ok 3 - Python on python.org [http://python.org/]
ok 4 - Perl on perl.org [http://perl.org/]
EOF
is_deeply(\@output, \@expected, "working output as expected");
