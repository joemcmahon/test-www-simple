package Test::WWW::Simple;

use 5.6.1;
use strict;
use warnings;

our $VERSION = '0.02';

use Test::Builder;
use Test::LongString;
use Test::More;
use WWW::Mechanize;

my $Test = Test::Builder->new;  # The Test:: singleton
my $Mech = WWW::Mechanize->new; # The Mech user agent and support methods

$Test::WWW::display_length = 40; # length for display in error messages

sub import {
    my $self = shift;
    my $caller = caller;
    no strict 'refs';
    *{$caller.'::page_like'}   = \&page_like;
    *{$caller.'::page_unlike'} = \&page_unlike;

    $Test->exported_to($caller);
    $Test->plan(@_);
}

sub page_like($$;$) {
    my($url, $regex, $comment) = @_;
    _fetch($url) and like_string($Mech->content, $regex, $comment);
}

sub page_unlike($$;$) {
    my($url, $regex, $comment) = @_;
    _fetch($url) and unlike_string($Mech->content, $regex, $comment);
}

sub _fetch {
    my ($url, $comment) = @_;
    local $Test::Builder::Level = 2;
    $Mech->get($url);
    $Mech->success or 
        $Test->diag("Fetch of @{[_trimmed_url($url)]} failed: @{[$Mech->response->status_line]}");
}

sub _trimmed_url {
    my $url = shift;
    length($url) > $Test::WWW::display_length 
       ? substr($url,0,$Test::WWW::display_length) . "..."
       : $url;
}
    
1;
__END__

=head1 NAME

Test::WWW::Simple - Test Web applications using TAP

=head1 SYNOPSIS

  use Test::WWW::Simple;
  page_like("http://yahoo.com",      qr/.../, "check for expected text");
  page_unlike("http://my.yahoo.com", qr/.../, "check for undesirable text");

=head1 DESCRIPTION

C<Test::WWW::Simple> is a very basic class for testing Web applications and Web pages. It uses
L<WWW::Mechanize> to fetch pages, and L<Test::Builder> to implement the TAP
(Test Anything Protocol) for the actual testing.

Since we use L<Test::Builder> for the C<like> and C<unlike> routines, these
can be integrated with the other standard L<Test::Builder>-based modules
as just more tests.

=head1 SEE ALSO

L<WWW::Mechanize> for a description of how the simulated browser works; 
L<Test::Builder> to see how a test module works.

=head1 AUTHOR

Joe McMahon, E<lt>mcmahon@yahoo-inc.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Yahoo!

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.6.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
