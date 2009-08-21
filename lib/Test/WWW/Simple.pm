package Test::WWW::Simple;

use 5.6.1;
use strict;
use warnings;

our $VERSION = '0.12';

use Test::Builder;
use Test::LongString;
use Test::More;
use WWW::Mechanize;

my $Test = Test::Builder->new;  # The Test:: singleton
my $Mech = WWW::Mechanize->new; # The Mech user agent and support methods
my $cache_results = 0;          # default to not caching Mech fetches
our $last_url;                  # last URL fetched successfully by Mech
my %page_cache;                 # saves pages for %%cache; we probably 
                                # will want to change this over to a
                                # tied hash later to allow for disk caching
                                # instead of just memory caching.
my %status_cache;               # ditto

$Test::WWW::display_length = 40; # length for display in error messages

sub import {
    my $self = shift;
    my $caller = caller;
    no strict 'refs';
    *{$caller.'::page_like'}   = \&page_like;
    *{$caller.'::page_unlike'} = \&page_unlike;
    *{$caller.'::user_agent'}  = \&user_agent;
    *{$caller.'::cache'}       = \&cache;
    *{$caller.'::no_cache'}    = \&no_cache;

    $Test->exported_to($caller);
    $Test->plan(@_);

    # Default user agent is IE 6, but it can be switched with user_agent().
    $Mech->agent_alias('Windows IE 6');
}

sub cache (;$) { 
  my $comment = shift;
  $Test->diag($comment) if defined $comment;
  $last_url = "";
  $cache_results = 1;
  1;
}

sub no_cache (;$) { 
  my $comment = shift;
  $Test->diag($comment) if defined $comment;
  $last_url = "";
  $cache_results = 0;
  1;
}


sub page_like($$;$) {
    my($url, $regex, $comment) = @_;
    my ($state, $content, $status_line) = _fetch($url);
    $state 
      ? like_string($content, $regex, $comment)
      : $Test->diag("Fetch of $url failed: ".$status_line);
}

sub page_unlike($$;$) {
    my($url, $regex, $comment) = @_;
    my ($state, $content, $status_line) = _fetch($url);
    $state 
      ? unlike_string($content, $regex, $comment)
      : $Test->diag("Fetch of $url failed: ".$status_line);
}

sub _fetch {
  my ($url, $comment) = @_;
  local $Test::Builder::Level = 2;
  my @results;

  if ($cache_results) {
    if (defined $page_cache{$url}) {
      # in cache: return it.
      @results = (1, $page_cache{$url}, $status_cache{$url});
    }
    elsif ($last_url eq $url) {
      # "cached" in Mech object
      @results = (1, 
              $page_cache{$url}   = $Mech->content,
              $status_cache{$url} = $Mech->response->status_line);
    }
    else {
      # not in cache - load and save the page (if any)
      $Mech->get($url);
      @results = ($Mech->success, 
              $page_cache{$url}   = $Mech->content,
              $status_cache{$url} = $Mech->response->status_line);
    }
  }
  else {
   # not caching. Just grab it.
   $Mech->get($url);
   @results = ($Mech->success, $Mech->content, $Mech->response->status_line);
  }
  $last_url = $_[0];
  $page_cache{$url}   = $results[1];
  $status_cache{$url} = $results[2];
  @results;
}

sub _trimmed_url {
    my $url = shift;
    length($url) > $Test::WWW::display_length 
       ? substr($url,0,$Test::WWW::display_length) . "..."
       : $url;
}

sub user_agent {
   my $agent = shift || "Windows IE 6";
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

The C<simlpe_scan> utility provided with this module demonstrates a
possible use of C<Test::WWW::Simple>; do a C<perldoc simple_scan> for
details on this program.

=head1 AUTHOR

Joe McMahon, E<lt>mcmahon@yahoo-inc.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Yahoo!

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.6.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
