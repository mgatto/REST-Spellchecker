REST Spellchecker
=================

A REST API to spellcheck a single word at a time.

Usage
-----

Issue a HTTP GET request to the endpoint `/api/v1/spellcheck/YOUR-WORD`. It
would be nice to include an Accept-Language header which matches the language
of the submitted word. If you do not, the service falls back to linguistic
analysis to determine which language dictionary to load.

However, determining the language of a single word is less reliable
compared to blocks of text, so please send the header. Multiple language
preferences should be qualified.

For example:
```
curl -v -H "Accept-Language: fr;q=1.0, en-us;q=0.8"  127.0.0.1:3000//api/v1/spellcheck/rsearch
```

## Returned Content

The return format is JSON.

#### Word is correct:

Returns just the word.

HTTP Code: 200.
```json
{"research":NULL}
```

#### Word is incorrect:

Returns the word with a list of suggestions.

HTTP Code: 404 (Not Found).
```json
{"rsearch":["searcher","research"]}
```

#### Error - Dictionary not found for locale:

Returns an error string.

HTTP Code: 500.
```json
{"error":"Dictionary does not exist for: ar_AE"}
```

#### Error - Speller library error:

Returns an error string.

HTTP Code: 500.
```json
{"error":"Speller failed at start-up."}
```

How it Works
------------

Mojolicious::Lite serves as the HTTP micro-framework. Mojolicious has no required
CPAN dependencies. Some have critiqued this, but I'm fine with it since its
fast. Also, a Mojolicious::Lite application can be easily upgraded to a full
Mojo application as it grows, for better developer happiness.

See the accompanying [`cpanfile`](https://github.com/mgatto/REST-Spellchecker/blob/master/cpanfile) in the source code for the latest dependencies
and their versions.

This company operates worldwide and supports multiple language. So too,
must this spellchecker support multiple languages.  Locale::Util parses the
HTTP Accept-Language header. As a fallback, Lingua::Identify identifies the
language of the text. In a globallized world, people may well need to
spellcheck in a language which does not match their reported locale.

Text::Hunspell performs the actual spellchecking. Hunspell gets the most recommendations
over Aspell and is used in many OSes, browsers and notably, OpenOffice. Hunspell
is just a library, so it needs dictionary files, one for each language. Sometimes
each language has a separate file for each locale. For example, there are
separate dictionaries in German for Germany and another for Switzerland.
See below for installing the necessary dictionaries.

Deployment
----------

### Prerequisites

You **must** have installed hunspell on the system in which this appliction
runs **and dictionaries** for each supported languge.

#### Tested

* Ubuntu:
    Tested under Perl 5.14.2 on Ubuntu 12.04 LTS, in VirtualBox.

    ```
    sudo apt-get install hunspell libhunspell-dev hunspell-en-us hunspell-fr
    ```
    There are virtual packages which group together multiple locales for each language.
    You probably want those to save some typing, but the above is laser-specific.

    Libhunspell is installed into `/usr/lib/i386-linux-gnu/` but Text::Hunspell
    only looks for it in `/usr/lib/` (at least when we install directly from CPAN),
    so symlink it:
    ```
    sudo /bin/ln -s /usr/lib/i386-linux-gnu/libhunspell.so /usr/lib/libhunspell.so
    ```

#### Untested

* CentOS/RHEL/Fedora:
    `yum install hunspell hunspell-en hunspell-fr`, etc.
* FreeBSD:
    `pkg_add -r hunspell en-hunspell fr-hunspell`, etc.
* OpenBSD:
    `pkg_add hunspell mozilla-dicts-us mozilla-dicts-fr`, etc.
* Windows: (difficult, unless one is prepared to compile hunspell exactly the same way as one's Perl installation.)
* OSX: (already installed by default on 10.6 and later)

### Get Source Code

```
git clone https://github.com/mgatto/REST-Spellchecker.git
cd REST-Spellchecker
```

Next, install the dependencies.

### Install Dependencies

cpanm will automatically use the [`cpanfile`](https://github.com/mgatto/REST-Spellchecker/blob/master/cpanfile) in the source code to install dependencies.

The modules are pinned to their latest releases, simply on principle and to match
my testing environment. Earlier releases of these distributions may well work.
Feel free to modify the cpanfile; it may break however, and if it does, please
file an issue on this GitHub project.

You may wish to install the required modules into your local::lib, and possibly
a separate install using Perlbrew.

In any case, go ahead and install the dependencies:
```
cpanm --installdeps .
```
After this, you are ready to start the (test) server!

### Start the Server

For demonstration purposes, we use the Morbo HTTP server, built-in to Mojolicious.
Make sure you're in the same directory as `spellchecker.pl` and then run:
```
./spellchecker.pl daemon
```

Why Not...?
-----------

<dl>
    <dt>Dancer</dt>
    <dd>A good drop in for Mojolicious, especially Dancer2. But my subjective opinions
    prefers Mojolicious::Lite.</dd>

    <dt>Raw Plack</dt>
    <dd>Fast, but too much wheel-reinventing.</dd>

    <dt>Mod_Perl</dt>
    <dd>If one must deploy in that environment, then a PSGI adapter would probably
    be better than using a slew of Apache:: or Apache2:: modules.</dd>
</dl>

Possible ToDos
--------------
The service could collect statistics on misspelled words and chosen replacements
to prioritize common replacements.

Hunspell copes poorly with some proper nouns. Could compare to dictionaries of
names for example, in the specfied locale.

More dictionaries, including Asian language support and their varying charsets:

* Český
* Dansk
* Español
* Italiano
* Magyar
* Nederlands
* Norsk
* Polski
* Português
* Suomi
* Svenska
* Russian
* Russian
* Thai
* Korean
* Mandarin Chinese
* Japanese
