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
RSYNC = rsync -avcq

SOURCE = source
TARGET = target

XSLT_ASSETS = transclude.xsl rdfa.xsl ibis.xsl
# SCSS_ASSETS = ibis.scss
JS_ASSETS   = complex.js d3.js rdf.js rdf-viz.js force-directed.js hierarchical.js utilities.js markup-mixup.js  cgto/scripts.js

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

$(TARGET)/asset/pm: $(TARGET)/asset
	$(MD) $(TARGET)/asset/pm

$(TARGET)/asset/sioc: $(TARGET)/asset
	$(MD) $(TARGET)/asset/sioc

$(TARGET)/asset/sioct: $(TARGET)/asset
	$(MD) $(TARGET)/asset/sioct

$(TARGET)/asset/foaf: $(TARGET)/asset
	$(MD) $(TARGET)/asset/foaf

$(TARGET)/asset/org: $(TARGET)/asset
	$(MD) $(TARGET)/asset/org

$(TARGET)/asset/ci: $(TARGET)/asset
	$(MD) $(TARGET)/asset/ci

$(TARGET)/asset/gr: $(TARGET)/asset
	$(MD) $(TARGET)/asset/gr

# $(TARGET)/asset/skos-ibis: $(TARGET)/asset
# 	$(MD) $(TARGET)/asset/skos-ibis

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

CGTO_XSLT  = space.xsl error.xsl
SKOS_XSLT  = concept.xsl concept-scheme.xsl
IBIS_XSLT  = entity.xsl position.xsl network.xsl
PM_XSLT    = goal.xsl task.xsl target.xsl
SIOC_XSLT  = container.xsl
SIOCT_XSLT = address-book.xsl
FOAF_XSLT  = agent.xsl person.xsl
ORG_XSLT   = organization.xsl organizational-unit.xsl organizational-collaboration.xsl role.xsl
CI_XSLT    = audience.xsl

$(TARGET)/asset/rdfa-util.xsl : $(TARGET)/asset/transclude.xsl $(TARGET)/asset/rdfa.xsl
	$(RSYNC) $(SOURCE)/asset/rdfa-util.xsl $(dir $@)

$(foreach x,$(CGTO_XSLT),$(TARGET)/asset/cgto/$(x)): $(TARGET)/asset/cgto $(TARGET)/asset/rdfa-util.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

$(foreach x,$(SKOS_XSLT),$(TARGET)/asset/skos/$(x)): $(TARGET)/asset/skos $(TARGET)/asset/cgto/space.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

$(TARGET)/asset/ibis/entity.xsl : $(TARGET)/asset/ibis $(TARGET)/asset/skos/concept.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

$(TARGET)/asset/ibis/position.xsl : $(TARGET)/asset/ibis $(TARGET)/asset/ibis/entity.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

$(TARGET)/asset/ibis/network.xsl : $(TARGET)/asset/ibis $(TARGET)/asset/skos/concept-scheme.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

$(foreach x,$(PM_XSLT),$(TARGET)/asset/pm/$(x)): $(TARGET)/asset/pm $(TARGET)/asset/ibis/entity.xsl
	$(RSYNC) $(shell echo -n "$@" | sed "s!$(TARGET)!$(SOURCE)!") $(dir $@)

$(TARGET)/asset/sioc/container.xsl : $(TARGET)/asset/sioc $(TARGET)/asset/cgto/space.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

$(TARGET)/asset/sioct/address-book.xsl : $(TARGET)/asset/sioct $(TARGET)/asset/sioc/container.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

$(TARGET)/asset/foaf/agent.xsl : $(TARGET)/asset/foaf $(TARGET)/asset/cgto/space.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

$(TARGET)/asset/foaf/person.xsl : $(TARGET)/asset/foaf $(TARGET)/asset/foaf/agent.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

$(TARGET)/asset/org/organization.xsl : $(TARGET)/asset/org $(TARGET)/asset/foaf/agent.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

$(TARGET)/asset/org/organizational-unit.xsl : $(TARGET)/asset/org $(TARGET)/asset/org/organization.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

$(TARGET)/asset/org/organizational-collaboration.xsl : $(TARGET)/asset/org $(TARGET)/asset/org/organization.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

$(TARGET)/asset/org/role.xsl : $(TARGET)/asset/org $(TARGET)/asset/skos/concept.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

$(TARGET)/asset/ci/audience.xsl : $(TARGET)/asset/org $(TARGET)/asset/skos/concept.xsl
	$(RSYNC) $(subst $(TARGET),$(SOURCE),$@) $(dir $@)

# $(TARGET)/asset/skos-ibis.xsl : $(TARGET)/asset/cgto.xsl $(TARGET)/asset/rdfa-util.xsl
# 	$(CP) $(SOURCE)/asset/skos-ibis.xsl $(TARGET)/asset

# $(TARGET)/transform.xsl : $(TARGET)/asset/rdfa-util.xsl $(TARGET)/asset/cgto.xsl $(TARGET)/asset/skos-ibis.xsl
# 	$(CP) $(SOURCE)/transform.xsl target

# xslt: clean-xslt $(TARGET)/transform.xsl $(TARGET)/asset/skos-ibis.xsl
xslt: clean-xslt $(foreach x,$(CGTO_XSLT),$(TARGET)/asset/cgto/$(x)) \
	$(foreach x,$(SKOS_XSLT),$(TARGET)/asset/skos/$(x)) \
	$(foreach x,$(IBIS_XSLT),$(TARGET)/asset/ibis/$(x)) \
	$(foreach x,$(PM_XSLT),$(TARGET)/asset/pm/$(x)) \
	$(foreach x,$(SIOC_XSLT),$(TARGET)/asset/sioc/$(x)) \
	$(foreach x,$(SIOCT_XSLT),$(TARGET)/asset/sioct/$(x)) \
	$(foreach x,$(FOAF_XSLT),$(TARGET)/asset/foaf/$(x)) \
	$(foreach x,$(ORG_XSLT),$(TARGET)/asset/org/$(x)) \
	$(foreach x,$(CI_XSLT),$(TARGET)/asset/ci/$(x))

clean-xslt:
	$(FIND) $(TARGET)/ -type f -name \*.xsl -print0 | xargs -0 rm -f

# (S)CSS

clean-css:
	$(FIND) $(TARGET)/ -type f -name \*.css -print0 | xargs -0 rm -f

$(TARGET)/asset/cgto/style.css : $(TARGET)/asset/cgto
	$(PSASS) -t expanded -o $(TARGET)/asset/cgto/style.css $(SOURCE)/asset/cgto/style.scss

css: clean-css $(TARGET)/asset/cgto/style.css

# JAVASCRIPT

js/node_modules :
	cd js; npm install; cd -

$(TARGET)/asset/complex.js : $(TARGET)/asset js/node_modules
	$(RSYNC) js/node_modules/complex.js/complex.js $(TARGET)/asset/complex.js

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

$(TARGET)/asset/utilities.js : $(TARGET)/asset
	$(RSYNC) $(SOURCE)/asset/utilities.js $(TARGET)/asset/

$(TARGET)/asset/cgto/scripts.js : $(TARGET)/asset/cgto
	$(RSYNC) $(SOURCE)/asset/cgto/scripts.js $(TARGET)/asset/cgto/

$(TARGET)/asset/markup-mixup.js : $(TARGET)/asset
	@ if [ -f $(LOCAL)/js-markup-mixup/markup-mixup.js ]; \
	then $(CP) $(LOCAL)/js-markup-mixup/markup-mixup.js $@; \
	else $(CURL) -o $@ $(GITHUB)/js-markup-mixup/main/markup-mixup.js ; fi

js: $(foreach x,$(JS_ASSETS),$(TARGET)/asset/$(x))

# FONTS

fonts : $(TARGET)/type

# XXX do a makefile for downloading/renaming these fonts
$(TARGET)/type :
	$(MD) $(TARGET)/type
	$(RSYNC) $(LOCAL)/extranet-boilerplate/type/{roboto,font-awesome,noto-sans-symbols2}{,.css} $(TARGET)/type/


# OTHER FILES

$(TARGET)/asset/*.jpeg : $(TARGET)/asset
	$(RSYNC) $(SOURCE)/asset/*.jpeg $(TARGET)/asset/

$(TARGET)/asset/*.png : $(TARGET)/asset
	$(RSYNC) $(SOURCE)/asset/*.png $(TARGET)/asset/

$(TARGET)/*.xhtml :

content: $(TARGET)/*.xhtml $(TARGET)/asset/*.jpeg $(TARGET)/asset/*.png
	$(RSYNC) $(SOURCE)/*.xhtml $(TARGET)/

# OTHER TARGETS
