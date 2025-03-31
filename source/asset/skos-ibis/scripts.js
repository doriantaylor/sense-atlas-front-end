// yo if we want to sponge the document for information about what to
// do next, we have to wait for it to load

document.addEventListener('load-graph', function () {
    // console.log('zap lol');
    const graph = this.graph = RDF.graph();
    this.rdfa  = new RDF.RDFaProcessor(
        this.graph, { base: window.location.href });

    // okay first we grab this page and shove it in the graph
    this.rdfa.process(this);

    // we actually need the focus here and we've already computed it
    // in the template so the template should just expose that

    // again the path to fetch the focus is:
    // ?s (skos:inScheme|skos:topConceptOf|^skos:hasTopConcept)?/(sioc:has_space|^sioc:space_of)/cgto:index/cgto:user/cgto:state/cgto:focus ?focus
    // and each one of these those steps has to be fetched and put in the graph

    // orrr we can just shove that path in the <head> of the document and save ourselves the trouble

    // orrrrrrrrrr we just don't care about this and render all the schemes at once

    const rdfv = RDF.Namespace('http://www.w3.org/1999/02/22-rdf-syntax-ns#');
    const ibis = RDF.Namespace('https://vocab.methodandstructure.com/ibis#');
    const skos = RDF.Namespace('http://www.w3.org/2004/02/skos/core#');
    const xhv  = RDF.Namespace('http://www.w3.org/1999/xhtml/vocab#');

    const ibisTypes = ['Issue', 'Position', 'Argument'].map(t => ibis(t));
    const skosc = skos('Concept');

    const me = RDF.sym(window.location.href);
    const a  = rdfv('type');
    let types = this.graph.match(me, a).filter(
        s => RDF.isNamedNode(s.object)).map(s => s.object);

    let isEntity = types.some(t => t.equals(skosc));

    if (ibisTypes.some(t => types.some(u => t.equals(u)))) {
        isEntity = true;
        types = ibisTypes;
    }

    // skos:inScheme|skos:topConceptOf|^skos:hasTopConcept
    // XXX is this *really* how you do this??
    const getSchemes = s => this.graph.match(s, skos('inScheme')).concat(
	this.graph.match(s, skos('topConceptOf'))).concat(
	    this.graph.match(null, skos('hasTopConcept'), s)).reduce(
		(a, s) => (RDF.isNamedNode(s.object) ?
			   a.some(x => x.equals(s.object)) ? a :
			   a.concat([s.object]) : a), []);
    // anyway get the scheme
    const schemes = isEntity ? getSchemes(me) : [me];

    // console.log(schemes);

    // test if these are the types we're after
    const test = ts => ts.filter(t => types.some(x => x.equals(t))).length > 0;

    // console.log(types);

    // D3 STUFF

    // layering: Simplex LongestPath CoffmanGraham
    // coord: Simplex Quad Greedy Center
    const dataviz = this.dataviz = new HierRDF(this.graph, {
        validateNode: function (node) {
	    // `this` goes missing because javascript
	    const s1 = schemes.map(x => dataviz.rewriteUUID(x));
	    const s2 = getSchemes(node.subject).map(x => dataviz.rewriteUUID(x));
	    // console.log(s1, s2);
	    if (s1.some(s => s2.some(x => x.equals(s)))) {
		//if ([ibis('Network'), skos('node.type
		if (!isEntity) return true;
		// console.log(node);

		// returns the node if it's not the only one
		// return node.neighbours.length > 0 ? true : test(node.type);
		return test(node.type);
	    }
	    return false;
        },
        validateEdge: function (source, target) {
            //return true;
            if (!isEntity) return true;
            return test(source.type) || test(target.type);
        },
    }, {
        preserveAspectRatio: 'xMidYMid meet', layering: 'Simplex',
        coord: 'Simplex', radius: 5, hyperbolic: true });

    // install the window onload XXX also this conditional sucks

    const postamble = () => {
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
		// console.log(elem);
		elem.addEventListener('mouseenter', OMO);
		elem.addEventListener('mouseleave', OMO);
	    });
    };

    if (document.getElementById('force'))
        this.dataviz.installFetchOnLoad(schemes, '#force', postamble);
    else console.log("wah wah link not found");

    return true;
});

document.addEventListener('readystatechange', function (e) {
    if (this.readyState == 'interactive') {
	console.log('state changed to interactive; now loading graph');
	const ev = new Event('load-graph');
	this.dispatchEvent(ev);
    }
});

window.addEventListener('load', function () {
    // XXX i'm sure the rdf thingy has this already
    const classes = 'Issue Position Argument'.split(/\s+/).map(
        (i) => `https://vocab.methodandstructure.com/ibis#${i}`
    ).concat(['http://www.w3.org/2004/02/skos/core#Concept']);

    const focus = e => {
        console.log(e);

        const form = e.target.form;
        const text = form['$ label'];
        const list = text.list;

        if (list) {
            console.log(list);
            const options = list.querySelectorAll('option');
            // and then what
        }
    };

    const blur = e => {
        // uncheck
        console.log(e);

        const form = e.currentTarget;
        let radios = form['$ type'];

        if (!e.relatedTarget || e.relatedTarget.form !== form) {
            if (radios instanceof RadioNodeList) radios = Array.from(radios);
            else radios = [radios];

            radios.forEach(r => r.checked = false);

            form.removeAttribute('about');

            console.log(radios);
        }
    };

    const escape = e => {
        if (e.key === 'Escape') {
            console.log(e);
            e.target.blur();
            e.currentTarget.blur();
        }
        return true;
    };

    const handleAutoFill = e => {
        if (!e.isTrusted) return;

        const input = e.target;
        const form  = input.form;
        const list  = input.list;

        // console.log('lol', e);

        const complies = e instanceof InputEvent;
        let value  = null;
        let option = null;

        const newInputs = Array.from(form.querySelectorAll('input.new'));
        const existing  = Array.from(form.querySelectorAll('input.existing'));

        if (!complies || e.inputType === 'insertReplacementText') {
            value  = input.value;
            option = list.querySelector(`option[value="${value}"]`);

            console.log('option', option);

	    // XXX THIS WHOLE existing[0] BUSINESS IS BAD

            if (option) {
                input.value = option.label;
                existing[0].disabled = false;
                existing[0].value = value;
                newInputs.forEach(i => i.disabled = true);
            }
        }
        else {
            console.log('putting back to "new"');
            // put it back
            existing[0].value = null;
            existing[0].disabled = true;
            const type = form.getAttribute('about');
            newInputs.forEach(i => {
                i.disabled = false;
                if (i.classList.contains('label') &&
                    i.getAttribute('about') !== type) i.disabled = true;
            });
        }
    };

    const clickRadio = e => {
        console.log(e);

        //e.preventDefault();
        e.stopPropagation();

        //const input = new InputEvent('input');

        //e.target.dispatchEvent(input);

        e.target.click();
        // return true;
    };

    const typeSelect = e => {
        console.log(e);
        const input = e.target;
        const form  = input.form;
        const text  = form['$ label'];
        const list  = text.list;

        form.setAttribute('about', input.value);

        if (list) {
            Array.from(list.querySelectorAll('option')).forEach(o => {
                const type = o.getAttribute('typeof');

                if (type !== input.value) o.disabled = true;
                else o.disabled = false;
            });
        }
    };

    const selector = 'section.relations > section > form';
    const forms    = this.document.querySelectorAll(selector);

    Array.from(forms).forEach(form => {

        // console.log(form);
        form.addEventListener('focusin',  focus,  false);
        form.addEventListener('focusout', blur,   false);
        form.addEventListener('keydown',  escape, true);

        const radios = Array.from(form.querySelectorAll('input[type="radio"]'));

        radios.forEach(r => {
            r.addEventListener('mousedown', clickRadio);
            // r.addEventListener('input', typeSelect);
            r.addEventListener('change', typeSelect);
        });

        // form['= rdf:value'].addEventListener('change', change, false);
        // form['= rdf:value'].addEventListener('select', change, false);
        form['$ label'].addEventListener('input', handleAutoFill, false);

    });

    const overlayOn = function (e) {
	e.cancelBubble = true;
	e.preventDefault();
	const ov = document.getElementById('scheme-list');
	ov.classList.add('open');

	return true;
    };
    const overlayOff = function (e) {
	const ov = document.getElementById('scheme-list');
	if (ov && ov.classList.contains('open')) {
	    e.preventDefault();
	    ov.classList.remove('open');
	}

	return true;
    };

    // open the panel
    document.getElementById('scheme-collapsed')?.addEventListener(
	'click', overlayOn);
    // add this to the popout that does nothing but kill the bubbling
    // so the next one doesn't fire
    document.getElementById('scheme-list')?.addEventListener(
	'click', e => e.cancelBubble = true);
    // click anywhere but the panel itself to dismiss it
    window.addEventListener('click', overlayOff);

    return true;
});
