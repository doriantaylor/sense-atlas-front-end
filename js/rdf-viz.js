import * as RDF from 'rdf';
import * as d3 from 'd3';

export default class RDFViz {
    static ns = Object.entries({
        rdf:  'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
        rdfs: 'http://www.w3.org/2000/01/rdf-schema#',
        owl:  'http://www.w3.org/2002/07/owl#',
        xsd:  'http://www.w3.org/2001/XMLSchema#',
        xhv:  'http://www.w3.org/1999/xhtml/vocab#',
        dct:  'http://purl.org/dc/terms/',
        bibo: 'http://purl.org/ontology/bibo/',
        foaf: 'http://xmlns.com/foaf/0.1/',
        org:  'http://www.w3.org/ns/org#',
        skos: 'http://www.w3.org/2004/02/skos/core#',
        ibis: 'https://vocab.methodandstructure.com/ibis#',
        ci:   'https://vocab.methodandstructure.com/content-inventory#',
        pm:   'https://vocab.methodandstructure.com/process-model#',
        cgto: 'https://vocab.methodandstructure.com/graph-tool#',
        qb:   'http://purl.org/linked-data/cube#',
        sioc: 'http://rdfs.org/sioc/ns#',
    }).reduce(
        // this will return `out` always
        (out, [key, value]) => (out[key] = new RDF.Namespace(value), out), {});

    static validTypes = [
        'foaf:Agent', 'foaf:Person', 'foaf:Organization', 'org:Organization',
        'org:FormalOrganization', 'org:OrganizationalCollaboration',
	'org:OrganizationalUnit', 'org:Role', 'skos:Concept', 'ci:Audience',
	'ibis:Issue', 'ibis:Position', 'ibis:Argument',
        'pm:Goal', 'pm:Task', 'pm:Target'];

    static labels = {
        'foaf:Person':             'foaf:name',
        'foaf:Organization':       'foaf:name',
        'org:Organization':        'foaf:name',
        'org:OrganizationalUnit':  'foaf:name',
        'org:FormalOrganization':  'foaf:name',
        'org:Role':                'skos:prefLabel',
        'skos:Concept':            'skos:prefLabel',
        'ci:Audience':             'skos:prefLabel',
        'ibis:Issue':              'rdf:value',
        'ibis:Position':           'rdf:value',
        'ibis:Argument':           'rdf:value',
        'pm:Goal':                 'rdf:value',
        'pm:Task':                 'rdf:value',
        'pm:Target':               'rdf:value',
    };

    static inverses = Object.entries({
        // SKOS
        'skos:related':            'skos:related',
        'skos:narrower':           'skos:broader',
        'skos:broader':            'skos:narrower',
        'skos:narrowerTransitive': 'skos:broaderTransitive',
        'skos:broaderTransitive':  'skos:narrowerTransitive',
        'skos:narrowMatch':        'skos:broadMatch',
        'skos:broadMatch':         'skos:narrowMatch',
        'skos:closeMatch':         'skos:closeMatch',
        'skos:exactMatch':         'skos:exactMatch',
        // IBIS
        'ibis:endorses':           'ibis:endorsed-by',
        'ibis:concerns':           'ibis:concern-of',
        'ibis:generalizes':        'ibis:specializes',
        'ibis:specializes':        'ibis:generalizes',
        'ibis:replaces':           'ibis:replaced-by',
        'ibis:replaced-by':        'ibis:replaces',
        'ibis:questions':          'ibis:questioned-by',
        'ibis:questioned-by':      'ibis:questions',
        'ibis:suggests':           'ibis:suggested-by',
        'ibis:suggested-by':       'ibis:suggests',
        'ibis:response':           'ibis:responds-to',
        'ibis:responds-to':        'ibis:response',
        'ibis:supports':           'ibis:supported-by',
        'ibis:supported-by':       'ibis:supports',
        'ibis:opposes':            'ibis:opposed-by',
        'ibis:opposed-by':         'ibis:opposes',
	// PM
	'pm:achieves':             'pm:achieved-by',
	'pm:anchors':              'pm:anchored-by',
	'pm:context':              'pm:contextualizes',
	'pm:dependency':           'pm:dependency-of',
	'pm:initiates':            'pm:initiated-by',
	'pm:method':               'pm:instance',
	'pm:process':              'pm:outcome',
	'pm:subtask':              'pm:supertask',
	'pm:variant':              'pm:variant',
	// FOAF/ORG
	'org:hasMember':           'org:memberOf',
	'org:hasSubOrganization':  'org:subOrganizatonOf',
	'org:hasUnit':             'org:unitOf',
    }).reduce((out, [key, value]) => {
	out[key]   = value;
	out[value] = key;
	return out;
    }, {});

    static symmetric = ['skos:related', 'foaf:knows', 'pm:variant'];
    // layering: Simplex LongestPath CoffmanGraham
    // coord: Simplex Quad Greedy Center

    // note these have been munged from what we actually want them to
    // be so the sugiyama graph is tighter
    static prefer = {
        'ibis:concern-of':   'ibis:concerns',
        'ibis:endorsed-by':  'ibis:endorses',
        'ibis:specializes':  'ibis:generalizes',
        'ibis:replaced-by':  'ibis:replaces',
        // 'ibis:questioned-by': 'ibis:questions',
        'ibis:questions':    'ibis:questioned-by',
        'ibis:suggested-by': 'ibis:suggests',
        // 'ibis:response':      'ibis:responds-to',
        'ibis:responds-to':  'ibis:response',
        // 'ibis:supported-by':  'ibis:supports',
        'ibis:supports':     'ibis:supported-by',
        // 'ibis:opposed-by':    'ibis:opposes',
        'ibis:opposes':      'ibis:opposed-by',
        // 'skos:narrower':      'skos:broader',
        'skos:broader':      'skos:narrower',
	'pm:achieves':       'pm:achieved-by',
        'pm:anchored-by':    'pm:anchors', // target on top
        'pm:contextualizes': 'pm:context',
        'pm:dependency-of':  'pm:dependency',
	'pm:initiates':      'pm:initiated-by',
	'pm:method':         'pm:instance',
        'pm:outcome':	     'pm:process',
        'pm:supertask':	     'pm:subtask',
    };

    constructor (graph, rdfParams = {}, d3Params = {}) {
        if (!graph) graph = RDF.graph();
        this.graph     = graph;
        this.rdfParams = Object.assign({}, rdfParams ||= {});
        this.d3Params  = Object.assign({ width: 1000, height: 1000 },
                                       d3Params ||= {});

        const ns = this.ns = this.graph.namespaces;

        // XXX there is probably something that easily does this

        Object.entries(
            Object.assign({}, this.constructor.ns, rdfParams.ns || {})
        ).forEach(([k, v]) => ns[k] = v);

        // rdf:type
        this.a = ns.rdf('type');

        this.validTypes = [].concat(
            rdfParams.validTypes || this.constructor.validTypes).map(
                x => ns.expand(x)).reduce((o, x) => {
                    x = ns.expand(x);
                    if (!(o.some(y => x.equals(y)))) o.push(x);
                    return o;
                }, []);

        this.labels = Object.entries(Object.assign(
            {}, this.constructor.labels, rdfParams.labels || {})).reduce(
                (x, [k, v]) => {
                    x[ns.expand(k).value] = ns.expand(v);
                    return x;
                }, {});

        this.inverses = Object.entries(Object.assign(
            {}, this.constructor.inverses, rdfParams.inverses || {})).reduce(
                (x, [k, v]) => {
                    x[ns.expand(k).value] = ns.expand(v);
                    return x;
                }, {});

        this.symmetric = [].concat(
            this.constructor.symmetric, rdfParams.symmetric || []).map(
                x => ns.expand(x)).reduce((o, x) => {
                    x = ns.expand(x);
                    if (!(o.some(y => x.equals(y)))) o.push(x);
                    return o;
                }, []);

        this.prefer = Object.entries(Object.assign(
            {}, this.constructor.prefer, rdfParams.prefer || {})).reduce(
                (x, [k, v]) => {
                    x[ns.expand(k).value] = ns.expand(v);
                    return x;
                }, {});
    }

    init () {
        throw 'Needs to be overridden in a subclass';
    }

    installFetchOnLoad (url, target, postamble) {
	if (!(url instanceof Array)) url = [url];
        if (window) {
            // XXX this is dumb but due to https://bugzilla.mozilla.org/show_bug.cgi?id=325891
	    // console.log('wat', this);
	    const me = this;

	    this.graph.fetcher.load(url, {
		// this overrides the actual <base href="">
		// baseURI: window.location.href,
		noRDFa: false }).then(() => {
		    console.log('graph loaded; initializing');
		    me.init();
		    const event = () => {
			if (target) {
			    me.attach(target);
			    if (typeof postamble == 'function') {
				console.log('calling postamble');
				postamble.bind(me)(me);
			    }
			}
		    };
		    // console.log(document.readyState);
		    if (document.readyState === 'complete') event();
		    else window.addEventListener('load', event);
		});
        }
        else console.error('window not available yet');
    }

    // XXX this might be obsolete
    getRoot () {
        if (this.root) return this.root;

        const root = this.root = new URL(window.location.href);
        const path = root.pathname.split('/').slice(0, -1);
        path.push('');
        root.pathname = path.join('/');
        root.hash     = ''; // the root is never a fragment
        root.search   = ''; // it probably shouldn't be a query either

        // (i might regret the latter but we'll see)

        return root;
    }

    rewriteUUID (uuid) {
        if (!uuid instanceof RDF.NamedNode) uuid = RDF.sym(uuid.toString());

        if (!uuid.value.toLowerCase().startsWith('urn:uuid')) return uuid;

        // clone the uri
        const uri = new URL(this.getRoot().href);

        let path = uuid.value.replace('urn:uuid:', uri.pathname);
        uri.pathname = path;

        // XXX THIS SUCKS JUST REWRITE THE URLS IN THE TURTLE OUTPUT
        return RDF.sym(uri.href);
    }

    attach (selector) {
        // bail out early if this is a node
        if (selector instanceof Node) return selector.appendChild(this.svg);

        if (typeof document !== 'undefined') {
            // now we assume it's an id
            let elem = document.getElementById(selector);
            // otherwise it's a query selector
            if (!elem) elem = document.querySelector(selector);

            if (elem) return elem.appendChild(this.svg);
        }

        console.error(`could not attach to ${selector}`);

        return null;
    }

    async derefPP (start, path) {
        const g = this.graph;

        // coerce path to array
        if (!path) path = [];
        else if (!Array.isArray(path)) path = [path];

        if (path.length > 0) {
            // obtain the first element in the property path
            let test = path[0];

            // normalize the element
            if (RDF.isNamedNode(test)) {
                let tmp = test;
                test = { subject: start, fwd: tmp };
            }
            else if (typeof test === 'object') {
                let patch = {};
                if (test.fwd) patch['subject'] = start;
                else if (test.rev) patch['object'] = start;

                test = Object.assign({}, test, patch);
            }
            else throw new Error('not sure what to do with path: ' +
                                 JSON.stringify(path));

            // check the existing graph for the thing
            let nexts = g.getResources(test);

            // if none, then fetch `start`
            if (nexts.length == 0) {
                console.debug(`dereferencing ${start}`);
                // okay *now* check
                await g.fetcher.load(start);
                nexts = g.getResources(test);
                // if still none, bail out or raise or something i dunno,
                // probably raise
                if (nexts.length == 0)
                    throw new Error(`could not find ${JSON.stringify(test)}` +
                                    ` after dereferencing ${start}`);
            }

            console.debug(`found ${nexts[0]}`);

            // onto the next one
            return this.derefPP(nexts[0], path.slice(1));

            //path = path.slice(1);
            //return path.length > 0 ? derefPP(nexts[0], path) : start;
        }

        return start;
    }

    async handlePagination (subject, seen) {
        // add to seen
        seen = seen || [];
        seen.push(subject);

        const g  = this.graph;
        const ns = g.namespaces;

        const next = g.getResources({
            subject: subject, fwd: ns.xhv('next')
        }).filter(x => seen.some(y => y.equals(x)))[0];

        // load the next one
        if (next) {
            await g.fetcher.load(next);
            return this.handlePagination(next, seen);
        }

        // our termination condition
        return subject;
    }

    /*
     * Traverse a path
     *
     */
    async loadDataList (subject, path, id, type, inferred) {
        const g       = this.graph;
        const ns      = g.namespaces;
        const fetcher = g.fetcher;

        const a    = ns.rdf.type;
        const cgto = ns.cgto;
        const ww = { fwd: cgto.window, rev: cgto['window-of'] };

        this.derefPP(subject, path).then(resource => {
            console.log(`hooray ${resource}`);
            fetcher.load(resource).then(() => {
                let obs = g.getResources({ object: type, fwd: ns.cgto.class});
                if (obs.length > 0) {
                    let pred = cgto[
                        (inferred ? 'inferred' : 'asserted') + '-subjects'];
                    let invs = this.derefPP(obs[0], [pred, ww]).then((s) => {
                        let types = g.getTypes(s);
                        // console.log(types);

                        let window;
                        if (g.has(types, [cgto.Window])) {
                            let inv = g.getResources(
                                {subject: s, fwd: ww.rev, rev: ww.fwd });
                            window = s;
                            s = inv[0];
                        }
                        else {
                            console.log(`${s} should be the inventory`);

                            console.log(g.match(null, ww.rev, s));

                            let windows = g.getResources(
                                { subject: s, rev: ww.rev });
                            console.log(windows);
                            window = windows[0];
                        }
                        this.handlePagination(window).then((w) => {
                            console.log(`pagination complete: ${w}`);
                            let members = g.getResources(
                                { subject: s, fwd: ns.rdfs('member')});
                            console.log(`${members.length} members`);
                            let options = members.map((m) => {
                                let types = g.getTypes(m);
                                let [lp, lo] = g.getLabel(m, types);

                                let out = {
                                    '#option': lo.value,
                                    about: m.value, value: m.value,
                                    typeof: types.map(t => ns.abbreviate(t)) };
                                if (lp) out.property = ns.abbreviate(lp);

                                return out;
                            });

                            // generate the list
                            MARKUP({ parent: document.body,
                                     spec: { '#datalist': options, id: id } });

                            // gotta reset it lol (XXX CARGO CULT??)
                            Array.from(
                                document.querySelectorAll(
                                    `*[list="${id}"]`)).forEach(
                                        e => e.setAttribute('list', id));
                        });
                        //console.log(s, window);
                    });
                }
            });
        });
    }
}
