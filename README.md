# IBIS Front-End

This is the front-end from the
[IBIS](https://en.wikipedia.org/wiki/Issue-based_information_system)
prototype [`App::IBIS`](https://github.com/doriantaylor/p5-app-ibis),
decoupled from said prototype, with bundling scripts for installation on
[Intertwingler](https://intertwingler.net/).

# Dependencies

## _Catalogue_ Resources

This front-end assumes the availability of a set of resources that populate the UI with data.

### Containing Space

A [`cgto:Space`](https://vocab.methodandstructure.com/graph-tool#Index) should be accessible by an [`ibis:Network`](https://vocab.methodandstructure.com/ibis#Network) or [`skos:ConceptScheme`](https://www.w3.org/2009/08/skos-reference/skos.html#ConceptScheme).

### Meta-Index

An instance of [`cgto:Index`](https://vocab.methodandstructure.com/graph-tool#Index) which is reachable from the `cgto:Space`.

### Summaries



## RDF-KV Protocol Handler

This front-end expects to be able to `POST` to any resource under management using the [RDF-KV protocol](https://doriantaylor.com/rdf-kv).

# XSLT

## *ISSUES*

> That is, issues making client-side XSLT templates that actually function.

In general the debugging sucks; I use `xsltproc` when the server is
running on localhost (it won't work over HTTPS). Firefox emits
`<xsl:message>` content to the *browser* console (like the JS console
but for the whole browser) but generally the debugging infrastructure
for XSLT is poor. Most errors do not resolve in any meaningful way;
processing will just stop and not tell you why.

There also appears to be a bug in Firefox's XSLT processor that trips
over empty attributes. You have to use `<xsl:attribute name="about"/>`
for something like `about=""`. Figuring that out only ate like two
hours of my life.

# (S)CSS

# JavaScript

# Fonts

# Copyright & License

©2013-2024 [Dorian Taylor](https://doriantaylor.com/)

This software is provided under
the [Apache License, 2.0](https://www.apache.org/licenses/LICENSE-2.0).
