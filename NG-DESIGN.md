# Sense Atlas Front End: Next-Generation Design

It is time to consider a new design for the [Sense
Atlas](https://senseatlas.net/) front end. The current one was evolved
incrementally from the original 2013 prototype which was originally
designed to function without JavaScript. That constraint is no longer
tenable, and has not been for quite some time.

That aside, there are two major forcing functions operating in tandem
to spur a first-principles reconsideration of the design:

1. XSLT, which I have been using for two decades to do ultra-lazy
   client-side Web templating, is finally getting memory-holed by the
   browsers and the WHATWG.
2. Sense Atlas is beginning to collide headlong with
   [`httpRange-14`](https://en.wikipedia.org/wiki/HTTPRange-14).

In addition to these forcing functions, there are a number of issues
with the UI which have been accumulating for years. To put Sense Atlas
on the path to proper producthood, I should probably move the front
end in the direction of a so-called "modern" content-replacement
paradigm.

## Elimination of XSLT

It is an extreme bummer that XSLT, the red-headed stepchild of the Web
ecosystem, is finally getting [taken out behind the
woodshed](https://github.com/whatwg/html/issues/11523). The
precipitating event was a Google security researcher siccing a fuzzer
on both implementations (LibXSLT via WebKit/Blink, and Gecko) and
finding a whole pile of zero-day. On one hand I can understand their
situation but I also think "let's nuke the entire standard from orbit"
is a shitty conclusion to draw from it.

I have been using XSLT fairly regularly since it first shipped in MSIE
in 2001, and I had the bright idea to use it to transform (X)HTML into
itself, compose pages, and do general template stuff, sometime
in 2007. It has served me reliably for over two decades as an
extremely lazy way to make websites. Now I have to use some other
technique in a hurry, and I am not amused.

> I am aware that I can move XSLT processing to the server side; I'm
> just not thrilled at the prospect, because that's going to be harder
> to debug than it already is, and run the load up on the edge more
> than I'd like.

## Fragment Navigation

There _is_ another aspect to this situation, which is that I want
navigation through the application to behave consistently,
irrespective of whether the user is moving between documents or
`#fragments` thereof.

The [Intertwingler](https://intertwingler.net/) URI resolver has the
ability to designate certain RDF classes to be identified primarily by
_fragments_ (an HTTP URI that contains a `#`) versus proper
_documents_ (one that does not). There are reasons for this:

* **Complying with `httpRange-14`:** This long-standing issue states
  that if HTTP `GET` were a function, its _range_ ought to be
  relegated to the set of _documents_, i.e., something that can be
  faithfully represented by a definite segment of bytes. Non-documents
  (e.g. `foaf:Agent`, `skos:Concept`) must therefore _never_ be
  represented by a request-URI. This entails that if you insist on
  using an HTTP(S) URI to represent non-documents, use a fragment
  identifier, as these are outside the scope of HTTP.
* **Large numbers of small objects:** Certain types of resources
  (e.g. `skos:Concept`, `qb:Observation`) tend to be small in addition
  to being numerous, and are usually attached to some kind of
  collection-shaped resource anyway. As a practical matter it is
  useful to represent these as fragments because the alternative is
  hundreds, or perhaps _thousands_ of hits to the server to fetch
  them when dereferencing said collection.

# Approach

i want what comes out of the server to be polyvalent

ie the server only ever has to care about emitting naïve (X?)HTML+RDFa markup or JSON-LD, which it does via content negotiation

ie you should be able to just hit the resource in the browser with scripting off and see an intelligible web page with stuff on it

the client-side scripting will rearrange whatever it gets

but it must nevertheless be strictly additive to what is coming off the wire

the open question is precisely _how_, of all the myriad available ways, to go about that

What the server can guarantee the client:

* The body of a `200 OK` response **MUST** be a representation of the
  information resource identified by the request-URI.
* Non-hypermedia representations **MUST** provide a `Link:` header to
  a hypermedia variant that encodes the related metadata.
* A hypermedia representation:
  * **MUST** encode _all_ forward _and_ backward links, or a
    pagination mechanism in lieu.
  * **MUST** likewise encode _all_ forward-adjacent fragment
    resources, or provide an analogous pagination mechanism.
  * **SHOULD** encode preferred labels for links if they are available.
    * Said labels **SHOULD** be content-negotiated against the
      request's `Accept-Language:` header.
  * **SHOULD** differentiate link presentation (eg plain arc,
    image/media, embed/transclude, non-displaying) if the
    representation document format supports it.
  * (there was a **MAY** but i forget what it was)

Whatever comes off the wire initially will need to be (X)HTML because
it will need a `<script>` tag to bootstrap the front end in case the
request was cold.

The front end can do whatever it wants from there (like switch to JSON-LD for wire/parsing efficiency).

The front end **MUST NOT** encode URIs (outside of RDF properties and
classes) or construct them (outside of ordinary URI normalization,
relative URI resolution, or RDF term/CURIE expansion). It **MUST**
only _ever_ fetch resources by RDF graph traversal or ordinary
hypermedia behaviour (i.e. it is relegated to HATEOAS).

## Bootstrapping

in sense atlas the client will have a quad store

the page markup should be able to be reconstructed from graph statements

(that's basically what the xslt is doing anyway)

* Fetch the document in the location bar (this is nominally the subject, or in the case of a fragment URI, the subject's containing document).
* fetch and initialize the `<script>` tag containing the bootstrapper
  * that goes and sets up the initial stuff
  * scan the document for RDFa
  * start pulling down relevant neighbours in the background
  * keep going until you find the thing that describes the layout
  * layout defines whatever else needs to be pulled down
* set up the layout

(should the client-side graph persist?)

(keeping the client-side quad store synced to the server — and source of truth — is going to be tough _unless_ we treat it like a log of deltas; basically de facto CRDT)

(the alternative to all this business is you could just download the entire graph in one shot)

(of course then you get weird self-referentiality stuff; not sure how to represent that)

## Navigation

navigate by content replacement

let's not mess this up:

* location bar **MUST** _always_ represent the current subject
  * even if the subject is a fragment
  * ie it should be possible to cut and paste the URI into another
    browser (modulo access control, etc) and see the exact same thing.
  * note not every fragment will replace the UI, only certain ones will
    * others will just do ordinary scroll/focus stuff
    * (will probably depend on the RDF type)
* navigation clicks push to history stack
  * back button pops off history stack
  * forward button pops off some other stack and re-pushes it onto the history
    * (is that built-in or do we have to make that?)
* just store the URI, let the state be reconstructed programmatically
  * ie UI bootstrap and navigation event are essentially the same code

## State Manipulation

* adding/removing nodes
* adding/removing edges
* changing literals (labels and other values)

The entire application state **MUST** be representable solely with (and therefore reconstructable from) RDF quads.

All _changes_ to application state will therefore implicitly be representable by [LD-Patch](https://www.w3.org/TR/ldpatch/).

Every state mutation is a change in the (client-side) graph first, UI second.

Every change in the client-side graph **MUST** be registered and confirmed by the server first before being applied.

(The server **MAY** reject a change, eg on SHACL validation failure.)

(The UI **SHOULD NOT** produce statement deltas that fail to pass SHACL validation on the server side.)

The graph should fundamentally be equivalent to the sum of a log of statement deltas, such that replaying the log into a new store will produce an identical graph (this will be its own Project™ to be sure).

(the idea there is that if all state reduces to statement deltas and the graph itself is the sum of the log of deltas, this takes care of undo at the level of the entire system)

composite UI mutation primitives (molecules?):

* asserts/retracts several statements at once
* representable as a single transaction/LD-Patch operation
* can be tied to a single UI action (or eg input idle timeout?)
* currently being handled as [RDF-KV](https://doriantaylor.com/rdf-kv) `POST` forms which translate to discrete transactions
  * the `POST` does a naïve server round-trip (to a `303` that redirects to itself) which updates the state
  * propose to replace with a `PATCH` request with the LD-Patch payload
  * (RDF-KV can then be reimplemented as a request transform)

## Multiplayer

LD-Patches from other users come in via WebSocket and are applied to the graph.

Identity/location of WebSocket URI **MUST** be a hypermedia assertion.

(hang all this off "app" resource)

there will also be other ephemeral state coming over the WebSocket like presence markers and cursor information and stuff

(should probably define a WS subprotocol then)

("my" graph changes go to the server, get validated, response is either `204` or `409` with error report; if successful the patch gets forwarded via websocket to all other connected subscribers)

## Accessibility

the primary source of truth is the graph structure (first the server, mirrored in the browser)

this should drive the markup structure (including ARIA)

the markup structure should drive any graphical layout or representation

therefore screen readers **SHOULD** always work (ie this is a normative assertion)

## Graphics

CSS **SHOULD** be dispatched by RDFa whenever possible, instead of having to manage an entire other ménagerie of class names.

State changes that alter the geometry of a graphical representation **SHOULD** be calculated in advance and then animated.

SVG graphics should have embedded RDFa (and use the same CSS stylesheets eg for the palette)

if you were to isolate the SVG it should have recoverable RDF that at very least indicates where to go to fill out the graph (ie it need not embed a complete replica of the graph but it should have all the same URIs)

rdfa provides the primary handles for manipulation just as with html

interactive svg graphics should have uniform (rdf) interfaces so the app doesn't have to care about details, just blit statement delta events and the graphics rearrange themselves accordingly

(this implies a statement delta event type for which listeners can be registered on different DOM elements and then just hook into the built-in event propagation infrastructure **THIS IS ULTRA-IMPORTANT**)

(this way any piece of document subtree has the same event interface whether it's html or svg or whatever)

# Notes/Remarks

i actually kinda wanna keep xslt

that said it may or may not be necessary

[Loupe](https://vocab.methodandstructure.com/loupe#) on the server side will give me basic markup

not clear how to give loupe instructions (??? what did i mean by this)

consider local-first-ish: i could have _my_ own set of assertions that differ from the shared space but the shared space lives on the server (ish)

or does it?

there are graph statements i want to share with colleagues (to say nothing of the public) but then there are others i don't want to disclose

i also don't want it to be possible for somebody else to retract statements i have made unless i approve the action

(this will all be replayable history anyway)
