#!/usr/bin/env perl
use Mojolicious::Lite;
use Modern::Perl '2011';
use utf8;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';


=head1 GET Index
This displays a help page, since we are really an API server.
=cut
get '/' => sub {
    my $self = shift;

    $self->render('help');
};


=head1 POST Spellcheck
POST a block of plain text to be spellchecked.
=cut
post 'spellcheck' => sub {
    # an instance of Mojolicious::Lite (or, Mojolicious::Controller?)
    my $self = shift;

    # format should be only plain text, not JSON nor YAML nor even HTML yet.
    my $text = $self->req->body_params->param('text');
        # ... and not $self->param(''); since we don't want to also pick up
        # 'text' from GET requests via URL hacking.

    ## Deal with charsets...



    ## Validate that its English



    ## Run the spellchecker




    $self->render(text => '');
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
    <head>
        <title><%= title %></title>
    </head>
    <body>
        <%= content %>
    </body>
</html>
