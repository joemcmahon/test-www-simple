package Test::WWW::Simple;

use 5.6.1;
use strict;
use warnings;

our $VERSION = '0.06';

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
    *{$caller.'::user_agent'}  = \&user_agent;

    $Test->exported_to($caller);
    $Test->plan(@_);

    # Default user agent is IE 6, but it can be switched with user_agent().
    $Mech->agent_alias('Windows IE 6');
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

sub user_agent {
   my $agent = shift || 'WWW-Mechanize';
   $Mech->agent_alias($agent);
}    

1;

__END__

=head1 NAME

Test::WWW::Simple - Test Web applications using TAP

=head1 SYNOPSIS

  use Test::WWW::Simple;
  # This is the default user agent.
  user_agent('Windows IE 6');
  page_like("http://yahoo.com",      qr/.../, "check for expected text");
  page_unlike("http://my.yahoo.com", qr/.../, "check for undesirable text");
  user_agent('Mac Safari');
  ...

=head1 DESCRIPTION

C<Test::WWW::Simple> is a very basic class for testing Web applications and 
Web pages. It uses L<WWW::Mechanize> to fetch pages, and L<Test::Builder> to 
implement TAP (Test Anything Protocol) for the actual testing.

Since we use L<Test::Builder> for the C<like> and C<unlike> routines, these
can be integrated with the other standard L<Test::Builder>-based modules
as just more tests.

=head1 SEE ALSO

L<WWW::Mechanize> for a description of how the simulated browser works; 
L<Test::Builder> to see how a test module works.

You may also want to look at L<Test::WWW::Mechanize> if you want to write 
more precise tests ("is the title of this page like the pattern?" or
"are all the page links ok?").

=head1 AUTHOR

Joe McMahon, E<lt>mcmahon@yahoo-inc.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Yahoo!

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.6.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
