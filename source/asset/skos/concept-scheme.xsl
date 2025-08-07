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

<xsl:variable name="CI" select="'https://vocab.methodandstructure.com/content-inventory#'"/>
<xsl:variable name="ORG" select="'http://www.w3.org/ns/org#'"/>

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

  <xsl:variable name="can-write" select="string-length(normalize-space($user)) != 0"/>

  <xsl:comment>
    subject: <xsl:value-of select="$subject"/>
    space: <xsl:value-of select="$space"/>
    index: <xsl:value-of select="$index"/>
    user: <xsl:value-of select="$user"/>
  </xsl:comment>

  <xsl:variable name="adjacents">
    <xsl:apply-templates select="." mode="rdfa:multi-object-resources">
      <xsl:with-param name="subjects" select="$subject"/>
      <xsl:with-param name="predicates" select="'^skos:inScheme ^skos:topConceptOf skos:hasTopConcept'"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="concepts">
    <xsl:apply-templates select="." mode="rdfa:filter-by-type">
      <xsl:with-param name="subjects" select="$adjacents"/>
      <xsl:with-param name="classes" select="concat($SKOS, 'Concept')"/>
      <xsl:with-param name="traverse" select="false()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="audiences">
    <xsl:apply-templates select="." mode="rdfa:filter-by-type">
      <xsl:with-param name="subjects" select="$adjacents"/>
      <xsl:with-param name="classes" select="concat($CI, 'Audience')"/>
      <xsl:with-param name="traverse" select="false()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="roles">
    <xsl:apply-templates select="." mode="rdfa:filter-by-type">
      <xsl:with-param name="subjects" select="$adjacents"/>
      <xsl:with-param name="classes" select="concat($ORG, 'Role')"/>
      <xsl:with-param name="traverse" select="false()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="label-raw">
    <xsl:apply-templates select="." mode="skos:object-form-label">
      <xsl:with-param name="subject" select="$subject"/>
    </xsl:apply-templates>
  </xsl:variable>
  <xsl:variable name="label-prop" select="substring-before($label-raw, ' ')"/>
  <xsl:variable name="label-val" select="substring-after($label-raw, ' ')"/>
  <xsl:variable name="label" select="substring-before($label-val, $rdfa:UNIT-SEP)"/>
  <xsl:variable name="label-type">
    <xsl:if test="not(starts-with(substring-after($label-val, $rdfa:UNIT-SEP), '@'))">
      <xsl:value-of select="substring-after($label-val, $rdfa:UNIT-SEP)"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="label-lang">
    <xsl:if test="starts-with(substring-after($label-val, $rdfa:UNIT-SEP), '@')">
      <xsl:value-of select="substring-after($label-val, concat($rdfa:UNIT-SEP, ' '))"/>
    </xsl:if>
  </xsl:variable>

  <main>
    <article>
      <hgroup>
        <h1>
          <xsl:if test="$label-prop">
            <xsl:attribute name="property">
	      <xsl:value-of select="$label-prop"/>
            </xsl:attribute>
            <xsl:if test="$label-type">
	      <xsl:attribute name="datatype"><xsl:value-of select="$label-type"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="$label-lang">
	      <xsl:attribute name="xml:lang"><xsl:value-of select="$label-lang"/></xsl:attribute>
            </xsl:if>
          </xsl:if>
          <xsl:value-of select="$label"/>
        </h1>
        <xsl:if test="string-length($user)">
        </xsl:if>
      </hgroup>

      <xsl:if test="$can-write or string-length($concepts)">
        <section about="skos:Concept">
          <hgroup>
            <h3>Concepts</h3>
            <xsl:if test="$can-write">
              <form method="POST" action="" accept-charset="utf-8">
                <input type="hidden" name="$ SUBJECT $" value="$NEW_UUID_URN"/>
                <input type="hidden" name="rdf:type :" value="skos:Concept"/>
                <input type="hidden" name="skos:inScheme :" value="{$subject}"/>
	        <input type="hidden" name="dct:created ^xsd:dateTime $" value="$NEW_TIME_UTC"/>
	        <input type="hidden" name="dct:creator :" value="{$user}"/>
                <input type="text" name="= skos:prefLabel" placeholder="Add a new concept&#x2026;"/>
                <button class="fa fa-plus"/>
              </form>
            </xsl:if>
          </hgroup>
          <xsl:if test="string-length(normalize-space($concepts))">
            <ul>
              <xsl:call-template name="skos:concept-scheme-list-item">
                <xsl:with-param name="resources" select="normalize-space($concepts)"/>
              </xsl:call-template>
            </ul>
          </xsl:if>
        </section>
      </xsl:if>

      <xsl:if test="$can-write or string-length($audiences)">
        <section about="ci:Audience">
          <hgroup>
            <h3>Concepts</h3>
            <xsl:if test="$can-write">
              <form method="POST" action="" accept-charset="utf-8">
                <input type="hidden" name="$ SUBJECT $" value="$NEW_UUID_URN"/>
                <input type="hidden" name="rdf:type :" value="ci:Audience"/>
                <input type="hidden" name="skos:inScheme :" value="{$subject}"/>
	        <input type="hidden" name="dct:created ^xsd:dateTime $" value="$NEW_TIME_UTC"/>
	        <input type="hidden" name="dct:creator :" value="{$user}"/>
                <input type="text" name="= skos:prefLabel" placeholder="Add a new audience&#x2026;"/>
                <button class="fa fa-plus"/>
              </form>
            </xsl:if>
          </hgroup>
          <xsl:if test="string-length(normalize-space($audiences))">
            <ul>
              <xsl:call-template name="skos:concept-scheme-list-item">
                <xsl:with-param name="resources" select="normalize-space($audiences)"/>
              </xsl:call-template>
            </ul>
          </xsl:if>
        </section>
      </xsl:if>

      <xsl:if test="$can-write or string-length($roles)">
        <section about="org:Role">
          <hgroup>
            <h3>Concepts</h3>
            <xsl:if test="$can-write">
              <form method="POST" action="" accept-charset="utf-8">
                <input type="hidden" name="$ SUBJECT $" value="$NEW_UUID_URN"/>
                <input type="hidden" name="rdf:type :" value="org:Role"/>
                <input type="hidden" name="skos:inScheme :" value="{$subject}"/>
	        <input type="hidden" name="dct:created ^xsd:dateTime $" value="$NEW_TIME_UTC"/>
	        <input type="hidden" name="dct:creator :" value="{$user}"/>
                <input type="text" name="= skos:prefLabel" placeholder="Add a new role&#x2026;"/>
                <button class="fa fa-plus"/>
              </form>
            </xsl:if>
          </hgroup>
          <xsl:if test="string-length(normalize-space($roles))">
            <ul>
              <xsl:call-template name="skos:concept-scheme-list-item">
                <xsl:with-param name="resources" select="normalize-space($roles)"/>
              </xsl:call-template>
            </ul>
          </xsl:if>
        </section>
      </xsl:if>

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
