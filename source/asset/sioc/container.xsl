<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:html="http://www.w3.org/1999/xhtml"
		xmlns:ibis="https://vocab.methodandstructure.com/ibis#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
		xmlns:cgto="https://vocab.methodandstructure.com/graph-tool#"
		xmlns:pm="https://vocab.methodandstructure.com/process-model#"
                xmlns:sioc="http://rdfs.org/sioc/ns#"
                xmlns:sioct="http://rdfs.org/sioc/types#"
		xmlns:x="urn:x-dummy:"
                xmlns:rdfa="http://www.w3.org/ns/rdfa#"
                xmlns:xc="https://makethingsmakesense.com/asset/transclude#"
                xmlns:str="http://xsltsl.org/string"
                xmlns:uri="http://xsltsl.org/uri"
		xmlns="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="html str uri rdfa xc x">

<xsl:import href="/asset/skos/concept-scheme"/>

<xsl:output
  method="xml" media-type="application/xhtml+xml"
  indent="yes" omit-xml-declaration="no"
  encoding="utf-8" doctype-public=""/>

<xsl:variable name="SIOC" select="'http://rdfs.org/sioc/ns#'"/>
<xsl:variable name="SIOCT" select="'http://rdfs.org/sioc/types#'"/>

<x:doc>
  <h1><abbr>SIOC</abbr> Containers</h1>
  <p>The container is just that: a container. You put stuff in it with subproperties of <a href="http://purl.org/dc/terms/hasPart">dct:hasPart</a>. There are a number of subtypes of containers in <a href="http://rdfs.org/sioc/types#">SIOC types</a>.</p>
</x:doc>

<xsl:template match="html:body" mode="rdfa:body-content">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
  <xsl:param name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
    </xsl:apply-templates>
  </xsl:param>

  <xsl:if test="not(@xml:lang)">
    <xsl:attribute name="xml:lang">en</xsl:attribute>
  </xsl:if>

  <xsl:variable name="space">
    <xsl:if test="string-length(normalize-space($subject))">
      <xsl:apply-templates select="." mode="rdfa:multi-object-resources">
	<xsl:with-param name="subjects" select="$subject"/>
	<!-- XXX there is a bug in the prefix resolution somewhere -->
	<xsl:with-param name="predicates" select="'http://rdfs.org/sioc/ns#has_space ^http://rdfs.org/sioc/ns#space_of'"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:variable>

  <main>
    <article>
      <!-- sioc:parent_of -->
      <xsl:call-template name="sioc:container-children">
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="property" select="concat($SIOC, 'parent_of')"/>
        <xsl:with-param name="label">Parent of</xsl:with-param>
      </xsl:call-template>
      <!-- sioc:container_of -->
      <xsl:call-template name="sioc:container-children">
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="property" select="concat($SIOC, 'container_of')"/>
        <xsl:with-param name="label">Container of</xsl:with-param>
      </xsl:call-template>
      <!-- dct:hasPart -->
      <xsl:call-template name="sioc:container-children">
        <xsl:with-param name="subject" select="$subject"/>
      </xsl:call-template>
    </article>
    <figure id="force" class="aside"/>
  </main>

</xsl:template>

<xsl:template name="sioc:container-children">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="property" select="concat($DCT, 'hasPart')"/>
  <xsl:param name="label" select="'Contents'"/>

  <xsl:variable name="children">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="predicate" select="$property"/>
    </xsl:apply-templates>
  </xsl:variable>

  <section>
    <h1><xsl:value-of select="$label"/></h1>
    <xsl:if test="string-length(normalize-space($children))">
      <ul>
        <xsl:call-template name="sioc:container-first-child">
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="property" select="$property"/>
          <xsl:with-param name="children" select="$children"/>
        </xsl:call-template>
      </ul>
    </xsl:if>
  </section>
</xsl:template>

<xsl:template name="sioc:container-first-child">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="property">
    <xsl:message terminate="yes">`property` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="children">
    <xsl:message terminate="yes">`children` parameter required</xsl:message>
  </xsl:param>

  <xsl:variable name="first">
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$children"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="string-length($first)">

    <xsl:variable name="type">
      <xsl:apply-templates select="." mode="rdfa:get-type">
        <xsl:with-param name="base" select="$base"/>
        <xsl:with-param name="subject" select="$first"/>
        <xsl:with-param name="debug" select="false()"/>
      </xsl:apply-templates>
    </xsl:variable>

    <!--<xsl:message>first: <xsl:value-of select="$first"/></xsl:message>-->

    <xsl:variable name="label-pair">
      <xsl:call-template name="rdfa:get-label">
        <xsl:with-param name="base" select="$base"/>
        <xsl:with-param name="subject" select="$first"/>
      </xsl:call-template>
    </xsl:variable>

    <!--<xsl:comment>first: <xsl:value-of select="$first"/></xsl:comment>-->

    <xsl:variable name="label-pred" select="substring-before($label-pair, ' ')"/>
    <xsl:variable name="label-raw" select="substring-after($label-pair, ' ')"/>
    <xsl:variable name="label">
      <xsl:call-template name="rdfa:literal-value">
        <xsl:with-param name="literal" select="$label-raw"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="label-lang">
      <xsl:call-template name="rdfa:literal-language">
        <xsl:with-param name="literal" select="$label-raw"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="label-dt">
      <xsl:call-template name="rdfa:literal-datatype">
        <xsl:with-param name="literal" select="$label-raw"/>
      </xsl:call-template>
    </xsl:variable>

    <li>
      <a href="{$first}">
        <xsl:if test="string-length(normalize-space($type))">
          <xsl:attribute name="typeof">
            <xsl:value-of select="$type"/>
        </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="string-length($label)">
            <span property="{$label-pred}">
            <xsl:if test="string-length($label-lang)">
              <xsl:attribute name="xml:lang">
                <xsl:value-of select="$label-lang"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length($label-dt)">
              <xsl:attribute name="datatype">
                <xsl:value-of select="$label-dt"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$label"/>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$first"/>
          </xsl:otherwise>
        </xsl:choose>
      </a>
    </li>

    <xsl:variable name="rest" select="substring-after(normalize-space($children), ' ')"/>
    <xsl:if test="string-length($rest)">
      <xsl:call-template name="sioc:container-first-child">
        <xsl:with-param name="base" select="$base"/>
        <xsl:with-param name="property" select="$property"/>
        <xsl:with-param name="children" select="$rest"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
