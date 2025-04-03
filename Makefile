# DEFINITIONS
SHELL  = /bin/bash

NOOP   = true
NOECHO = @

CP    = cp -a
MD    = mkdir -p
RM    = rm
RMRF  = rm -rf
CURL  = curl
NPM   = npm
PSASS = psass


XSLT_ASSETS = transclude.xsl rdfa.xsl ibis.xsl
# SCSS_ASSETS = ibis.scss
JS_ASSETS   = complex.js d3.js rdf.js rdf-viz.js force-directed.js hierarchical.js skos-ibis/scripts.js

GITHUB = https://raw.githubusercontent.com/doriantaylor
LOCAL  = $(HOME)/clients/me

# INITIAL TARGET

.PHONY: all clean

all: js css xslt fonts

clean:
	$(RMRF) target

target:
	$(MD) target
	$(CP) source/favicon.ico target

target/asset: target
	$(MD) target/asset

target/asset/skos-ibis: target/asset
	$(MD) target/asset/skos-ibis

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

target/asset/rdfa-util.xsl : target/asset/transclude.xsl target/asset/rdfa.xsl
	$(CP) source/asset/rdfa-util.xsl target/asset

target/asset/cgto.xsl : target/asset/rdfa-util.xsl
	$(CP) source/asset/cgto.xsl target/asset

target/asset/skos-ibis.xsl : target/asset/cgto.xsl target/asset/rdfa-util.xsl
	$(CP) source/asset/skos-ibis.xsl target/asset

target/transform.xsl : target/asset/rdfa-util.xsl target/asset/cgto.xsl target/asset/skos-ibis.xsl
	$(CP) source/transform.xsl target

xslt: clean-xslt target/transform.xsl target/asset/skos-ibis.xsl

clean-xslt:
	$(RM) -f target/asset/*.xsl target/*.xsl

# (S)CSS

target/asset/skos-ibis/style.css : target/asset/skos-ibis
	$(PSASS) -t expanded -o target/asset/skos-ibis/style.css source/asset/skos-ibis/style.scss

css: target/asset/skos-ibis/style.css

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

target/asset/skos-ibis/scripts.js : target/asset/skos-ibis
	$(CP) source/asset/skos-ibis/scripts.js target/asset/skos-ibis/

js: $(foreach x,$(JS_ASSETS),target/asset/$(x))

# FONTS

fonts : target/type

# XXX do a makefile for downloading/renaming these fonts
target/type :
	$(MD) target/type
	$(CP) $(LOCAL)/extranet-boilerplate/type/{roboto,font-awesome,noto-sans-symbols2}{,.css} target/type


# OTHER FILES

# OTHER TARGETS
