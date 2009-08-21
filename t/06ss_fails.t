#!/usr/local/bin/perl
use Test::More tests=>18;

@output = `examples/simple_scan<examples/ss_fail.in 2>tmp.out`;
@expected = map {"$_\n"} split /\n/,<<EOF;
1..4
not ok 1 - No python on perl.org
not ok 2 - No perl on python.org
not ok 3 - Python on python.org
not ok 4 - Perl on perl.org
EOF
is_deeply(\@output, \@expected, "failed STDOUT as expected");

open(PRODUCED_STDERR, "tmp.out") or die "Can't open saved STDERR: $!\n";
@output = <PRODUCED_STDERR>;
@expected = map {"$_\n"} split /\n/, <<EOF;
#     Failed test (/home/y/lib/perl5/site_perl/5.6.1/Test/WWW/Simple.pm at line 32)
#          got: "\x{0a}<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Tran"...
#       length: 8294
#     doesn't match '(?-xism:python)'
#     Failed test (/home/y/lib/perl5/site_perl/5.6.1/Test/WWW/Simple.pm at line 32)
#          got: "<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Trans"...
#       length: 11516
#     doesn't match '(?-xism:perl)'
#     Failed test (/home/y/lib/perl5/site_perl/5.6.1/Test/WWW/Simple.pm at line 37)
#          got: "<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Trans"...
#       length: 11516
#           matches '(?-xism:python)'
#     Failed test (/home/y/lib/perl5/site_perl/5.6.1/Test/WWW/Simple.pm at line 37)
#          got: "\x{0a}<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Tran"...
#       length: 8256
#           matches '(?-xism:perl)'
# Looks like you failed 4 tests of 4.
EOF

is($expected[-1], $output[-1], "summary right");
for (0, 4, 8, 12) {
  like($output[$_], qr/Failed test \(.* at line \d+\)/, "'Failed' right");
  like($output[$_+1], qr/got: /, "'got:' right");
  like($output[$_+2], qr/length: /, "'length: ' right");
}

for (3, 7) {
  like($output[$_], qr/doesn't match '\(\?-xism:/, "'doesn't match' ok");
}

for (11, 15) {
  like($output[$_], qr/ matches '\(\?-xism:/, "'matches' ok");
}
unlink "tmp.out";
