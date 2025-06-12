<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:html="http://www.w3.org/1999/xhtml"
		xmlns:ibis="https://vocab.methodandstructure.com/ibis#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
		xmlns:cgto="https://vocab.methodandstructure.com/graph-tool#"
		xmlns:pm="https://vocab.methodandstructure.com/process-model#"
		xmlns:x="urn:x-dummy:"
                xmlns:rdfa="http://www.w3.org/ns/rdfa#"
                xmlns:xc="https://makethingsmakesense.com/asset/transclude#"
                xmlns:str="http://xsltsl.org/string"
                xmlns:uri="http://xsltsl.org/uri"
		xmlns="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="html str uri rdfa xc x">

<xsl:import href="goal"/>

<xsl:output
  method="xml" media-type="application/xhtml+xml"
  indent="yes" omit-xml-declaration="no"
  encoding="utf-8" doctype-public=""/>

<xsl:template name="skos:self">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="debug" select="false()"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="type">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="predicate" select="$rdfa:RDF-TYPE"/>
    </xsl:apply-templates>
  </xsl:param>

  <xsl:param name="user">
    <xsl:message terminate="yes">`user` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="can-write" select="normalize-space($user) != ''"/>

  <xsl:variable name="value">
    <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="predicate" select="concat($RDF, 'value')"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:call-template name="ibis:entity-heading">
    <xsl:with-param name="subject" select="$subject"/>
    <xsl:with-param name="type" select="$type"/>
    <xsl:with-param name="value" select="$value"/>
    <xsl:with-param name="can-write" select="$can-write"/>
  </xsl:call-template>

  <xsl:call-template name="skos:created-by">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="subject" select="$subject"/>
  </xsl:call-template>

  <!-- add class-specific stuff here -->

  <xsl:call-template name="pm:goal-boilerplate">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="subject" select="$subject"/>
    <xsl:with-param name="user" select="$user"/>
    <xsl:with-param name="can-write" select="$can-write"/>
  </xsl:call-template>

  <section>
    <div>
      <h5>Budget:</h5>
      <xsl:call-template name="pm:number-control">
        <xsl:with-param name="base"      select="$base"/>
        <xsl:with-param name="subject"   select="$subject"/>
        <xsl:with-param name="predicate" select="concat($PM, 'budget')"/>
        <xsl:with-param name="can-write" select="$can-write"/>
      </xsl:call-template>
    </div>
    <div>
      <h5>Due on:</h5>
      <xsl:call-template name="pm:date-control">
        <xsl:with-param name="base"      select="$base"/>
        <xsl:with-param name="subject"   select="$subject"/>
        <xsl:with-param name="predicate" select="concat($PM, 'due')"/>
        <xsl:with-param name="can-write" select="$can-write"/>
      </xsl:call-template>
    </div>
  </section>

  <xsl:call-template name="skos:referenced-by-inset">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="subject" select="$subject"/>
    <xsl:with-param name="can-write" select="$can-write"/>
  </xsl:call-template>

  <xsl:call-template name="skos:object-form">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="subject" select="$subject"/>
    <xsl:with-param name="can-write" select="$can-write"/>
  </xsl:call-template>

  <!-- who else endorses this goal? -->

  <xsl:call-template name="ibis:endorsements">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="subject" select="$subject"/>
    <xsl:with-param name="user" select="$user"/>
  </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
