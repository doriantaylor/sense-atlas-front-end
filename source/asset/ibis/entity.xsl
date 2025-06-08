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

<xsl:import href="/asset/skos/concept"/>

<xsl:output
    method="xml" media-type="application/xhtml+xml"
    indent="yes" omit-xml-declaration="no"
    encoding="utf-8" doctype-public=""/>

<xsl:variable name="DCT"  select="'http://purl.org/dc/terms/'"/>
<xsl:variable name="FOAF" select="'http://xmlns.com/foaf/0.1/'"/>
<xsl:variable name="IBIS" select="'https://vocab.methodandstructure.com/ibis#'"/>

<x:doc>
  <h3>skos:self</h3>
</x:doc>

<xsl:template name="skos:self">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite"       select="''"/>
  <xsl:param name="main"          select="false()"/>
  <xsl:param name="heading"       select="0"/>

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
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="predicate" select="concat($rdfa:RDF-NS, 'value')"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="created">
    <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="predicate" select="concat($DCT, 'created')"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="creator">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="predicate" select="concat($DCT, 'creator')"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="name">
    <xsl:if test="string-length(normalize-space($creator))">
      <xsl:variable name="_">
	<xsl:call-template name="uri:document-for-uri">
	  <xsl:with-param name="uri" select="$creator"/>
	</xsl:call-template>
      </xsl:variable>
      <xsl:apply-templates select="document($_)/*" mode="rdfa:object-literal-quick">
        <xsl:with-param name="subject" select="$creator"/>
        <xsl:with-param name="predicate" select="concat($FOAF, 'name')"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:variable>

  <h1 class="heading">
    <xsl:choose>
      <xsl:when test="$can-write"><!--
        <xsl:call-template name="ibis:toggle-list">
          <xsl:with-param name="type" select="$type"/>
        </xsl:call-template>-->
        <form accept-charset="utf-8" action="" class="description" method="POST">
          <textarea class="heading" name="= rdf:value"><xsl:value-of select="substring-before($value, $rdfa:UNIT-SEP)"/></textarea>
          <button class="fa fa-sync" title="Save Text"></button>
        </form>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="property">rdf:value</xsl:attribute>
        <xsl:value-of select="substring-before($value, $rdfa:UNIT-SEP)"/>
      </xsl:otherwise>
    </xsl:choose>
  </h1>

  <xsl:call-template name="skos:created-by">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="subject" select="$subject"/>
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

  <xsl:call-template name="ibis:endorsements">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="subject" select="$subject"/>
    <xsl:with-param name="user" select="$user"/>
  </xsl:call-template>
</xsl:template>

<x:doc>
  <h3>ibis:endorsements</h3>
</x:doc>

<xsl:template name="ibis:endorsements">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="user">
    <xsl:message terminate="yes">`user` parameter required</xsl:message>
  </xsl:param>

  <xsl:variable name="endorsements">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="predicate" select="concat($IBIS, 'endorsed-by')"/>
    </xsl:apply-templates>
  </xsl:variable>
  <xsl:variable name="i-endorse" select="string-length($user) and contains(concat(' ', normalize-space($endorsements), ' '), concat(' ', normalize-space($user), ' '))"/>

  <xsl:message>endorsements: <xsl:value-of select="$endorsements"/></xsl:message>

  <ul rel="ibis:endorsed-by">
    <xsl:call-template name="ibis:one-endorsement">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="endorsements" select="$endorsements"/>
      <xsl:with-param name="user" select="$user"/>
    </xsl:call-template>

    <xsl:if test="string-length($user)">
      <li>
        <form method="POST" action="">
          <xsl:choose>
            <xsl:when test="$i-endorse">
              <button name="- ibis:endorsed-by :" value="{$user}" class="fa-solid fa-thumbs-up"/>
            </xsl:when>
            <xsl:otherwise>
              <button name="ibis:endorsed-by :" value="{$user}" class="fa-regular fa-thumbs-up"/>
            </xsl:otherwise>
          </xsl:choose>
        </form>
      </li>
    </xsl:if>
  </ul>
</xsl:template>

<x:doc>
  <h3>ibis:endorsements</h3>
</x:doc>

<xsl:template name="ibis:one-endorsement">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="endorsements">
    <xsl:message terminate="yes">`endorsements` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="user">
    <xsl:message terminate="yes">`user` parameter required</xsl:message>
  </xsl:param>

  <xsl:variable name="first">
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$endorsements"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="string-length($first)">
    <xsl:variable name="name">
      <xsl:variable name="_">
        <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
          <xsl:with-param name="base"      select="$base"/>
          <xsl:with-param name="subject"   select="$first"/>
          <xsl:with-param name="predicate" select="concat($FOAF, 'name')"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:value-of select="substring-before($_, $rdfa:UNIT-SEP)"/>
    </xsl:variable>

    <li><a href="{$first}" property="foaf:name"><xsl:value-of select="$name"/></a></li>

    <xsl:variable name="rest" select="substring-after(normalize-space($endorsements), ' ')"/>
    <xsl:if test="$rest">
      <xsl:call-template name="ibis:one-endorsement">
        <xsl:with-param name="base"         select="$base"/>
        <xsl:with-param name="endorsements" select="$rest"/>
        <xsl:with-param name="user"         select="$user"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
