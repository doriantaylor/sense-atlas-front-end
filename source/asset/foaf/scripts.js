document.addEventListener('can-load-graph', function () {
    // console.log('zap lol');
    const g = this.graph;

    const { rdf: rdfv, dct, foaf, org } = this.graph.namespaces;

    const foafTypes = ['Agent', 'Person', 'Organization'].map(t => foaf(t));
    const orgTypes  = ['Organization', 'FormalOrganization',
		       'OrganizationalCollaboration', 'OrganizationalUnit',
		       'Role', 'Post', 'Membership', 'Site'].map(t => org(t));

    const me = RDF.sym(window.location.href);
    const a = rdfv.type;


    const isPartOf = (s, o) => g.getResources({
        subject: s, object: o, fwd: dct.isPartOf, rev: dct.hasPart });
    const getCollections = s => isPartOf(s);

    const myTypes = g.getTypes(me);

    const isAgent = g.has(myTypes, foafTypes.concat(orgTypes));
    const collections = isAgent ? getCollections(me) : [me];

    const dataviz = this.dataviz = new ForceRDF(g, {
        validTypes: foafTypes.concat(orgTypes),
    }, {
        width: 1000, height: 1000, preserveAspectRatio: 'xMidYMid meet',
    });

    const postamble = (dv) => {
    };

    if (document.getElementById('force'))
        this.dataviz.installFetchOnLoad(collections, '#force', postamble);
    else console.log("wah wah link not found");
});

