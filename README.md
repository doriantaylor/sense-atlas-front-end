# IBIS Front-End

This is the front-end from the
[IBIS](https://en.wikipedia.org/wiki/Issue-based_information_system)
prototype [`App::IBIS`](https://github.com/doriantaylor/p5-app-ibis),
decoupled from said prototype, with bundling scripts for installation
on top of [Intertwingler](https://intertwingler.net/).

# Server-Side Dependencies

This front end has been adapted to interface with
[Intertwingler](https://github.com/doriantaylor/rb-intertwingler), but
could conceivably work with any Web-based system that can produce valid
XHTML+RDFa and correctly renders the relevant RDF vocabularies.

## _Catalogue_ Resources

This front-end assumes the availability of a set of resources that
populate the UI with data.

### Containing Space

A
[`cgto:Space`](https://vocab.methodandstructure.com/graph-tool#Space)
(a subclass of [`sioc:Space`](http://rdfs.org/sioc/spec/#term_Space))
should be accessible by an
[`ibis:Network`](https://vocab.methodandstructure.com/ibis#Network) or
[`skos:ConceptScheme`](https://www.w3.org/2009/08/skos-reference/skos.html#ConceptScheme),
via the property
[`sioc:has_space`](http://rdfs.org/sioc/spec/#term_has_space). This is
the outer container of the application. It requires no special
implementation and can be rendered straight from the graph using the
default
[`Intertwingler::Handler::Generated`](https://github.com/doriantaylor/rb-intertwingler/blob/main/lib/intertwingler/handler/generated.rb).

### Meta-Index

This is the entry point for the set of reusable catalogue
resources. It is an instance of
[`cgto:Index`](https://vocab.methodandstructure.com/graph-tool#Index)
which is reachable from the `cgto:Space` via
[`cgto:index`](https://vocab.methodandstructure.com/graph-tool#index). It
also lists the current logged-in user (which currently resolves to a
[`foaf:Agent`](http://xmlns.com/foaf/spec/#term_Agent), though this
may change) via
[`cgto:user`](https://vocab.methodandstructure.com/graph-tool#user). The
index is implemented by
[`Intertwingler::Handler::Catalogue`](https://github.com/doriantaylor/rb-intertwingler/blob/main/lib/intertwingler/handler/catalogue.rb).

### Summaries

These are subclasses of
[`qb:DataSet`](https://www.w3.org/TR/vocab-data-cube/#datasets) that
each have their respective
[`qb:DataStructureDefinition`](https://www.w3.org/TR/vocab-data-cube/#dsd-dsd)
denoting what's in them. The two we concern ourselves with are:

* [instances of classes](https://vocab.methodandstructure.com/graph-tool#resources-by-class)
* [entities in the domains and/or ranges of properties](https://vocab.methodandstructure.com/graph-tool#resources-by-property)

These are rendered as HTML tables. Every record in each table includes
the relevant class or property, counts of both asserted and inferred
resources, and links to the corresponding inventories. The summaries,
then, provide an overview of all the addressable resources in the RDF
graph. They are also implemented by `Intertwingler::Handler::Catalogue`.

### Inventories

The
[`cgto:Inventory`](https://vocab.methodandstructure.com/graph-tool#resources-by-class)
is a subclass of
[`rdfs:Container`](https://www.w3.org/TR/rdf-schema/#ch_container),
and resources are connected to it by
[`rdfs:member`](https://www.w3.org/TR/rdf-schema/#ch_member). Assuming
it can get very large, the inventory is paginated, using a
[`cgto:Window`](https://vocab.methodandstructure.com/graph-tool#Window)
mechanism. There is only one inventory resource, which is
parametrized. It is also implemented by
`Intertwingler::Handler::Catalogue`.

### Vocabularies

This is a single RDF/XML resource that serializes all the vocabularies
known to the server. It is used for looking up e.g. the domains and
ranges of properties. Since this can be rather large, it is unclear if
it will be a permanent strategy. There _is_ a generated version
implemented by `Intertwingler::Handler::Catalogue`, but it's very slow
to execute, mainly due to the two copies of
[schema.org](https://schema.org), which are enormous.

## RDF-KV Protocol Handler

This front-end expects to be able to `POST` to any resource under
management using the [RDF-KV
protocol](https://doriantaylor.com/rdf-kv).

# XSLT

The templating is done using client-side [XSLT
1.0](https://www.w3.org/TR/1999/REC-xslt-19991116). Yes, this is
archaic. Yes there are [newer](https://www.w3.org/TR/xslt20/)
[versions](https://www.w3.org/TR/xslt-30/), but 1.0 is still the only
one with native browser support. The only drawback (aside from XSLT
1.0 being 26 years old and missing all sorts of useful stuff
introduced in subsequent versions) is it's in XML and only operates
over XML, and it tends to be a little wordy. Due to atrophied support
among browser vendors, it is also difficult to debug. XSLT, however,
in addition to being a standard, is fast and efficient, and,
importantly, _only_ operates over markup, and only operates over
information it is expilcitly given. Due to its node-oriented nature,
moreover, it is also incapable of producing results that are not
syntactically valid.

## Manifest

### [`transform.xsl`](source/transform.xsl)

This is the main entry point. It handles the root transformation, as
well as contains the dispatcher that forwards processing to (RDF)
type-specific templates.

### [`rdfa-util.xsl`](source/asset/rdfa-util.xsl)

These are utilities that are candidates for, or are ultimately too
specific to go straight into the dependency `rdfa.xsl`. They abridge
some of the metadata lookup tasks.

### [`cgto.xsl`](source/asset/cgto.xsl)

These are mainly utility templates for resolving chains of resources
that, again, are not specific to the content being manipulated.

### [`skos-ibis.xsl`](source/asset/skos-ibis.xsl)

This the actual type-specific template, handling SKOS and IBIS
content.

## Dependencies

### `transclude.xsl`

This is a [general-purpose
mechanism](https://github.com/doriantaylor/xslt-transclusion) for
performing seamless transclusions, and handling things like headings
and rewriting links and particularly fragment identifiers.

### `rdfa.xsl`

This is [a basic RDFa query
engine](https://github.com/doriantaylor/xslt-rdfa), which is used to
query the RDFa embedded in (X)HTML (or SVG, or other) markup, to drive
other decisions about template rendering.

### XSLTSL

[The XSLT standard library](https://xsltsl.sourceforge.net/), last
released in 2004, is used by both the transclusion and RDFa templates.

## _ISSUES_

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

The app uses [Sass](https://sass-lang.org/) to generate the CSS and
particularly the resplendent palette of the tool. This currently has
to be compiled up front but will eventually be switched to be served
on the fly.

## Manifest

### [`_data.scss`](source/asset/_data.scss)

This contains all the palette data.

### [`skos-ibis/style.scss`](source/asset/skos-ibis/style.scss)

This specifies the CSS for SKOS and IBIS entities.

# JavaScript

The JavaScript situation is currently _extremely_ disorganized. Much
like the Sass, the eventual goal is to trace dependencies and bundle
it (if necessary) on the fly. For the time being, this is a `Makefile`
task.

## Manifest

### [`rdf.js`](js/rdf.js)

This is a wrapper around `rdflib.js` (for some reason).

### [`rdf-viz.js`](js/rdf-viz.js)

This mainly provides an abstract superclass for generating SVG
visualizations using RDF data.

### [`hierarchical.js`](js/hierarchical.js)

This script provides the hierarchical graph visualization.

### [`force-directed.js`](js/force-directed.js)

This script provides an earlier force-directed visualization that is
currently not used.

### [`skos-ibis/scripts.js`](source/asset/skos-ibis/scripts.js)

This script handles the loading of the visualization and the write
support for SKOS and IBIS entities.

## Dependencies

### `complex.js`

[Complex numbers](https://www.npmjs.com/package/complex) for rendering
the [Poincaré
Disk](https://en.wikipedia.org/wiki/Poincar%C3%A9_disk_model).

### `d3.js`

The venerable [D3 graphics library](https://d3js.org/).

### `rdflib.js`

The [JS implementation of RDF](https://www.npmjs.com/package/rdflib).

# Fonts

* [Roboto](https://fonts.google.com/specimen/Roboto)
* [Font Awesome 5 Free](https://fontawesome.com/)
* [Noto Sans Symbols 2](https://fonts.google.com/noto/specimen/Noto+Sans+Symbols+2)

# Copyright & License

©2013-2025 [Dorian Taylor](https://doriantaylor.com/)

This software is provided under
the [Apache License, 2.0](https://www.apache.org/licenses/LICENSE-2.0).
