// yo if we want to sponge the document for information about what to
// do next, we have to wait for it to load

document.addEventListener('can-load-graph', function () {
    // console.log('zap lol');
    const g = this.graph;

    // also grab this page and shove it in the graph
    this.rdfa = new RDF.RDFaProcessor(g, { base: window.location.href });
    this.rdfa.process(this);

    // we actually need the focus here and we've already computed it
    // in the template so the template should just expose that

    // again the path to fetch the focus is:
    // ?s (skos:inScheme|skos:topConceptOf|^skos:hasTopConcept)?/(sioc:has_space|^sioc:space_of)/cgto:index/cgto:user/cgto:state/cgto:focus ?focus
    // and each one of these those steps has to be fetched and put in the graph

    // orrr we can just shove that path in the <head> of the document and save ourselves the trouble

    // orrrrrrrrrr we just don't care about this and render all the schemes at once

    const { rdf: rdfv, rdfs, foaf, org, ibis, pm,
            skos, xhv, dct, cgto, qb, sioc } = this.graph.namespaces;

    const skosc       = skos('Concept');
    const ibisTypes   = ['Issue', 'Position', 'Argument'].map(t => ibis(t));
    const pmTypes     = ['Goal', 'Task', 'Target', 'Action', 'Method'].map(t => pm(t));
    const foafTypes   = ['Agent', 'Person', 'Organization'].map(t => foaf(t));
    const orgTypes    = ['Organization', 'FormalOrganization',
			 'OrganizationalCollaboration', 'OrganizationalUnit',
			 'Role', 'Post', 'Membership', 'Site'].map(t => org(t));
    const entityTypes = [skosc].concat(ibisTypes, pmTypes, foafTypes, orgTypes);

    const me = RDF.sym(window.location.href);
    const a  = rdfv('type');

    // skos:inScheme|skos:topConceptOf|^skos:hasTopConcept

    const inScheme = (s, o) => g.getResources({
        subject: s, object: o,
        fwd: [skos('inScheme'), skos('topConceptOf')],
        rev: skos('hasTopConcept') });

    const getSchemes = s => inScheme(s);

    const hasSpace = (s, o) => g.getResources({
        subject: s, object: o, fwd: sioc('has_space'), rev: sioc('space_of') });

    const getSpaces = s => hasSpace(s);

    const hasIndex = (s, o) => g.getResources({
        subject: s, object: o, fwd: cgto('index') });
    const getIndices = s => hasIndex(s);

    // XXX what about language?
    const getLabel = function (subject, types) {
        if (!types) types = g.getTypes(subject);
        if (!Array.isArray(types)) types = [types];
        // XXX MAKE THIS LESS STUPID
        let label = [
            skos('prefLabel'), rdfv('value'), rdfs('label'),
            dct('title'), foaf('name')].reduce((out, p) => {
                // console.log(p);
                let o = g.getLiteralSimple(subject, p).toSorted(
                    (a, b) => a.compareTerm(b))[0];
                // this will pick the first predicate
                if (!out.length && o) return [p, o];
                return out;
            });
        return label.length ? label : [null, subject];
    };

    const TYPES = {
        ibis: ibisTypes.concat(pmTypes),
        skos: [skosc],
        foaf: foafTypes.concat(orgTypes),
    };

    // get "my" RDF types
    let myTypes = g.match(me, a).filter(
        s => RDF.isNamedNode(s.object)).map(s => s.object);

    let test;
    if      (g.has(myTypes, TYPES.ibis)) test = ts => g.has(ts, TYPES.ibis);
    else if (g.has(myTypes, TYPES.skos)) test = ts => g.has(ts, TYPES.skos);
    else if (g.has(myTypes, TYPES.foaf)) test = ts => g.has(ts, TYPES.foaf);
    else test = ts => true;

    let isEntity = g.has(myTypes, TYPES.ibis.concat(TYPES.skos));

    // anyway get the scheme
    const schemes = isEntity ? getSchemes(me) : [me];

    // console.log(types);

    // D3 STUFF

    // layering: Simplex LongestPath CoffmanGraham
    // coord: Simplex Quad Greedy Center
    const dataviz = this.dataviz = new HierRDF(g, {
        // these get compared first
	validTypes: entityTypes,
        // then this gets run
        validateEdge: (source, target, predicate) => {
            // XXX this is basically redundant
	    // console.log([source, target, predicate]);
            //return true;
            if (!isEntity) return true;
            return test(source.type) || test(target.type);
        },
        // this gets run afterward
        validateNode: (node) => {
	    // `this` goes missing because javascript
	    const s1 = schemes.map(x => dataviz.rewriteUUID(x));
	    const s2 = getSchemes(node.subject).map(x => dataviz.rewriteUUID(x));
            //console.log(s1, s2);
	    if (g.has(s1, s2)) {
		//console.log(node);
		return true;
		//if ([ibis('Network'), skos('node.type
		//if (!isEntity) return true;

		// returns the node if it's not the only one
		// return node.neighbours.length > 0 ? true : test(node.type);

		//return test(node.type);
	    }
	    return false;
        },
    }, {
        preserveAspectRatio: 'xMidYMid meet', layering: 'Simplex',
        coord: 'Simplex', radius: 5, hyperbolic: true });

    // XXX do we want to have this run in the context of the dataviz?
    const postamble = (dv) => {

	const OMO = function (e) {
	    const t = e.target;
	    const href = t.href ? t.href.baseVal || t.href :
		  t.getAttribute('about');

	    // it turns out that the selector 'a[href]' won't work on svg
	    // so we have to filter them
	    let elems = document.querySelectorAll(
		t.ownerSVGElement ?
		    'section.relations li[typeof]' : 'svg a[typeof]');

	    // console.log(elems.length, e.type);

	    const funcs = {
		mouseenter: elem => elem.classList.add('fake-hover'),
		mouseleave: elem => elem.classList.remove('fake-hover'),
	    };

	    Array.from(elems).filter(elem => {
		const uri = elem.href ? elem.href.baseVal || elem.href :
		      elem.getAttribute('about');
		return uri == href;
	    }).forEach(funcs[e.type]);

	    return true;
	};

	Array.from(document.querySelectorAll(
	    'section.relations li[typeof], svg a[typeof]')).forEach(elem => {
		// console.log (elem);
		elem.addEventListener('mouseenter', OMO);
		elem.addEventListener('mouseleave', OMO);
	    });
    };

    // XXX the whole installFetchOnLoad thing is dumb; no reason why
    // those resources couldn't be loaded right now

    // console.log(schemes);

    if (document.getElementById('force'))
        this.dataviz.installFetchOnLoad(schemes, '#force', postamble);
    else console.log("wah wah link not found");

    // install the datalists but wait until loaded because apparently
    // caching is an issue?
    if (isEntity) window.addEventListener('load', () => {
        [['big-friggin-list', skos('Concept'), true],
         ['agents', foaf('Agent'), true]
        ].forEach(([id, type, inferred]) => dataviz.loadDataList(me, [
            { fwd: [skos('inScheme'), skos('topConceptOf')],
              rev: skos('hasTopConcept') },
            { fwd: sioc('has_space'), rev: sioc('space_of') },
            cgto('index'),
            cgto('by-class'),
        ], id, type, inferred));
    });
});
