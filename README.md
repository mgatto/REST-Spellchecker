REST Spellchecker
=================

Usage
-----

Issue an HTTP POST to the endpoint "/v1/".

The body content should be the text to spellcheck. In this simple example, it
mostly expects only plain text.

Only English text is supported at this time.

The text is not saved.

```

```

  # /hello (Accept: text/plain)
  # /hello.txt
  # /hello?format=txt


It returns a string with spelling error highlighted.



### About HTTP Verbs

Strictly speaking, `POST` is meant for new resources (usually, canonically).
However, this application does not save resources to a URL on the server.
Thus, it technically does not count. However, `GET` would be inadequate here
and `PUT` would suffer from the same semantic issues which `POST` suffers.

No matter: `POST` makes this application more robust, if only because this API
could be used directly from a browser even without client-side Javascript.

How it Works
------------

Mojolicious::Lite serves as the micro-framework. Mojolicious has no required
CPAN dependencies. Some have critiqued this, but I'm fine with it since its
fast. Also, Mojolicious::Lite applications can be easily upgraded to full
Mojo applications as it grows.

See the accompanying `cpanfile` in the source code for the latest dependencies
and their versions.

Since this company operates worldwide and supports multiple language, so too,
must this spellchecker support multiple languages.  Lingua::Identify, er,
identifies the language of the text. We can't really rely on the locale reported
by the client, if even it does in a RESTful environment. In a globallized world,
people might easily need to spellcheck in a language which does not match their
reported locale.

Text::Spellchecker performs the actual spellchecking, which in turn, depends on
Text::Hunspell, or Text::Aspell. Hunspell is recommended, so we use that.
Hunspell needs dictionary files, so we'll need a number of them to support all
the languages which the company supports. See below for installing the necessary
dictionaries.


Deployment
----------

### Prerequisites

I recommend using local::lib, and even Perlbrew.

You **must** have installed hunspell on the system in which this appliction
runs. **and** dictionaries for each supported anguge.

#### Tested

* Ubuntu:
    `sudo apt-get install hunspell libhunspell-dev hunspell-en-us hunspell-fr`, etc.
    Apparently, libhunspell is placed in `/usr/lib/i386-linux-gnu/` but Text::Hunspell
    really wants it to be in `/usr/lib/`, so symlink it:
    `sudo /bin/ln -s /usr/lib/i386-linux-gnu/libhunspell.so /usr/lib/libhunspell.so`

#### Untested

* CentOS/RHEL/Fedora:
    `yum install hunspell hunspell-en hunspell-fr`, etc.
* FreeBSD:
    `pkg_add -r hunspell en-hunspell fr-hunspell`, etc.
* OpenBSD:
    `pkg_add hunspell mozilla-dicts-us mozilla-dicts-fr`, etc.
* Windows: (difficult, unless one is prepared to compile hunspell exactly the same way as one's Perl installation.)
* OSX: (already installed by default on 10.6 and later)


### Source Code

```
git clone https://github.com/mgatto/REST-Spellchecker.git
cd REST-Spellchecker
```

Now, install the dependencies.

### Dependencies

cpanm will automatically use the `cpanfile` in the source code to install dependencies.

`cpanm --installdeps .`


### Start the Server

For demonstration purposes, we use the built-in Morbo HTTP server.

Make sure you're in the same directory as `spellchecker.pl` and then run:
`./spellchecker.pl daemon`



Testing
-------

Tested under Perl 5.14.2 on Ubuntu 12.04.


Why Not...?
-----------

Dancer:


Raw Plack:


Mod_Perl:


Interesting Future Directions
-----------------------------
The text could be saved in a psuedo- or real VCS, and used to make diffs of
resubmitted texts. Might be useful for linguists tracking spelling error rates.
