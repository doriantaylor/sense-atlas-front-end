// routines and event handlers common to all graph layouts

// in a perfect world we would just use DOMContentLoaded but the event
// doesn't fire correctly when XSLT is involved.

document.addEventListener('readystatechange', function () {
    if (this.readyState == 'interactive') {
	console.log('state changed to interactive; can now load graph');

        // might as well put this here
        const g = this.graph = RDF.graph(null, { storeClass: RDF.LiveStore });
        const ns = g.namespaces;

        // might as well add all the namespaces (they get coerced)
        ns.rdf   = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
        ns.rdfs  = 'http://www.w3.org/2000/01/rdf-schema#';
        ns.owl   = 'http://www.w3.org/2002/07/owl#';
        ns.xsd   = 'http://www.w3.org/2001/XMLSchema#';
        ns.xhv   = 'http://www.w3.org/1999/xhtml/vocab#';
        ns.skos  = 'http://www.w3.org/2004/02/skos/core#';
        ns.dct   = 'http://purl.org/dc/terms/';
        ns.foaf  = 'http://xmlns.com/foaf/0.1/';
        ns.org   = 'http://www.w3.org/ns/org#';
        ns.bibo  = 'http://purl.org/ontology/bibo/';
        ns.cgto  = 'https://vocab.methodandstructure.com/graph-tool#';
        ns.ibis  = 'https://vocab.methodandstructure.com/ibis#';
        ns.pm    = 'https://vocab.methodandstructure.com/process-model#';
        ns.ci    = 'https://vocab.methodandstructure.com/content-inventory#';
        ns.qb    = 'http://purl.org/linked-data/cube#';
        ns.gr    = 'http://purl.org/goodrelations/v1#';
        ns.sioc  = 'http://rdfs.org/sioc/ns#';
        ns.sioct = 'http://rdfs.org/sioc/types#';

        // you'd think we should make the rdfa go here but it fucks
        // with the cache for some reason

        // now fire the event
	const ev = new Event('can-load-graph');
	this.dispatchEvent(ev);
    }
});

window.addEventListener('load', function () {
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
            else if (typeof radios !== 'undefined') radios = [radios];
            else radios = [];

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

        // console.log(`list is ${list}`);

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
                existing[0].value = value;
                existing.forEach(e => e.disabled = false);
                newInputs.forEach(i => i.disabled = true);
            }
        }
        else {
            console.log('putting back to "new"');
            // put it back
            existing[0].value = null;
            existing.forEach(e => e.disabled = true);
            const type = form.getAttribute('about');
            newInputs.forEach(i => {
                i.disabled = false;
                if (i.classList.contains('label') &&
                    i.getAttribute('about') !== type) i.disabled = true;
            });
        }
    };

    // assuming this exists because merely selecting the radio button
    // (eg jogging the arrow keys) doesn't "click" it

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
                const types = (o.getAttribute('typeof') || '').trim().split(/\s+/);

                // console.debug(input.value, types);

                if (types.includes(input.value)) o.disabled = false;
                else o.disabled = true;
            });
        }
    };

    // attach the event listeners

    const selector = 'main > article form';
    const forms    = this.document.querySelectorAll(selector);

    Array.from(forms).forEach(form => {
        const label = form['$ label'];
        if (label && label.getAttribute('list')) {
            // console.log(form);
            form.addEventListener('focusin',  focus,  false);
            form.addEventListener('focusout', blur,   false);
            form.addEventListener('keydown',  escape, true);

            // this will do nothing if there aren't any
            const radios = Array.from(form.querySelectorAll('input[type="radio"]'));

            radios.forEach(r => {
                r.addEventListener('mousedown', clickRadio);
                // r.addEventListener('input', typeSelect);
                r.addEventListener('change', typeSelect);
            });

            label.addEventListener('input', handleAutoFill, false);
        }

    });

    // submit the form if you see an enter key with a control or meta
    // modifier and the value is valid
    const commitDateTime = function (e) {
        if (this.validity.valid) {
            if (e.code == 'Enter' && (e.metaKey || e.ctrlKey)) {
                // deal with event stuff
                e.preventDefault();
                e.stopPropagation();

                const now = new Date();

                // turns out this will fudge the local time representation
                // const val = new Date(Date.parse(this.value));

                // turns out actually that you can do this
                const val = this.valueAsDate;

                // note the date is in local time

                // okay try this?
                // this.formNoValidate = true;
                // this.form.noValidate = true;

                // set the type to text quickly
                this.type = 'text';

                // …and this will coerce the time zone to zulu already
                // this.setAttribute('value',val.toISOString());
                const offsetMs = now.getTimezoneOffset() * 60000;
                this.value = (new Date(val.valueOf() + offsetMs)).toISOString();

                console.log(`set datetime value to ${this.value}`);

                // so all there's left to do is:
                this.form.submit();
            }
            else console.log('waiting for an enter key…');
        }
        else console.log(`datetime value ${this.value} is invalid`);
    };

    Array.from(
        this.document.querySelectorAll('input[type="datetime-local"]')
    ).forEach(elem => {
        console.log(elem);

        // lol god
        let num = Date.parse(elem.getAttribute('value'));
        if (!isNaN(num)) {
            // get local time
            let now = new Date();

            // get tz offset
            let tzMs = now.getTimezoneOffset() * 60000;
            let val  = new Date(num - tzMs);

            let valStr = val.toISOString();

            elem.value = valStr.substring(0, valStr.lastIndexOf(':'));
        }

        elem.addEventListener('keydown', commitDateTime);
    });

    // these are for the concept scheme/issue network selector overlay
    // at the bottom of the screen

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
