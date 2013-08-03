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


Deployment
----------

I recommend using local::lib, and even Perlbrew.


Testing
-------





Why Not...?
-----------

Dancer:


Raw Plack:


Mod_Perl:


Interesting Future Directions
-----------------------------
The text could be saved in a psuedo- or real VCS, and used to make diffs of
resubmitted texts. Might be useful for linguists tracking spelling error rates.
