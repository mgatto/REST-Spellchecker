#!/usr/bin/env perl
use Mojolicious::Lite;
use Modern::Perl '2012';
use Lingua::Identify qw(:language_identification);
use Locale::Util qw(parse_http_accept_language);
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


=head1 GET '/api/v1/spellcheck/WORD'

Spellcheck a word.


=cut
get '/api/v1/spellcheck/:word' => sub {
    # an instance of Mojolicious::Controller
    my $self = shift;

    my $dict_path = '/usr/share/hunspell';
    my $lang = "en_US"; # default

    # format should be only plain text, not JSON nor YAML nor even HTML yet.
    my $word = $self->param('word');

    # some dictionary files have locale suffixes; avoid "empty dic file"
    my %lang_2_locales = (
        # Yeah, I'm making alot of assumptions here
        fr => 'fr',
        en => 'en_US', # ah, sorry Brits; should have passed a whole Accpet-Language + locale in your HTTP header!
        de => 'de_DE',
    );
    # @TODO: Deal with character sets for non-Latin scripts.


    ## Determine language
    # First, see if our client is well-behaved and sets Accept-Language
    my @languages = parse_http_accept_language($self->req->headers->accept_language);
    if ( @languages && $#languages > 0 ) {
        #convert to a dict-freindly locale name
        my @parts = split(/-/, $languages[0]);
        # $#parts is the *subscript* of the last element, not the size...
        if ( $#parts > 0 ) {
            $lang = $parts[0] . '_' . uc $parts[1];
        } else {
            $lang = $parts[0];
        }

    } else {
        # fallback from HTTP headers for locales: someone in a Spanish locale
        # may easily wish to spellcheck an English text, so check the text directly.
        $lang = langof($word);
            # this is nice, but it can't distinguish country locales...
    }

    return $self->render(json => {error => "Dictionary does not exist for: $lang."}, status => 500)
        unless exists $lang_2_locales{$lang} && defined $lang_2_locales{$lang};

    #$self->app->log->debug("Language in use: '$lang_2_locales{$lang}'");
    my $speller = Text::Hunspell->new(
        sprintf("%s/%s.aff", $dict_path, $lang_2_locales{$lang}), # Hunspell affix file
        sprintf("%s/%s.dic", $dict_path, $lang_2_locales{$lang})  # Hunspell dictionary file
    );
    return $self->render(json => {error => "Speller failed at start-up."}, status => 500) unless $speller;

    #strip punctuation before checking to prevent false errors.
    my $temp_word = $word =~ s/[[:punct:]]//r;
        # use a temp var since we want to return the original

    my $correct = $speller->check($temp_word);
    my %spelling_result = (
        # present suggestions if not in dictionary; i.e. probably misspelled,
        # and I emphasize "probably" since Hunspell/my algo marks some proper names
        # as misspelled, simply because the word is not present in the dictionary.
        # In this case, an empty array is returned to the client.
        $word => ( $correct ) ? undef : [$speller->suggest($temp_word)]
    );

    return $self->render(json => \%spelling_result, status => ($correct) ? 200 : 404);
};


app->start;

__DATA__

@@ help.html.ep
% layout 'default';
% title 'Help';
This application is only meant to be accessed a an API.

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
