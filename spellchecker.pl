#!/usr/bin/env perl
use Mojolicious::Lite;
use Modern::Perl '2011';
use Lingua::Identify qw(:language_identification);
use Text::Hunspell;
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
post '/api/v1/word/:word' => sub {
    # an instance of Mojolicious::Lite (or, Mojolicious::Controller?)
    my $self = shift;
    my $dict_path = '/usr/share/hunspell';

    # format should be only plain text, not JSON nor YAML nor even HTML yet.
    my $word = $self->param('word');

    ## Deal with charsets...


    ## Determine language
    # we won't rely on HTTP headers for locales: someone in a Spanish locale
    # may easily wish to spellcheck an English text, so check the text directly.
    my $lang = "en_US"; #langof($word) . "_US"; # hack!

    my $speller = Text::Hunspell->new(
        sprintf("%s/%s.aff", $dict_path, $lang), # Hunspell affix file
        sprintf("%s/%s.dic", $dict_path, $lang)  # Hunspell dictionary file
    ) or die "Speller could not start!";

    #strip punctuation before checking to prevent false errors.
    my $temp_word = $word =~ s/[[:punct:]]//r;

    # will be either 1 or 0 = found in dictionary or not
    my $correct = $speller->check($temp_word);

    my %spelling_result = (
        # present suggestions if not in dictionary; i.e. probably misspelled,
        # and I emphasize "probably" since Hunspell/my algo marks some proper names
        # as misspelled, simply because the word is not present in the dictionary.
        $word => ($correct) ? "correct" : [$speller->suggest($temp_word)]
    );

    $self->render(json => \%spelling_result);
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
