# DEFINITIONS

NOOP   = true
NOECHO = @

CP   = cp -a
MD   = mkdir -p
RMRF = rm -rf
CURL = curl
NPM  = npm


XSLT_ASSETS = transclude.xsl rdfa.xsl ibis.xsl
SCSS_ASSETS = ibis.scss
JS_ASSETS   = complex.js d3.js rdf.js rdf-viz.js force-directed.js hierarchical.js

GITHUB = https://raw.githubusercontent.com/doriantaylor
LOCAL  = $(HOME)/clients/me

# INITIAL TARGET

.PHONY: all clean

all: js css xslt

clean:
	$(RMRF) target

target:
	$(MD) target

target/asset: target
	$(MD) target/asset

# OUT-OF-REPO XSLT

target/asset/transclude.xsl : target/asset
	@ if [ -f $(LOCAL)/xslt-transclusion/transclude.xsl ]; \
	then $(CP) $(LOCAL)/xslt-transclusion/transclude.xsl $@; \
	else curl -o $@ $(GITHUB)/xslt-transclusion/master/transclude.xsl ; fi

target/asset/rdfa.xsl : target/asset
	@ if [ -f $(LOCAL)/xslt-rdfa/rdfa.xsl ]; \
	then $(CP) $(LOCAL)/xslt-rdfa/rdfa.xsl $@; \
	else $(CURL) -o $@ $(GITHUB)/xslt-rdfa/master/rdfa.xsl ; fi

# OUR XSLT

target/asset/ibis.xsl : target/asset
	$(CP) source/asset/ibis.xsl target/asset

target/transform.xsl : target/asset
	$(CP) source/transform.xsl target

xslt: target/asset/transclude.xsl target/asset/rdfa.xsl target/asset/ibis.xsl target/transform.xsl

# (S)CSS

target/asset/ibis.css : target/asset
	$(PSASS) -t expanded -o target/asset/ibis.css source/asset/ibis.scss

css: target/asset/ibis.css

# JAVASCRIPT

js/node_modules :
	cd js; npm install; cd -

target/asset/complex.js : target/asset js/node_modules
	$(CP) js/node_modules/complex.js/complex.js target/asset/complex.js

target/asset/d3.js : target/asset
	cd js; $(NPM) run build; cd -

target/asset/rdf.js : target/asset
	cd js; $(NPM) run build; cd -

target/asset/rdf-viz.js : target/asset
	cd js; $(NPM) run build; cd -

target/asset/force-directed.js : target/asset
	cd js; $(NPM) run build; cd -

target/asset/hierarchical.js : target/asset
	cd js; $(NPM) run build; cd -

js: $(foreach x,$(JS_ASSETS),target/asset/$(x))

# FONTS


# OTHER FILES

# OTHER TARGETS
