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

<xsl:import href="/asset/foaf/agent"/>

<xsl:output
  method="xml" media-type="application/xhtml+xml"
  indent="yes" omit-xml-declaration="no"
  encoding="utf-8" doctype-public=""/>

<!-- head and immediate members -->
<!-- part of (unit of, sub-organization of) -->
<!-- organizational units -->
<!-- sub-organizations -->
<!-- products -->

<xsl:template name="foaf:relationships">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="type">
    <xsl:message terminate="yes">`type` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="user">
    <xsl:message terminate="yes">`user` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="collections">
    <xsl:message terminate="yes">`collections` parameter required</xsl:message>
  </xsl:param>
  <!-- relationships with people -->
  <xsl:call-template name="foaf:rel-subset">
    <xsl:with-param name="subject" select="$subject"/>
    <xsl:with-param name="type" select="$type"/>
    <xsl:with-param name="subset">people</xsl:with-param>
    <xsl:with-param name="user" select="$user"/>
    <xsl:with-param name="collections" select="$collections"/>
  </xsl:call-template>

  <!-- relationships with organizations -->
  <xsl:call-template name="foaf:rel-subset">
    <xsl:with-param name="subject" select="$subject"/>
    <xsl:with-param name="type" select="$type"/>
    <xsl:with-param name="subset">orgs</xsl:with-param>
    <xsl:with-param name="user" select="$user"/>
    <xsl:with-param name="collections" select="$collections"/>
  </xsl:call-template>
</xsl:template>


</xsl:stylesheet>
