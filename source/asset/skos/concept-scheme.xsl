<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:html="http://www.w3.org/1999/xhtml"
		xmlns:cgto="https://vocab.methodandstructure.com/graph-tool#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdfa="http://www.w3.org/ns/rdfa#"
                xmlns:xc="https://makethingsmakesense.com/asset/transclude#"
                xmlns:str="http://xsltsl.org/string"
                xmlns:uri="http://xsltsl.org/uri"
		xmlns:x="urn:x-dummy:"
		xmlns="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="html str uri rdfa xc x">

  <xsl:import href="/asset/cgto/space"/>
  <xsl:import href="/asset/skos/concept"/>

<xsl:output
  method="xml" media-type="application/xhtml+xml"
  indent="yes" omit-xml-declaration="no"
  encoding="utf-8" doctype-public=""/>

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

  <xsl:variable name="space">
    <xsl:if test="string-length(normalize-space($subject))">
      <xsl:apply-templates select="." mode="rdfa:multi-object-resources">
	<xsl:with-param name="subjects" select="$subject"/>
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

  <xsl:variable name="top-concepts">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="predicate" select="concat($SKOS, 'hasTopConcept')"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="in-scheme">
    <xsl:call-template name="str:token-minus">
      <xsl:with-param name="tokens">
        <xsl:apply-templates select="." mode="rdfa:subject-resources">
          <xsl:with-param name="object" select="$subject"/>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="predicate" select="concat($SKOS, 'inScheme')"/>
        </xsl:apply-templates>
      </xsl:with-param>
      <xsl:with-param name="minus" select="$top-concepts"/>
    </xsl:call-template>
  </xsl:variable>

  <main>
    <article>
      <xsl:if test="string-length($user)">
        <form method="POST" action="" accept-charset="utf-8">
          <input type="hidden" name="$ SUBJECT $" value="$NEW_UUID_URN"/>
          <input type="hidden" name="rdf:type :" value="skos:Concept"/>
          <input type="hidden" name="skos:inScheme :" value="{$subject}"/>
	  <input type="hidden" name="dct:created ^xsd:dateTime $" value="$NEW_TIME_UTC"/>
	  <input type="hidden" name="dct:creator :" value="{$user}"/>
          <input type="text" name="= skos:prefLabel"/>
          <button class="fa fa-plus"/>
        </form>
      </xsl:if>
      <ul>
        <xsl:if test="string-length(normalize-space($top-concepts))">
          <xsl:call-template name="skos:concept-scheme-list-item">
            <xsl:with-param name="resources" select="normalize-space($top-concepts)"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($in-scheme))">
          <xsl:call-template name="skos:concept-scheme-list-item">
            <xsl:with-param name="resources" select="normalize-space($in-scheme)"/>
          </xsl:call-template>
        </xsl:if>
      </ul>
    </article>
    <figure id="force" class="aside"/>
  </main>

  <xsl:call-template name="skos:footer">
    <xsl:with-param name="base"          select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="heading"       select="$heading"/>
    <xsl:with-param name="subject"       select="$subject"/>
    <xsl:with-param name="space"         select="$space"/>
    <xsl:with-param name="index"         select="$index"/>
    <xsl:with-param name="user"          select="$user"/>
  </xsl:call-template>
</xsl:template>

<x:doc>
  <h3>skos:concept-scheme-list-item</h3>
  <p>we really need to sort out this terminology</p>
</x:doc>

<xsl:template name="skos:concept-scheme-list-item">
  <xsl:param name="resources">
    <xsl:message terminate="yes">`resources` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="lprop" select="concat($SKOS, 'prefLabel')"/>

  <xsl:variable name="first">
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$resources"/>
    </xsl:call-template>
  </xsl:variable>

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

  <xsl:variable name="lpc">
    <xsl:call-template name="rdfa:make-curie">
      <xsl:with-param name="uri" select="$lprop"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="label">
    <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
      <xsl:with-param name="subject" select="$first"/>
      <xsl:with-param name="predicate" select="$lprop"/>
    </xsl:apply-templates>
  </xsl:variable>

  <li>
    <a href="{$first}">
      <xsl:if test="string-length($types)">
        <xsl:attribute name="typeof"><xsl:value-of select="$types"/></xsl:attribute>
      </xsl:if>
      <span property="{$lpc}">
        <xsl:choose>
          <xsl:when test="contains(substring-after($label, $rdfa:UNIT-SEP), ':')">
            <xsl:attribute name="datatype">
              <xsl:value-of select="substring-after($label, $rdfa:UNIT-SEP)"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:when test="string-length(substring-after($label, $rdfa:UNIT-SEP))">
            <xsl:attribute name="xml:lang">
              <xsl:value-of select="substring-after($label, $rdfa:UNIT-SEP)"/>
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <xsl:value-of select="substring-before($label, $rdfa:UNIT-SEP)"/>
      </span>
    </a>
  </li>

  <xsl:variable name="rest" select="substring-after(normalize-space($resources), ' ')"/>
  <xsl:if test="string-length($rest)">
    <xsl:call-template name="skos:concept-scheme-list-item">
      <xsl:with-param name="resources" select="$rest"/>
      <xsl:with-param name="lprop" select="$lprop"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
