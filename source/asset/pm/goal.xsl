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

<xsl:import href="/asset/ibis/entity"/>

<xsl:output
  method="xml" media-type="application/xhtml+xml"
  indent="yes" omit-xml-declaration="no"
  encoding="utf-8" doctype-public=""/>

<xsl:variable name="PM"   select="'https://vocab.methodandstructure.com/process-model#'"/>
<xsl:variable name="FOAF" select="'http://xmlns.com/foaf/0.1/'"/>
<xsl:variable name="ORG"  select="'http://www.w3.org/ns/org#'"/>

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

<x:doc>
  <h3>pm:goal-boilerplate</h3>
</x:doc>

<xsl:template name="pm:goal-boilerplate">
  <xsl:param name="base">
    <xsl:message terminate="yes">`base` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="user">
    <xsl:message terminate="yes">`user` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="can-write">
    <xsl:message terminate="yes">`can-write` parameter required</xsl:message>
  </xsl:param>

  <!-- who wants this goal? -->
  <section>
    <div>
      <h5>Wanted by:</h5>
      <xsl:call-template name="cgto:editable-resource-list">
        <xsl:with-param name="base"        select="$base"/>
        <xsl:with-param name="subject"     select="$subject"/>
        <xsl:with-param name="predicate"   select="concat($PM, 'wanted-by')"/>
        <xsl:with-param name="resources">
          <xsl:apply-templates select="." mode="rdfa:object-resources">
            <xsl:with-param name="base"      select="$base"/>
            <xsl:with-param name="subject"   select="$subject"/>
            <xsl:with-param name="predicate" select="concat($PM, 'wanted-by')"/>
          </xsl:apply-templates>
        </xsl:with-param>
        <xsl:with-param name="label-prop"  select="concat($FOAF, 'name')"/>
        <xsl:with-param name="new-type"    select="concat($FOAF, 'Person')"/>
        <xsl:with-param name="datalist-id" select="'agents'"/>
        <xsl:with-param name="can-write"   select="$can-write"/>
      </xsl:call-template>
    </div>
    <div>
      <h5>Valued at:</h5>
      <xsl:call-template name="pm:number-control">
        <xsl:with-param name="base"      select="$base"/>
        <xsl:with-param name="subject"   select="$subject"/>
        <xsl:with-param name="predicate" select="concat($PM, 'valuation')"/>
        <xsl:with-param name="can-write" select="$can-write"/>
      </xsl:call-template>
    </div>
    <div>
      <h5>Expires on:</h5>
      <xsl:call-template name="pm:date-control">
        <xsl:with-param name="base"      select="$base"/>
        <xsl:with-param name="subject"   select="$subject"/>
        <xsl:with-param name="predicate" select="concat($PM, 'expires')"/>
        <xsl:with-param name="can-write" select="$can-write"/>
      </xsl:call-template>
    </div>
  </section>

</xsl:template>

<xsl:template name="pm:number-control">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="predicate" select="concat($PM, 'valuation')"/>
  <xsl:param name="datatype"  select="concat($XSD, 'decimal')"/>
  <xsl:param name="value-raw">
    <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
      <xsl:with-param name="base"      select="$base"/>
      <xsl:with-param name="subject"   select="$subject"/>
      <xsl:with-param name="predicate" select="$predicate"/>
      <!--<xsl:with-param name="datatype"  select="$datatype"/>-->
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="can-write">
    <xsl:message terminate="yes">`can-write` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="prefixes">
    <xsl:apply-templates select="." mode="rdfa:prefix-stack"/>
  </xsl:param>

  <xsl:variable name="p-curie">
    <xsl:choose>
      <xsl:when test="starts-with($predicate, 'http:') or starts-with($predicate, 'https:')">
        <xsl:call-template name="rdfa:make-curie">
          <xsl:with-param name="uri" select="$predicate"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$predicate"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="dt-curie">
    <xsl:variable name="_">
      <xsl:choose>
        <xsl:when test="string-length(substring-after($value-raw, $rdfa:UNIT-SEP))">
          <xsl:value-of select="substring-after($value-raw, $rdfa:UNIT-SEP)"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$datatype"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="starts-with($_, 'http:') or starts-with($_, 'https:')">
        <xsl:call-template name="rdfa:make-curie">
          <xsl:with-param name="uri" select="$_"/>
          <xsl:with-param name="prefixes" select="$prefixes"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$_"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="value" select="substring-before($value-raw, $rdfa:UNIT-SEP)"/>

  <xsl:comment>raw value: <xsl:value-of select="$value-raw"/></xsl:comment>

  <xsl:choose>
    <xsl:when test="$can-write">
      <form xsl:use-attribute-sets="cgto:form-post-self">
        <input type="number" name="= {$p-curie} ^{$dt-curie}">
          <xsl:if test="string-length($value)">
            <xsl:attribute name="value">
              <xsl:value-of select="$value"/>
            </xsl:attribute>
          </xsl:if>
        </input>
      </form>
    </xsl:when>
    <xsl:when test="string-length($value)">
      <span property="{$p-curie}" datatype="{$dt-curie}"><xsl:value-of select="$value"/></span>
    </xsl:when>
    <xsl:otherwise>
      <span>N/A</span>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<x:doc>
  <h3>pm:date-control</h3>
</x:doc>

<xsl:template name="pm:date-control">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="predicate" select="concat($PM, 'expires')"/>
  <xsl:param name="value-raw">
    <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
      <xsl:with-param name="base"      select="$base"/>
      <xsl:with-param name="subject"   select="$subject"/>
      <xsl:with-param name="predicate" select="$predicate"/>
      <xsl:with-param name="datatype"  select="concat($XSD, 'dateTime')"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="can-write">
    <xsl:message terminate="yes">`can-write` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="prefixes">
    <xsl:apply-templates select="." mode="rdfa:prefix-stack"/>
  </xsl:param>

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

  <xsl:comment><xsl:value-of select="$actual-prefixes"/></xsl:comment>

  <xsl:variable name="p-curie">
    <xsl:choose>
      <xsl:when test="starts-with($predicate, 'http:') or starts-with($predicate, 'https:')">
        <xsl:call-template name="rdfa:make-curie">
          <xsl:with-param name="uri" select="$predicate"/>
          <xsl:with-param name="prefixes" select="$actual-prefixes"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$predicate"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!--<xsl:variable name="value" select="substring-before($value-raw, $rdfa:UNIT-SEP)"/>-->

  <!--
      i forgot that if you specify the datatype it doesn't concatenate
      it because you know it already; that might actually be a bad
      thing because of mistakes like this.
  -->
  <xsl:variable name="value" select="$value-raw"/>

  <xsl:comment><xsl:value-of select="$predicate"/> &#x2192; <xsl:value-of select="$p-curie"/>: <xsl:value-of select="$value"/></xsl:comment>

  <xsl:choose>
    <xsl:when test="$can-write">
      <form xsl:use-attribute-sets="cgto:form-post-self">
        <input type="datetime-local" name="= {$p-curie} ^xsd:dateTime">
          <xsl:if test="string-length($value)">
            <xsl:attribute name="value">
              <xsl:value-of select="$value"/>
            </xsl:attribute>
          </xsl:if>
        </input>
      </form>
    </xsl:when>
    <xsl:when test="string-length($value)">
      <time property="{$p-curie}" datatype="xsd:dateTime"><xsl:value-of select="$value"/></time>
    </xsl:when>
    <xsl:otherwise>
      <span>N/A</span>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
