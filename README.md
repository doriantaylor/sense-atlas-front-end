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

# (S)CSS

# JavaScript

# Fonts

# Copyright & License

©2013-2024 [Dorian Taylor](https://doriantaylor.com/)

This software is provided under
the [Apache License, 2.0](https://www.apache.org/licenses/LICENSE-2.0).
