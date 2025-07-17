<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:html="http://www.w3.org/1999/xhtml"
		xmlns:cgto="https://vocab.methodandstructure.com/graph-tool#"
                xmlns:rdfa="http://www.w3.org/ns/rdfa#"
                xmlns:xc="https://makethingsmakesense.com/asset/transclude#"
                xmlns:str="http://xsltsl.org/string"
                xmlns:uri="http://xsltsl.org/uri"
		xmlns:x="urn:x-dummy:"
		xmlns="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="html str uri rdfa xc x">

<xsl:import href="/asset/rdfa-util"/>

<xsl:output
  method="xml" media-type="application/xhtml+xml"
  indent="yes" omit-xml-declaration="no"
  encoding="utf-8" doctype-public=""/>

<x:doc>
  <h1>Collaborative Graph Tool Space</h1>
  <p>This template manages what is effectively the <q>home page</q> for collaborative graph tools like <a href="https://senseatlas.net/">Sense Atlas</a>.</p>
</x:doc>

<!-- too bad firefox still has no namespace:: axis -->
<xsl:variable name="RDF"   select="$rdfa:RDF-NS"/>
<xsl:variable name="RDFS"  select="$rdfa:RDFS-NS"/>
<xsl:variable name="DCT"   select="'http://purl.org/dc/terms/'"/>
<xsl:variable name="CGTO"  select="'https://vocab.methodandstructure.com/graph-tool#'"/>
<xsl:variable name="IBIS"  select="'https://vocab.methodandstructure.com/ibis#'"/>
<xsl:variable name="SIOC"  select="'http://rdfs.org/sioc/ns#'"/>
<xsl:variable name="SIOCT" select="'http://rdfs.org/sioc/types#'"/>
<xsl:variable name="SKOS"  select="'http://www.w3.org/2004/02/skos/core#'"/>
<xsl:variable name="XHV"   select="'http://www.w3.org/1999/xhtml/vocab#'"/>
<xsl:variable name="XSD"   select="$rdfa:XSD-NS"/>

<x:doc>
  <h2>Metadata</h2>
</x:doc>

<xsl:template match="html:head" mode="rdfa:head-extra">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>

  <!-- XXX get rid of this lol -->
  <link rel="stylesheet" type="text/css" href="/type/roboto"/>
  <link rel="stylesheet" type="text/css" href="/type/font-awesome"/>
  <link rel="stylesheet" type="text/css" href="/type/noto-sans-symbols2"/>
  <link rel="stylesheet" type="text/css" href="/asset/cgto/style"/>
  <script type="text/javascript" src="/asset/utilities"></script>
  <script type="text/javascript" src="/asset/rdf"></script>
  <script type="text/javascript" src="/asset/rdf-viz"></script>
  <script type="text/javascript" src="/asset/markup-mixup"></script>
  <script type="text/javascript" src="/asset/complex"></script>
  <script type="text/javascript" src="/asset/d3"></script>
  <script type="text/javascript" src="/asset/sense-atlas"></script>
  <script type="text/javascript" src="/asset/hierarchical"></script>
  <script type="text/javascript" src="/asset/force-directed"></script>
  <script type="text/javascript" src="/asset/cgto/scripts"></script>

</xsl:template>

<x:doc>
  <h2>Main body</h2>
</x:doc>

<xsl:template match="html:body" mode="rdfa:body-content">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:if test="not(@xml:lang)">
    <xsl:attribute name="xml:lang">en</xsl:attribute>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="html:main">
      <xsl:apply-templates select="html:header|html:main|html:footer">
        <xsl:with-param name="base" select="$base"/>
        <xsl:with-param name="resource-path" select="$resource-path"/>
        <xsl:with-param name="rewrite" select="$rewrite"/>
        <xsl:with-param name="main" select="$main"/>
        <xsl:with-param name="heading" select="$heading"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates>
        <xsl:with-param name="base" select="$base"/>
        <xsl:with-param name="resource-path" select="$resource-path"/>
        <xsl:with-param name="rewrite" select="$rewrite"/>
        <xsl:with-param name="main" select="$main"/>
        <xsl:with-param name="heading" select="$heading"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="html:main">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="true()"/>
  <xsl:param name="heading" select="0"/>

  <main>
    <xsl:apply-templates select="@*" mode="xc:attributes">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="resource-path" select="$resource-path"/>
      <xsl:with-param name="rewrite" select="$rewrite"/>
    </xsl:apply-templates>

    <xsl:call-template name="cgto:main-navigation">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="resource-path" select="$resource-path"/>
      <xsl:with-param name="rewrite" select="$rewrite"/>
      <xsl:with-param name="main" select="true()"/>
      <xsl:with-param name="heading" select="$heading"/>
    </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="resource-path" select="$resource-path"/>
      <xsl:with-param name="rewrite" select="$rewrite"/>
      <xsl:with-param name="main" select="true()"/>
      <xsl:with-param name="heading" select="$heading"/>
    </xsl:apply-templates>
  </main>
</xsl:template>

<xsl:template name="cgto:main-navigation">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="true()"/>
  <xsl:param name="heading" select="0"/>

  <nav>
    <h1>Explore Sense Atlas:</h1>
    <xsl:apply-templates select="/html:html/html:body" mode="cgto:enter-site">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="resource-path" select="$resource-path"/>
      <xsl:with-param name="rewrite" select="$rewrite"/>
      <xsl:with-param name="main" select="$main"/>
      <xsl:with-param name="heading" select="$heading"/>
    </xsl:apply-templates>
  </nav>
</xsl:template>

<xsl:template match="html:body" mode="cgto:enter-site">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:variable name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="index">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="predicate" select="concat($CGTO, 'index')"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="user">
    <xsl:if test="string-length(normalize-space($index))">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="subject" select="$index"/>
      <xsl:with-param name="predicate" select="concat($CGTO, 'user')"/>
      <xsl:with-param name="traverse" select="true()"/>
    </xsl:apply-templates>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="contents">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="predicate" select="concat($SIOC, 'space_of')"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:message>subject: <xsl:value-of select="$subject"/> index: <xsl:value-of select="$index"/> user: <xsl:value-of select="$user"/></xsl:message>

  <xsl:variable name="state">
    <xsl:if test="string-length($user)">
      <xsl:variable name="_">
        <xsl:apply-templates select="." mode="rdfa:object-resources">
	  <xsl:with-param name="subject" select="$user"/>
	  <xsl:with-param name="predicate" select="concat($CGTO, 'state')"/>
	  <xsl:with-param name="traverse" select="true()"/>
        </xsl:apply-templates>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="." mode="rdfa:subject-resources">
	  <xsl:with-param name="object" select="$user"/>
	  <xsl:with-param name="predicate" select="concat($CGTO, 'owner')"/>
	  <xsl:with-param name="traverse" select="true()"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:call-template name="str:safe-first-token">
        <xsl:with-param name="tokens">
          <xsl:call-template name="str:token-intersection">
            <xsl:with-param name="left" select="$contents"/>
            <xsl:with-param name="right" select="$_"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>

  <!-- XXX modal to check for foaf:name? -->

  <xsl:choose>
    <xsl:when test="string-length($user) and not(string-length($state))">
      <p>state modal goes here</p>
    </xsl:when>
    <xsl:otherwise>
      <!-- no user; show list -->
      <xsl:apply-templates select="." mode="cgto:plain-list">
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="property" select="concat($SIOC, 'space_of')"/>
        <!-- note the spaces you ass, that's why it wasn't showing up -->
        <xsl:with-param name="types" select="concat($IBIS, 'Network ', $SKOS, 'ConceptScheme ' , $SIOCT, 'AddressBook')"/>
        <xsl:with-param name="label-prop" select="concat($SKOS, 'prefLabel')"/>
        <xsl:with-param name="can-write" select="string-length($user)"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<x:doc>
  <h2><code>cgto:plain-list</code></h2>
  <p>List</p>
</x:doc>

<xsl:template match="html:*" mode="cgto:plain-list">
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="property">
    <xsl:message terminate="yes">`property` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="types">
    <xsl:message terminate="yes">`types` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="label-prop" select="concat($RDFS, 'label')"/>
  <xsl:param name="can-write" select="false()"/>

  <xsl:variable name="resources">
    <xsl:variable name="_">
      <xsl:apply-templates select="." mode="rdfa:object-resources">
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="predicate" select="$property"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($_) and string-length(normalize-space($types))">
        <xsl:apply-templates select="." mode="rdfa:filter-by-type">
          <xsl:with-param name="subjects" select="$_"/>
          <xsl:with-param name="classes" select="$types"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$_"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="property-curie">
    <xsl:call-template name="rdfa:make-curie">
      <xsl:with-param name="uri" select="$property"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="string-length($resources) or $can-write">
    <ul rel="{$property-curie}">
      <xsl:call-template name="cgto:plain-list-items">
        <xsl:with-param name="resources" select="$resources"/>
        <xsl:with-param name="label-prop" select="$label-prop"/>
      </xsl:call-template>
      <xsl:if test="$can-write">
        <li>
          <form xsl:use-attribute-sets="cgto:form-post-self">
            <input type="hidden" name="$ SUBJECT $" value="$NEW_UUID_URN"/>
            <input type="hidden" name="! sioc:space_of :" value="{$subject}"/>
            <select name="rdf:type :">
              <option value="ibis:Network">IBIS Network</option>
              <option value="skos:ConceptScheme">Concept Scheme</option>
              <option value="sioct:AddressBook">Address Book</option>
            </select>
            <input type="text" name="= skos:prefLabel" placeholder="Name it&#x2026;"/>
            <button class="fa fa-plus"/>
          </form>
        </li>
      </xsl:if>
    </ul>
  </xsl:if>
</xsl:template>

<x:doc>
  <h3>cgto:plain-list-items</h3>
</x:doc>

<xsl:template name="cgto:plain-list-items">
  <xsl:param name="resources">
    <xsl:message terminate="yes">`resources` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="label-prop" select="concat($RDFS, 'label')"/>

  <xsl:variable name="first">
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$resources"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="string-length($first)">
    <xsl:variable name="types">
      <xsl:call-template name="rdfa:make-curie-list">
        <xsl:with-param name="list">
          <xsl:apply-templates select="." mode="rdfa:object-resources">
            <xsl:with-param name="subject" select="$first"/>
            <xsl:with-param name="predicate" select="$rdfa:RDF-TYPE"/>
          </xsl:apply-templates>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="label-prop-curie">
      <xsl:call-template name="rdfa:make-curie">
        <xsl:with-param name="uri" select="$label-prop"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="label-raw">
      <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
        <xsl:with-param name="subject" select="$first"/>
        <xsl:with-param name="predicate" select="$label-prop"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="label" select="substring-before($label-raw, $rdfa:UNIT-SEP)"/>
    <xsl:variable name="label-type">
      <xsl:if test="not(starts-with(substring-after($label-raw, $rdfa:UNIT-SEP), '@'))">
        <xsl:value-of select="substring-after($label-raw, $rdfa:UNIT-SEP)"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="label-lang">
      <xsl:if test="starts-with(substring-after($label-raw, $rdfa:UNIT-SEP), '@')">
        <xsl:value-of select="substring-after($label-raw, concat($rdfa:UNIT-SEP, '@'))"/>
      </xsl:if>
    </xsl:variable>

    <li>
      <a href="{$first}">
        <xsl:if test="string-length($types)">
          <xsl:attribute name="typeof"><xsl:value-of select="$types"/></xsl:attribute>
        </xsl:if>
        <span property="{$label-prop-curie}">
          <xsl:choose>
            <xsl:when test="string-length($label-lang)">
              <xsl:attribute name="xml:lang">
                <xsl:value-of select="$label-lang"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="string-length($label-type)">
              <xsl:attribute name="datatype">
                <xsl:call-template name="rdfa:make-curie">
                  <xsl:with-param name="uri" select="$label-type"/>
                </xsl:call-template>
              </xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <xsl:value-of select="$label"/>
        </span>
      </a>
    </li>
    <xsl:variable name="rest" select="substring-after(normalize-space($resources), ' ')"/>
    <xsl:if test="string-length($rest)">
      <xsl:call-template name="cgto:plain-list-items">
        <xsl:with-param name="resources" select="$rest"/>
        <xsl:with-param name="label-prop" select="$label-prop"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:if>
</xsl:template>

<x:doc>
  <h2>cgto:editable-resource-list</h2>
  <p>This is tentatively going to be moved to the CGTO template. The goal is to create a <code>&lt;ul&gt;</code> of resources connected by a given predicate, and such that the last entry in the list is a form to add a new entry.</p>
</x:doc>

<!-- XXX make these part of CGTO -->

<xsl:template name="cgto:editable-resource-list">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="predicate">
    <xsl:message terminate="yes">`predicate` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="resources">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="predicate" select="$predicate"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="new-type">
    <xsl:message terminate="yes">`new-type` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="label-prop" select="concat($RDF, 'value')"/>
  <xsl:param name="datalist-id"/>
  <xsl:param name="prefixes"/>
  <xsl:param name="can-write" select="false()"/>

  <xsl:variable name="actual-prefixes">
    <xsl:variable name="_">
      <xsl:apply-templates select="." mode="rdfa:prefix-stack"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="string-length(normalize-space($prefixes))">
        <xsl:apply-templates select="." mode="rdfa:merge-prefixes">
          <xsl:with-param name="prefixes" select="$_"/>
          <xsl:with-param name="with" select="$prefixes"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$_"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="p-curie">
    <xsl:call-template name="rdfa:make-curie">
      <xsl:with-param name="uri" select="$predicate"/>
      <xsl:with-param name="prefixes" select="$actual-prefixes"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="c-curie">
    <xsl:call-template name="rdfa:make-curie">
      <xsl:with-param name="uri" select="$new-type"/>
      <xsl:with-param name="prefixes" select="$actual-prefixes"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="lprop-curie">
    <xsl:call-template name="rdfa:make-curie">
      <xsl:with-param name="uri" select="$label-prop"/>
      <xsl:with-param name="prefixes" select="$actual-prefixes"/>
    </xsl:call-template>
  </xsl:variable>

  <ul>
    <!-- already added -->
    <xsl:call-template name="cgto:editable-resource-list-items">
      <xsl:with-param name="resources" select="$resources"/>
      <xsl:with-param name="predicate" select="$predicate"/>
      <xsl:with-param name="label-prop" select="$label-prop"/>
      <xsl:with-param name="prefixes" select="$actual-prefixes"/>
      <xsl:with-param name="can-write" select="$can-write"/>
    </xsl:call-template>

    <!-- add new / link existing -->
    <xsl:if test="$can-write">
    <li>
      <form method="POST" action="" accept-charset="utf-8">
        <input class="new" type="hidden" name="$ SUBJECT $" value="$NEW_UUID_URN"/>
        <input class="new" type="hidden" name="= rdf:type : $" value="{$new-type}"/>
        <input class="new label" type="hidden" about="{$c-curie}" disabled="disabled" name="= {$lprop-curie} $" value="$label"/>
        <input class="existing" type="hidden" disabled="disabled" name="{$p-curie} :"/>
        <input tabindex="0" type="text" name="$ label">
          <xsl:if test="$datalist-id">
            <xsl:attribute name="list"><xsl:value-of select="$datalist-id"/></xsl:attribute>
            <xsl:attribute name="autocomplete">off</xsl:attribute>
          </xsl:if>
        </input>
      </form>
    </li>
    </xsl:if>
  </ul>
</xsl:template>

<x:doc>
  <h3>cgto:editable-resource-list-items</h3>
  <p>what's this doing here?</p>
</x:doc>

<xsl:template name="cgto:editable-resource-list-items">
  <xsl:param name="resources"/>
  <xsl:param name="predicate"/>
  <xsl:param name="label-prop"/>
  <xsl:param name="prefixes"/>
  <xsl:param name="can-write" select="false()"/>

  <xsl:variable name="rs" select="normalize-space($resources)"/>

  <xsl:if test="string-length($rs)">

    <xsl:variable name="first">
      <xsl:call-template name="str:safe-first-token">
        <xsl:with-param name="tokens" select="$rs"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="p-curie">
      <xsl:call-template name="rdfa:make-curie">
        <xsl:with-param name="uri" select="$predicate"/>
        <xsl:with-param name="prefixes" select="$prefixes"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="type">
      <xsl:call-template name="rdfa:make-curie-list">
        <xsl:with-param name="list">
          <xsl:apply-templates select="." mode="rdfa:object-resources">
            <xsl:with-param name="subject" select="$first"/>
            <xsl:with-param name="predicate" select="$rdfa:RDF-TYPE"/>
          </xsl:apply-templates>
        </xsl:with-param>
        <xsl:with-param name="prefixes" select="$prefixes"/>
      </xsl:call-template>
    </xsl:variable>

    <li>
      <a rel="{$p-curie}" href="{$first}" typeof="{$type}">
        <span>
          <xsl:apply-templates select="." mode="cgto:literal-content">
            <xsl:with-param name="subject"   select="$first"/>
            <xsl:with-param name="predicate" select="$label-prop"/>
            <xsl:with-param name="prefixes"  select="$prefixes"/>
          </xsl:apply-templates>
        </span>
      </a>
      <xsl:if test="$can-write">
        <form method="POST" action="" accept-charset="utf-8">
          <button class="fa fa-times" name="- {$p-curie} :" value="{$first}"/>
        </form>
      </xsl:if>
    </li>

    <xsl:variable name="rest" select="substring-after($rs, ' ')"/>
    <xsl:if test="string-length($rest)">
      <xsl:call-template name="cgto:editable-resource-list-items">
        <xsl:with-param name="resources" select="$rest"/>
        <xsl:with-param name="predicate" select="$predicate"/>
        <xsl:with-param name="label-prop"   select="$label-prop"/>
        <xsl:with-param name="prefixes"  select="$prefixes"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:if>

</xsl:template>

<x:doc>
  <h3><code>cgto:literal-content</code></h3>
  <p>This template spits out some attributes and a text node. You supply the enclosing element and other attributes (but don't put a <code>property</code>, <code>datatype</code>, or <code>xml:lang</code> in it, or the template will blow up).</p>
  <dl>
    <dt><code>base</code></dt>
    <dd>You can pass in the <code>base href</code> to save it the effort of re-fetching it.</dd>
    <dt><code>prefixes</code></dt>
    <dd>Any additional prefixes that may not already be in the document, in the form of an RDFa <code>prefix</code> attribute, for CURIEs.</dd>
    <dt><code>subject</code></dt>
    <dd>Likewise the subject, or otherwise override if it's not the same as the base.</dd>
    <dt><code>predicate</code></dt>
    <dd>This is the only mandatory parameter, the predicate associated with the label.</dd>
    <dt><code>object</code></dt>
    <dd>This is the actual label, and will be derived from the subject and the predicate, but if overridden, the value passed in must be a raw literal with <code>$rdfa:UNIT-SEP</code> delimiting the language/datatype (whether it has one or not).</dd>
    <dt><code>content</code></dt>
    <dd>If non-empty, this will place the label content (if present) in the <code>content</code> attribute and create a text node with this content instead.</dd>
    <dt><code>noop</code></dt>
    <dd>This will place the URL of the subject if no label is found (unless the <code>content</code> parameter is set, then it's that).</dd>
  </dl>
</x:doc>

<xsl:template match="html:*" mode="cgto:literal-content">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="prefixes"/>
  <xsl:param name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="predicate">
    <xsl:message terminate="yes">`predicate` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="object">
    <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="predicate" select="$predicate"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="content"/>
  <xsl:param name="noop" select="false()"/>

  <xsl:choose>
    <xsl:when test="string-length($object)">
      <xsl:variable name="pfx">
        <xsl:apply-templates select="." mode="rdfa:merge-prefixes">
          <xsl:with-param name="with" select="prefixes"/>
        </xsl:apply-templates>
      </xsl:variable>

      <xsl:variable name="p-curie">
        <xsl:call-template name="rdfa:make-curie">
          <xsl:with-param name="uri" select="$predicate"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="label" select="substring-before($object, $rdfa:UNIT-SEP)"/>
      <xsl:variable name="label-type">
        <xsl:if test="not(starts-with(substring-after($object, $rdfa:UNIT-SEP), '@'))">
          <xsl:value-of select="substring-after($object, $rdfa:UNIT-SEP)"/>
        </xsl:if>
      </xsl:variable>
      <xsl:variable name="label-lang">
        <xsl:if test="starts-with(substring-after($object, $rdfa:UNIT-SEP), '@')">
          <xsl:value-of select="substring-after($object, concat($rdfa:UNIT-SEP, '@'))"/>
        </xsl:if>
      </xsl:variable>

      <xsl:attribute name="property"><xsl:value-of select="$p-curie"/></xsl:attribute>

      <xsl:if test="$label-type">
        <xsl:variable name="d-curie">
          <xsl:call-template name="rdfa:make-curie">
            <xsl:with-param name="uri" select="$label-type"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:attribute name="datatype"><xsl:value-of select="$label-type"/></xsl:attribute>
      </xsl:if>

      <xsl:if test="$label-lang">
        <xsl:attribute name="xml:lang"><xsl:value-of select="$label-lang"/></xsl:attribute>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="string-length($content)">
          <xsl:attribute name="content"><xsl:value-of select="$label"/></xsl:attribute>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$label"/></xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="string-length($content)">
      <xsl:value-of select="$content"/>
    </xsl:when>
    <xsl:when test="$noop"><xsl:value-of select="$subject"/></xsl:when>
  </xsl:choose>
</xsl:template>

<x:doc>
  <h3>cgto:select-focus</h3>
</x:doc>


<xsl:template match="html:*" mode="cgto:select-focus">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="state">
    <xsl:message terminate="yes">`state` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="focus">
    <xsl:message terminate="yes">`focus` parameter required</xsl:message>
  </xsl:param>

  <xsl:variable name="inventory">
    <xsl:variable name="_">
      <xsl:apply-templates select="." mode="cgto:find-inventories-by-class">
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="classes">
          <xsl:value-of select="concat($IBIS, 'Network')"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="concat($SKOS, 'ConceptScheme')"/>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>

    <!-- subtract existing foci from the inventory -->
    <xsl:call-template name="str:token-minus">
      <xsl:with-param name="tokens">
        <!-- just grab the raw inventory here; we don't use it elsewhere -->
        <xsl:apply-templates select="." mode="rdfa:find-relations">
          <xsl:with-param name="resources" select="$_"/>
          <xsl:with-param name="predicate" select="concat($SIOC, 'space_of')"/>
        </xsl:apply-templates>
      </xsl:with-param>
      <xsl:with-param name="minus" select="$focus"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:message><xsl:value-of select="$inventory"/></xsl:message>

  <xsl:if test="string-length($focus)">
    <section>
      <p>Resolve the conflict of multiple foci by specifying <em>exactly</em> one focus from those that have been erroneously selected:</p>
      <ul>
        <xsl:apply-templates select="." mode="cgto:focus-item">
          <xsl:with-param name="state" select="$state"/>
          <xsl:with-param name="items" select="$inventory"/>
        </xsl:apply-templates>
      </ul>
    </section>
    <hr/>
 </xsl:if>

  <!-- if it doesn't have a focus, we try to give it one (or make one) -->

  <xsl:if test="string-length($inventory)">
    <!-- if there *are* candidates for a focus, offer them for selection -->
    <section>
      <p>Pick a focus from other candidates found in the graph:</p>
      <ul>
        <xsl:apply-templates select="." mode="cgto:focus-item">
          <xsl:with-param name="state" select="$state"/>
          <xsl:with-param name="items" select="$inventory"/>
        </xsl:apply-templates>
      </ul>
    </section>

    <!-- or -->
    <hr/>
  </xsl:if>

  <!-- if there are no candidates for a focus, try to make one -->
  <section>
    <p>Create a new focus:</p>
    <form method="POST" action="" accept-charset="utf-8">
      <input type="hidden" name="$ new $" value="$NEW_UUID_URN"/>
      <input type="hidden" name="{$state} cgto:focus : $" value="$new"/>
      <select name="= $new rdf:type :">
        <option value="ibis:Network">Issue Network</option>
        <option value="skos:ConceptScheme">Concept Scheme</option>
      </select>
      <input type="text" name="= $new skos:prefLabel" placeholder="Name of new focus"/>
      <button class="fa fa-plus"></button>
    </form>
  </section>

</xsl:template>

<xsl:template match="html:*" mode="cgto:focus-item">
  <xsl:param name="state">
    <xsl:message terminate="yes">`state` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="items">
    <xsl:message terminate="yes">`items` parameter required</xsl:message>
  </xsl:param>

  <xsl:variable name="first">
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$items"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="doc">
    <xsl:call-template name="uri:document-for-uri">
      <xsl:with-param name="uri" select="$first"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="root" select="document($doc)/*"/>

  <xsl:variable name="types">
    <xsl:call-template name="rdfa:make-curie-list">
      <xsl:with-param name="node" select="$root"/>
      <xsl:with-param name="list">
        <xsl:apply-templates select="$root/html:body" mode="rdfa:object-resources">
          <xsl:with-param name="subject" select="$first"/>
          <xsl:with-param name="predicate" select="$rdfa:RDF-TYPE"/>
        </xsl:apply-templates>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="label">
    <xsl:apply-templates select="$root/html:body" mode="rdfa:object-literal-quick">
      <xsl:with-param name="subject" select="$first"/>
      <xsl:with-param name="predicate" select="concat($SKOS, 'prefLabel')"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="suffix" select="substring-after($label, $rdfa:UNIT-SEP)"/>

  <li about="{$first}" typeof="{$types}">
    <a property="skos:prefLabel" href="{$first}">
      <xsl:choose>
        <xsl:when test="contains($suffix, ':')">
          <xsl:attribute name="datatype"><xsl:value-of select="$suffix"/></xsl:attribute>
        </xsl:when>
        <xsl:when test="string-length($suffix)">
          <xsl:attribute name="xml:lang"><xsl:value-of select="$suffix"/></xsl:attribute>
        </xsl:when>
      </xsl:choose>
    <xsl:value-of select="substring-before($label, $rdfa:UNIT-SEP)"/></a>
    <form method="POST" action="" accept-charset="utf-8">
      <button class="fa fa-equals" name="= {$state} cgto:focus :" value="{$first}"/>
    </form>
  </li>

  <xsl:variable name="rest" select="substring-after(normalize-space($items), ' ')"/>

  <xsl:if test="string-length($rest)">
    <xsl:apply-templates select="." mode="cgto:focus-item">
      <xsl:with-param name="items" select="$rest"/>
    </xsl:apply-templates>
  </xsl:if>

</xsl:template>

<x:doc>
  <h3>cgto:show-focus</h3>
</x:doc>

<xsl:template match="html:*" mode="cgto:show-focus">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
  <xsl:param name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="debug" select="false()"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="focus">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="predicate" select="concat($CGTO, 'focus')"/>
    </xsl:apply-templates>
  </xsl:param>

  <xsl:variable name="others">
    <xsl:call-template name="str:token-minus">
      <xsl:with-param name="tokens">
        <xsl:apply-templates select="." mode="rdfa:object-resources">
          <xsl:with-param name="subject" select="$subject"/>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="predicate" select="concat($SIOC, 'space_of')"/>
        </xsl:apply-templates>
      </xsl:with-param>
      <xsl:with-param name="minus" select="$focus"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:apply-templates select="." mode="cgto:space-cartouche">
    <xsl:with-param name="resources" select="$focus"/>
        <xsl:with-param name="relation" select="'cgto:focus'"/>
  </xsl:apply-templates>
  <xsl:if test="string-length(normalize-space($others))">
    <xsl:apply-templates select="." mode="cgto:space-cartouche">
      <xsl:with-param name="resources" select="$others"/>
      <xsl:with-param name="relation" select="'sioc:space_of'"/>
    </xsl:apply-templates>
  </xsl:if>

</xsl:template>

<x:doc>
  <h3>space-cartouche</h3>
</x:doc>

<xsl:template match="html:*" mode="cgto:space-cartouche">
  <xsl:param name="resources">
    <xsl:message terminate="yes">`resources` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="relation">
    <xsl:message terminate="yes">`relation` parameter required</xsl:message>
  </xsl:param>

  <xsl:variable name="first">
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$resources"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="doc">
    <xsl:call-template name="uri:document-for-uri">
      <xsl:with-param name="uri" select="$first"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="root" select="document($doc)/*"/>

  <xsl:variable name="types">
    <xsl:call-template name="rdfa:make-curie-list">
      <xsl:with-param name="list">
        <xsl:apply-templates select="$root" mode="rdfa:object-resources">
          <xsl:with-param name="subject" select="$first"/>
          <xsl:with-param name="predicate" select="$rdfa:RDF-TYPE"/>
        </xsl:apply-templates>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="title" select="$root/html:head/html:title"/>

  <xsl:variable name="entities">
    <xsl:apply-templates select="$root" mode="rdfa:object-resources">
      <xsl:with-param name="subject" select="$first"/>
      <xsl:with-param name="predicate" select="$rdfa:RDF-TYPE"/>
    </xsl:apply-templates>
  </xsl:variable>

  <a rel="{$relation}" href="{$first}" typeof="{$types}">
    <h1 property="{$title/@property}"><xsl:value-of select="normalize-space($title)"/></h1>
  </a>

  <xsl:variable name="rest" select="substring-after(normalize-space($resources), ' ')"/>
  <xsl:if test="string-length($rest)">
    <xsl:apply-templates select="." mode="cgto:space-cartouche">
      <xsl:with-param name="resources" select="$rest"/>
      <xsl:with-param name="relation" select="$relation"/>
    </xsl:apply-templates>
  </xsl:if>

</xsl:template>

<!-- uhh this is gonna have to be moved -->

<xsl:template match="html:body" mode="cgto:Error">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
  <xsl:param name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="debug" select="false()"/>
    </xsl:apply-templates>
  </xsl:param>

  <xsl:variable name="top">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="predicate" select="'http://www.w3.org/1999/xhtml/vocab#top'"/>
    </xsl:apply-templates>
  </xsl:variable>

<main>
  <!-- get the title -->
  <h1><xsl:value-of select="../html:head/html:title"/></h1>

  <!-- get all the cgto:Space entities -->

    <!--
        remember we're seeing this "error" because there's either no
        cgto:Space at all in the graph or at least none that are
        attached to the root (and if there are more than one, then *only*
        one is to be designated as the root)

        anyway probably a table?
    -->
    <form method="POST" action="" accept-charset="utf-8">
    <table>
      <thead>
        <tr>
          <th>Space</th>
          <th>Make Active</th>
        </tr>
      </thead>
      <tbody>
        <!-- put the existing ones here -->
        <tr>
          <td>
            <input type="hidden" name="$ new $" value="$NEW_UUID_URN"/>
            <input type="text" name="$new dct:title" placeholder="Give a name for the new space"/>
          </td>
          <td>
            <input type="hidden" name="$new rdf:type :" value="cgto:Space"/>
            <button class="fa fa-plus" name="= $new ci:canonical :" value="{$top}"/>
          </td>
        </tr>
      </tbody>
    </table>
    </form>
  </main>

</xsl:template>

<x:doc>
  <h2>find-inventories-by-class</h2>
</x:doc>

<xsl:template match="html:*" mode="cgto:find-inventories-by-class">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="debug" select="false()"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="classes">
    <xsl:message terminate="yes">`classes` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="summaries">
    <xsl:apply-templates select="." mode="rdfa:find-relations">
      <xsl:with-param name="resources" select="$subject"/>
      <xsl:with-param name="predicate" select="concat($CGTO, 'by-class')"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="inferred" select="false()"/>

  <!--<xsl:message>lol summaries <xsl:value-of select="$summaries"/></xsl:message>-->

  <xsl:if test="string-length(normalize-space($summaries))">
    <xsl:variable name="observations">
      <xsl:variable name="_">
        <xsl:apply-templates select="." mode="rdfa:find-relations">
          <xsl:with-param name="resources" select="$summaries"/>
          <xsl:with-param name="predicate" select="concat($QB, 'dataSet')"/>
          <xsl:with-param name="reverse"   select="true()"/>
        </xsl:apply-templates>
      </xsl:variable>

      <!--<xsl:message>did this net anything? <xsl:value-of select="$_"/></xsl:message>-->

      <xsl:choose>
        <xsl:when test="string-length(normalize-space($classes))">
          <xsl:apply-templates select="." mode="rdfa:filter-by-predicate-object">
            <xsl:with-param name="subjects" select="$_"/>
            <xsl:with-param name="predicate" select="concat($CGTO, 'class')"/>
            <xsl:with-param name="object" select="$classes"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$_"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!--<xsl:message>observations: <xsl:value-of select="$observations"/></xsl:message>-->

    <xsl:variable name="p">
      <xsl:choose>
	<xsl:when test="$inferred">inferred</xsl:when>
	<xsl:otherwise>asserted</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:apply-templates select="." mode="rdfa:find-relations">
      <xsl:with-param name="resources" select="$observations"/>
      <xsl:with-param name="predicate" select="concat($CGTO, $p, '-subjects')"/>
    </xsl:apply-templates>

  </xsl:if>

</xsl:template>

<x:doc>
  <h2>cgto:find-inventories-by-class</h2>
  <p>XXX this can probably be replaced by something more generic.</p>
</x:doc>

<xsl:template match="html:*" mode="cgto:find-inventories-by-class">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="debug" select="false()"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="classes">
    <xsl:message terminate="yes">`classes` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="summaries">
    <xsl:apply-templates select="." mode="rdfa:find-relations">
      <xsl:with-param name="resources" select="$subject"/>
      <xsl:with-param name="predicate" select="concat($CGTO, 'by-class')"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="inferred" select="false()"/>

  <!--<xsl:message>lol summaries <xsl:value-of select="$summaries"/></xsl:message>-->

  <xsl:if test="string-length(normalize-space($summaries))">
    <xsl:variable name="observations">
      <xsl:variable name="_">
        <xsl:apply-templates select="." mode="rdfa:find-relations">
          <xsl:with-param name="resources" select="$summaries"/>
          <xsl:with-param name="predicate" select="concat($QB, 'dataSet')"/>
          <xsl:with-param name="reverse"   select="true()"/>
        </xsl:apply-templates>
      </xsl:variable>

      <!--<xsl:message>did this net anything? <xsl:value-of select="$_"/></xsl:message>-->

      <xsl:choose>
        <xsl:when test="string-length(normalize-space($classes))">
          <xsl:apply-templates select="." mode="rdfa:filter-by-predicate-object">
            <xsl:with-param name="subjects" select="$_"/>
            <xsl:with-param name="predicate" select="concat($CGTO, 'class')"/>
            <xsl:with-param name="object" select="$classes"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$_"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!--<xsl:message>observations: <xsl:value-of select="$observations"/></xsl:message>-->

    <xsl:variable name="p">
      <xsl:choose>
	<xsl:when test="$inferred">inferred</xsl:when>
	<xsl:otherwise>asserted</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:apply-templates select="." mode="rdfa:find-relations">
      <xsl:with-param name="resources" select="$observations"/>
      <xsl:with-param name="predicate" select="concat($CGTO, $p, '-subjects')"/>
    </xsl:apply-templates>

  </xsl:if>

</xsl:template>

<x:doc>
  <h3>attribute sets cgto:form-post and cgto:form-post-self</h3>
  <p>we use a lot of forms and this is the boilerplate, lol</p>
</x:doc>

<xsl:attribute-set name="cgto:form-post">
  <xsl:attribute name="method">POST</xsl:attribute>
  <xsl:attribute name="accept-charset">utf-8</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cgto:form-post-self" use-attribute-sets="cgto:form-post">
  <xsl:attribute name="action"/>
</xsl:attribute-set>

</xsl:stylesheet>
