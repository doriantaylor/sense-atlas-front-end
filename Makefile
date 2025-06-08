# DEFINITIONS
SHELL  = /bin/bash

NOOP   = true
NOECHO = @

CP    = cp -a
MD    = mkdir -p
RM    = rm
RMRF  = rm -rf
FIND  = find
CURL  = curl
NPM   = npm
PSASS = psass

SOURCE = source
TARGET = target

XSLT_ASSETS = transclude.xsl rdfa.xsl ibis.xsl
# SCSS_ASSETS = ibis.scss
JS_ASSETS   = complex.js d3.js rdf.js rdf-viz.js force-directed.js hierarchical.js cgto/scripts.js

GITHUB = https://raw.githubusercontent.com/doriantaylor
LOCAL  = $(HOME)/clients/me

# INITIAL TARGET

.PHONY: all clean

all: js css xslt fonts

clean:
	$(RMRF) $(TARGET)

$(TARGET):
	$(MD) $(TARGET)
	$(CP) $(SOURCE)/favicon.ico $(TARGET)

$(TARGET)/asset: $(TARGET)
	$(MD) $(TARGET)/asset

$(TARGET)/asset/cgto: $(TARGET)/asset
	$(MD) $(TARGET)/asset/cgto

$(TARGET)/asset/skos: $(TARGET)/asset
	$(MD) $(TARGET)/asset/skos

$(TARGET)/asset/ibis: $(TARGET)/asset
	$(MD) $(TARGET)/asset/ibis

$(TARGET)/asset/skos-ibis: $(TARGET)/asset
	$(MD) $(TARGET)/asset/skos-ibis

# OUT-OF-REPO XSLT

$(TARGET)/asset/transclude.xsl : $(TARGET)/asset
	@ if [ -f $(LOCAL)/xslt-transclusion/transclude.xsl ]; \
	then $(CP) $(LOCAL)/xslt-transclusion/transclude.xsl $@; \
	else curl -o $@ $(GITHUB)/xslt-transclusion/master/transclude.xsl ; fi

$(TARGET)/asset/rdfa.xsl : $(TARGET)/asset
	@ if [ -f $(LOCAL)/xslt-rdfa/rdfa.xsl ]; \
	then $(CP) $(LOCAL)/xslt-rdfa/rdfa.xsl $@; \
	else $(CURL) -o $@ $(GITHUB)/xslt-rdfa/master/rdfa.xsl ; fi

# OUR XSLT

$(TARGET)/asset/rdfa-util.xsl : $(TARGET)/asset/transclude.xsl $(TARGET)/asset/rdfa.xsl
	$(CP) $(SOURCE)/asset/rdfa-util.xsl $(TARGET)/asset

$(TARGET)/asset/cgto/space.xsl : $(TARGET)/asset/cgto $(TARGET)/asset/rdfa-util.xsl
	$(CP) $(SOURCE)/asset/cgto/space.xsl $(TARGET)/asset/cgto

$(TARGET)/asset/cgto/error.xsl : $(TARGET)/asset/cgto $(TARGET)/asset/rdfa-util.xsl
	$(CP) $(SOURCE)/asset/cgto/error.xsl $(TARGET)/asset/cgto

$(TARGET)/asset/skos/concept.xsl : $(TARGET)/asset/skos $(TARGET)/asset/cgto/space.xsl
	$(CP) $(SOURCE)/asset/skos/concept.xsl $(TARGET)/asset/skos

$(TARGET)/asset/skos/concept-scheme.xsl : $(TARGET)/asset/skos $(TARGET)/asset/cgto/space.xsl
	$(CP) $(SOURCE)/asset/skos/concept-scheme.xsl $(TARGET)/asset/skos

$(TARGET)/asset/ibis/entity.xsl : $(TARGET)/asset/ibis $(TARGET)/asset/skos/concept.xsl
	$(CP) $(SOURCE)/asset/ibis/entity.xsl $(TARGET)/asset/ibis

$(TARGET)/asset/ibis/network.xsl : $(TARGET)/asset/ibis $(TARGET)/asset/skos/concept-scheme.xsl
	$(CP) $(SOURCE)/asset/ibis/network.xsl $(TARGET)/asset/ibis

# $(TARGET)/asset/skos-ibis.xsl : $(TARGET)/asset/cgto.xsl $(TARGET)/asset/rdfa-util.xsl
# 	$(CP) $(SOURCE)/asset/skos-ibis.xsl $(TARGET)/asset

# $(TARGET)/transform.xsl : $(TARGET)/asset/rdfa-util.xsl $(TARGET)/asset/cgto.xsl $(TARGET)/asset/skos-ibis.xsl
# 	$(CP) $(SOURCE)/transform.xsl target

# xslt: clean-xslt $(TARGET)/transform.xsl $(TARGET)/asset/skos-ibis.xsl
xslt: clean-xslt \
	$(TARGET)/asset/cgto/space.xsl $(TARGET)/asset/cgto/error.xsl \
	$(TARGET)/asset/skos/concept.xsl $(TARGET)/asset/skos/concept-scheme.xsl \
	$(TARGET)/asset/ibis/entity.xsl $(TARGET)/asset/ibis/network.xsl

clean-xslt:
	$(FIND) $(TARGET)/ -type f -name \*.xsl -print0 | xargs -0 rm -f

# (S)CSS

clean-css:
	$(FIND) $(TARGET)/ -type f -name \*.css -print0 | xargs -0 rm -f

$(TARGET)/asset/cgto/style.css : $(TARGET)/asset/cgto
	$(PSASS) -t expanded -o $(TARGET)/asset/cgto/style.css $(SOURCE)/asset/cgto/style.scss

css: $(TARGET)/asset/cgto/style.css

# JAVASCRIPT

js/node_modules :
	cd js; npm install; cd -

$(TARGET)/asset/complex.js : $(TARGET)/asset js/node_modules
	$(CP) js/node_modules/complex.js/complex.js $(TARGET)/asset/complex.js

$(TARGET)/asset/d3.js : $(TARGET)/asset
	cd js; $(NPM) run build; cd -

$(TARGET)/asset/rdf.js : $(TARGET)/asset
	cd js; $(NPM) run build; cd -

$(TARGET)/asset/rdf-viz.js : $(TARGET)/asset
	cd js; $(NPM) run build; cd -

$(TARGET)/asset/force-directed.js : $(TARGET)/asset
	cd js; $(NPM) run build; cd -

$(TARGET)/asset/hierarchical.js : $(TARGET)/asset
	cd js; $(NPM) run build; cd -

$(TARGET)/asset/cgto/scripts.js : $(TARGET)/asset/cgto
	$(CP) $(SOURCE)/asset/cgto/scripts.js $(TARGET)/asset/cgto/

js: $(foreach x,$(JS_ASSETS),$(TARGET)/asset/$(x))

# FONTS

fonts : $(TARGET)/type

# XXX do a makefile for downloading/renaming these fonts
$(TARGET)/type :
	$(MD) $(TARGET)/type
	$(CP) $(LOCAL)/extranet-boilerplate/type/{roboto,font-awesome,noto-sans-symbols2}{,.css} $(TARGET)/type


# OTHER FILES

# OTHER TARGETS
