<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:html="http://www.w3.org/1999/xhtml"
		xmlns:ibis="https://vocab.methodandstructure.com/ibis#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
		xmlns:cgto="https://vocab.methodandstructure.com/graph-tool#"
		xmlns:pm="https://vocab.methodandstructure.com/process-model#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:org="http://www.w3.org/ns/org#"
		xmlns:x="urn:x-dummy:"
                xmlns:rdfa="http://www.w3.org/ns/rdfa#"
                xmlns:xc="https://makethingsmakesense.com/asset/transclude#"
                xmlns:str="http://xsltsl.org/string"
                xmlns:uri="http://xsltsl.org/uri"
		xmlns="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="html str uri rdfa xc x">

<xsl:import href="/asset/cgto/space"/>

<xsl:output
  method="xml" media-type="application/xhtml+xml"
  indent="yes" omit-xml-declaration="no"
  encoding="utf-8" doctype-public=""/>

<xsl:variable name="FOAF" select="'http://xmlns.com/foaf/0.1/'"/>
<xsl:variable name="ORG" select="'http://www.w3.org/ns/org#'"/>
<xsl:variable name="SIOCT" select="'http://rdfs.org/sioc/types#'"/>

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
  <xsl:param name="type">
    <xsl:call-template name="rdfa:get-type">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="subject" select="$subject"/>
    </xsl:call-template>
  </xsl:param>

  <xsl:if test="not(@xml:lang)">
    <xsl:attribute name="xml:lang">en</xsl:attribute>
  </xsl:if>

  <xsl:variable name="prefixes">
    <xsl:call-template name="rdfa:merge-prefixes">
      <xsl:with-param name="with" select="concat('dct: ', $DCT)"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="containers">
    <xsl:apply-templates select="." mode="rdfa:multi-object-resources">
      <xsl:with-param name="subjects" select="$subject"/>
      <xsl:with-param name="predicates" select="'dct:isPartOf ^dct:hasPart'"/>
      <xsl:with-param name="prefixes" select="$prefixes"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="space">
    <xsl:if test="string-length(normalize-space($containers))">
      <xsl:apply-templates select="." mode="rdfa:multi-object-resources">
	<xsl:with-param name="subjects" select="$containers"/>
	<!-- XXX there is a bug in the prefix resolution somewhere -->
	<xsl:with-param name="predicates" select="'http://rdfs.org/sioc/ns#has_space ^http://rdfs.org/sioc/ns#space_of'"/>
	<xsl:with-param name="traverse" select="true()"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="index">
    <xsl:if test="string-length(normalize-space($space))">
      <xsl:apply-templates select="." mode="rdfa:object-resources">
	<xsl:with-param name="subject" select="$space"/>
	<xsl:with-param name="predicate" select="'https://vocab.methodandstructure.com/graph-tool#index'"/>
	<xsl:with-param name="traverse" select="true()"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="user">
    <xsl:if test="string-length(normalize-space($index))">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="subject" select="$index"/>
      <xsl:with-param name="predicate" select="'https://vocab.methodandstructure.com/graph-tool#user'"/>
      <xsl:with-param name="traverse" select="true()"/>
    </xsl:apply-templates>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="name-raw">
    <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="predicate" select="concat($FOAF, 'name')"/>
    </xsl:apply-templates>
  </xsl:variable>
  <xsl:variable name="name-lang">
    <xsl:call-template name="rdfa:literal-language">
      <xsl:with-param name="literal" select="$name-raw"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="name-dt">
    <xsl:call-template name="rdfa:literal-datatype">
      <xsl:with-param name="literal" select="$name-raw"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="name">
    <xsl:call-template name="rdfa:literal-value">
      <xsl:with-param name="literal" select="$name-raw"/>
    </xsl:call-template>
  </xsl:variable>

  <main>
    <article>
      <hgroup class="self">
        <h1 property="foaf:name"><xsl:value-of select="$name"/></h1>
      </hgroup>
    </article>
    <figure id="force" class="aside"/>
  </main>

  <!-- name in h1 -->
  <!-- accounts/contact info -->
  <!-- org affiliations -->
  <!-- products (created/contributed/generated) -->
  <!-- (actual human people can have other relationships) -->
  <!-- other relationships -->

</xsl:template>

</xsl:stylesheet>
