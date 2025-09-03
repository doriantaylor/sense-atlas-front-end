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

      <xsl:comment>oh hi</xsl:comment>

      <xsl:call-template name="skos:concept-scheme-section">
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="adjacents" select="$adjacents"/>
        <xsl:with-param name="can-write" select="$can-write"/>
        <xsl:with-param name="user" select="$user"/>
        <xsl:with-param name="placeholder">Add new concept&#x2026;</xsl:with-param>
      </xsl:call-template>

      <xsl:call-template name="skos:concept-scheme-section">
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="adjacents" select="$adjacents"/>
        <xsl:with-param name="type" select="'ci:Audience'"/>
        <xsl:with-param name="sec-label">Audiences</xsl:with-param>
        <xsl:with-param name="can-write" select="$can-write"/>
        <xsl:with-param name="user" select="$user"/>
        <xsl:with-param name="placeholder">Add new audience&#x2026;</xsl:with-param>
      </xsl:call-template>

      <xsl:call-template name="skos:concept-scheme-section">
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="adjacents" select="$adjacents"/>
        <xsl:with-param name="type" select="'org:Role'"/>
        <xsl:with-param name="sec-label">Roles</xsl:with-param>
        <xsl:with-param name="can-write" select="$can-write"/>
        <xsl:with-param name="user" select="$user"/>
        <xsl:with-param name="placeholder">Add new role&#x2026;</xsl:with-param>
      </xsl:call-template>

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
  <h3>skos:concept-scheme-section</h3>
</x:doc>

<xsl:template name="skos:concept-scheme-section">
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="adjacents">
    <xsl:message terminate="yes">`adjacents` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="type" select="'skos:Concept'"/>
  <xsl:param name="sec-label" select="'Concepts'"/>
  <xsl:param name="member-prop" select="'skos:inScheme'"/>
  <xsl:param name="label-prop" select="'skos:prefLabel'"/>
  <xsl:param name="add-created" select="true()"/>
  <xsl:param name="add-creator" select="true()"/>
  <xsl:param name="can-write" select="false()"/>
  <xsl:param name="placeholder" select="'Add new&#x2026;'"/>
  <xsl:param name="traverse" select="false()"/>
  <xsl:param name="user">
    <xsl:if test="$add-creator">
      <xsl:message terminate="yes">`user` parameter required</xsl:message>
    </xsl:if>
  </xsl:param>

  <xsl:variable name="resources">
    <xsl:apply-templates select="." mode="rdfa:filter-by-type">
      <xsl:with-param name="subjects" select="$adjacents"/>
      <xsl:with-param name="classes" select="$type"/>
      <xsl:with-param name="traverse" select="$traverse"/>
    </xsl:apply-templates>
  </xsl:variable>

  <!-- why oh why did i make the rdf-kv protocol deviate from sparql notation -->
  <xsl:variable name="rel-name">
    <xsl:choose>
      <xsl:when test="starts-with(normalize-space($member-prop), '^')">
        <xsl:text>! </xsl:text>
        <xsl:value-of select="substring-after(normalize-space($member-prop), '^')"/>
        <xsl:text> :</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($member-prop)"/><xsl:text> :</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$can-write or string-length(normalize-space($resources))">
    <section about="{$type}">
      <hgroup>
        <h3><xsl:value-of select="$sec-label"/></h3>
        <xsl:if test="$can-write">
          <form method="POST" action="" accept-charset="utf-8">
            <input type="hidden" name="$ SUBJECT $" value="$NEW_UUID_URN"/>
            <input type="hidden" name="rdf:type :" value="{$type}"/>
            <input type="hidden" name="{$rel-name}" value="{$subject}"/>
            <xsl:if test="$add-created">
	      <input type="hidden" name="dct:created ^xsd:dateTime $" value="$NEW_TIME_UTC"/>
            </xsl:if>
            <xsl:if test="$add-creator">
	      <input type="hidden" name="dct:creator :" value="{$user}"/>
            </xsl:if>
            <input type="text" name="= {$label-prop}" placeholder="{$placeholder}"/>
            <button class="fa fa-plus"/>
          </form>
        </xsl:if>
      </hgroup>
      <xsl:if test="string-length(normalize-space($resources))">
        <ul>
          <xsl:call-template name="skos:concept-scheme-list-item">
            <xsl:with-param name="resources" select="normalize-space($resources)"/>
            <xsl:with-param name="label-prop" select="$label-prop"/>
          </xsl:call-template>
        </ul>
      </xsl:if>
    </section>
  </xsl:if>

</xsl:template>

<x:doc>
  <h3>skos:concept-scheme-list-item</h3>
  <p>we really need to sort out this terminology</p>
</x:doc>

<xsl:template name="skos:concept-scheme-list-item">
  <xsl:param name="resources">
    <xsl:message terminate="yes">`resources` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="label-prop" select="concat($SKOS, 'prefLabel')"/>

  <xsl:variable name="lprop">
    <xsl:choose>
      <xsl:when test="contains($label-prop, ':') and starts-with($label-prop, 'http')">
        <xsl:value-of select="$label-prop"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="rdfa:resolve-curie">
          <xsl:with-param name="curie" select="$label-prop"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

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
      <xsl:with-param name="label-prop" select="$lprop"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
