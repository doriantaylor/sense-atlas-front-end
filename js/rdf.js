// repackage rdflib
import * as RDFLib from 'rdflib';

// XXX rewrite all this in typescript? get on that program?? lol

// pull everything out but the namespace function and the store
const { Namespace: origNSFunc, Store, ...rest } = RDFLib;

class _Namespace extends RDFLib.NamedNode {
    constructor (iri) {
        super(iri);
    }
}

function Namespace (iri, factory) {
    if (iri instanceof _Namespace) return iri;

    if (RDFLib.isNamedNode(iri)) iri = iri.value;
    else iri = iri.toString();

    const base = new _Namespace(iri);
    const callable = origNSFunc(iri, factory);

    return new Proxy(callable, {
        get: (target, prop, receiver) => {
            if (prop in base) return base[prop];
            // so [] works the same as ()
            return target(prop.toString());
        },
        getPrototypeOf: () => _Namespace.prototype,
        has: (target, prop) => true,
        apply: (target, thisArg, args) => target.apply(thisArg, args),
    });
};

class NSMap {
    constructor (initial) {
        // coerce object to thing
        initial ||= [];
        if (typeof initial == 'object' && !Array.isArray(initial))
            initial = Object.entries(initial);

        initial = initial.map(([k, v]) => [
            k.toString(), (v instanceof RDFLib.Namespace) ? v :
                RDFLib.Namespace(v.toString())]);

        this._fwd = new Map(initial);
        // this._rev = new Map(this._fwd.entries().map(([k, v]) => [v.value, k]));

        return new Proxy(this, {
            get: (target, prop, receiver) => {
                if (typeof prop === "symbol" || prop in target)
                    return Reflect.get(target, prop, receiver);

                // Map key exists
                if (target.has(prop)) return target.get(prop);

                return undefined;
            },

            set: (target, prop, value, receiver) => {
                target.set(prop, value);
                return true;
            },

            has: (target, prop) => target._fwd.has(prop),

            deleteProperty: (target, prop) => {
                if (target.has(prop)) return target.delete(prop);
                return undefined;
            },

            ownKeys: (target) => [...target._fwd.keys()],

            getOwnPropertyDescriptor: (target, prop) => {
                if (target._fwd.has(prop)) {
                    return {
                        enumerable: true,
                        configurable: true
                    };
                }
                return undefined;
            }
        });
    }

    get(key) {
        return this._fwd.get(key);
    }

    set(key, value) {
        // this._rev.set(value.toString(), key);
        value = (value instanceof _Namespace) ? value : Namespace(value);
        return this._fwd.set(key || '', value);
    }

    has(key) {
        return this._fwd.has(key);
    }

    delete(key) {
        return this._fwd.delete(key);
    }

    entries() {
        return this._fwd.entries();
    }

    keys() {
        return this._fwd.keys();
    }

    values() {
        return this._fwd.values();
    }

    toObject() {
        return Object.fromEntries(this._fwd);
    }

    abbreviate (uris, scalar = true) {
        // first we coerce the input into an array
        if (!Array.isArray(uris)) uris = [uris];

        uris = uris.map(uri => {
            uri = uri.value ? uri.value : uri.toString();

            let prefix = null, namespace = null;
            this._fwd.entries().forEach(([pfx, nsURI]) => {
                nsURI = nsURI('').value;
                if (uri.startsWith(nsURI)) {
                    if (!namespace || nsURI.length > namespace.length) {
                        prefix    = pfx;
                        namespace = nsURI;
                    }
                }
            });

            // bail out if there is no match
            if (prefix == null) return uri;

            // otherwise we have a curie (or slug potentially)
            const rest = uri.substring(namespace.length);
            return prefix == '' ? rest : [prefix, rest].join(':');
        });

        return scalar ? uris.join(' ') : uris;
    }

    expand (curie) {
        if (curie instanceof RDFLib.NamedNode) return curie;
        let [prefix, slug] = curie.split(':', 2);
        if (slug == undefined) {
            slug = prefix;
            prefix = '';
        }

        // console.log(this);

        if (this._fwd.has(prefix) !== undefined)
            return this._fwd.get(prefix)(slug);

        return curie;
    }

};

// i'm sure this is everywhere, lol
const RDFNS   = Namespace('http://www.w3.org/1999/02/22-rdf-syntax-ns#');
const RDFTYPE = RDFNS.type;

// for some reason doing it this way won't trip rollup into messing with `this`
const storeMixin =  {
    getResources(args) {
        const collect = {};
        if (args.fwd) {
            let fwd = Array.isArray(args.fwd) ? args.fwd : [args.fwd];
            fwd.forEach(p => {
                this.match(args.subject, p, args.object).forEach(st => {
                    if (!args.subject && RDFLib.isNamedNode(st.subject))
                        collect[st.subject.toString()] = st.subject;
                    if (!args.object && RDFLib.isNamedNode(st.object))
                        collect[st.object.toString()] = st.object;
                });
            });
        }
        if (args.rev) {
            let rev = Array.isArray(args.rev) ? args.rev : [args.rev];
            rev.forEach(p => {
                this.match(args.object, p, args.subject).forEach(st => {
                    // the subject is the object
                    if (!args.object && RDFLib.isNamedNode(st.subject))
                        collect[st.subject.toString()] = st.subject;
                    if (!args.subject && RDFLib.isNamedNode(st.object))
                        collect[st.object.toString()] = st.subject;
                });
            });
        }

        return Object.values(collect);
    },

    getLiteralSimple (subject, predicate) {
        const out = [];

        this.match(subject, predicate).forEach(stmt => {
            if (RDFLib.isLiteral(stmt.object)) out.push(stmt.object);
        });

        return out;
    },

    // create a new array with the intersection of the contents of
    // both; really should just be in the array prototype; not sure
    // what i was thinking when i made this or why it's here but
    // leaving it here for now
    intersect (left, right, fn) {
        fn ||= ((a, b) => a == b);
        return left.reduce(
            ((x, a) => right.some(b => fn(a, b)) ? (x.push(a), x) : x), []);
    },

    has (a, b) {
        return a.some(x => b.some(y => x.equals(y)));
    },

    getTypes (subject) {
        return this.getResources({ subject: subject, fwd: RDFTYPE });
    },

    hasTypes (subject, types) {
        if (!types) types = [];
        if (!Array.isArray(types)) types = [types];

        return this.has(this.getTypes(subject), types);
    },
};

// whatever, cram the mixin into Store's prototype
Object.assign(Store.prototype, storeMixin);

// aand back out
//export { RDF as default };
export default {
    ...rest,
    Store,
    Namespace,
    NSMap,
};
