#!/usr/bin/env perl
use Mojolicious::Lite;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

=head1 GET Index
This displays a help page, since we are really an API server.
=cut
get '/' => sub {
  my $self = shift;

  $self->render('help');
};

app->start;
__DATA__

@@ help.html.ep
% layout 'default';
% title 'Help';
This application is only meant to be accessed via

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
