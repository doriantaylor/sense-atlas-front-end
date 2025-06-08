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

  <xsl:import href="/asset/skos/concept-scheme"/>

<xsl:output
  method="xml" media-type="application/xhtml+xml"
  indent="yes" omit-xml-declaration="no"
  encoding="utf-8" doctype-public=""/>

<xsl:variable name="IBIS" select="'https://vocab.methodandstructure.com/ibis#'"/>
<xsl:variable name="PM"   select="'https://vocab.methodandstructure.com/process-model#'"/>

<xsl:template match="html:body" mode="rdfa:body-content">
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

  <xsl:variable name="space">
    <xsl:apply-templates select="." mode="rdfa:multi-object-resources">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="subjects" select="$subject"/>
      <!-- XXX there is a bug in the prefix resolution somewhere -->
      <xsl:with-param name="predicates" select="'http://rdfs.org/sioc/ns#has_space ^http://rdfs.org/sioc/ns#space_of'"/>
    </xsl:apply-templates>
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

  <xsl:variable name="adjacents">
    <xsl:apply-templates select="." mode="rdfa:multi-object-resources">
      <xsl:with-param name="subjects" select="$subject"/>
      <xsl:with-param name="predicates" select="'^skos:inScheme ^skos:topConceptOf skos:hasTopConcept'"/>
    </xsl:apply-templates>
  </xsl:variable>

  <!--
  <p>subject: <xsl:value-of select="$subject"/></p>
  <p>space: <xsl:value-of select="$space"/></p>
  <p>index: <xsl:value-of select="$index"/></p>
  <p>user: <xsl:value-of select="$user"/></p>
  <p>adjacents: <xsl:value-of select="$adjacents"/></p>
  -->

  <xsl:variable name="issues">
    <xsl:apply-templates select="." mode="rdfa:filter-by-type">
      <xsl:with-param name="subjects" select="$adjacents"/>
      <xsl:with-param name="classes" select="concat($IBIS, 'Issue')"/>
      <xsl:with-param name="traverse" select="false()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="positions">
    <xsl:apply-templates select="." mode="rdfa:filter-by-type">
      <xsl:with-param name="subjects" select="$adjacents"/>
      <xsl:with-param name="classes" select="concat($IBIS, 'Position')"/>
      <xsl:with-param name="traverse" select="false()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="arguments">
    <xsl:apply-templates select="." mode="rdfa:filter-by-type">
      <xsl:with-param name="subjects" select="$adjacents"/>
      <xsl:with-param name="classes" select="concat($IBIS, 'Argument')"/>
      <xsl:with-param name="traverse" select="false()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="goals">
    <xsl:apply-templates select="." mode="rdfa:filter-by-type">
      <xsl:with-param name="subjects" select="$adjacents"/>
      <xsl:with-param name="classes" select="concat($PM, 'Goal')"/>
      <xsl:with-param name="traverse" select="false()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="tasks">
    <xsl:apply-templates select="." mode="rdfa:filter-by-type">
      <xsl:with-param name="subjects" select="$adjacents"/>
      <xsl:with-param name="classes" select="concat($PM, 'Task')"/>
      <xsl:with-param name="traverse" select="false()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="targets">
    <xsl:apply-templates select="." mode="rdfa:filter-by-type">
      <xsl:with-param name="subjects" select="$adjacents"/>
      <xsl:with-param name="classes" select="concat($PM, 'Target')"/>
      <xsl:with-param name="traverse" select="false()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="concepts">
    <xsl:apply-templates select="." mode="rdfa:filter-by-type">
      <xsl:with-param name="subjects" select="$adjacents"/>
      <xsl:with-param name="classes" select="concat($SKOS, 'Concept')"/>
      <xsl:with-param name="traverse" select="false()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <main>
    <article>
      <form method="POST" action="" accept-charset="utf-8">
        <input type="hidden" name="$ SUBJECT $" value="$NEW_UUID_URN"/>
        <input type="hidden" name="skos:inScheme :" value="{$subject}"/>
	<input type="hidden" name="dct:created ^xsd:dateTime $" value="$NEW_TIME_UTC"/>
	<input type="hidden" name="dct:creator :" value="{$user}"/>
        <select name="= rdf:type :">
          <option value="ibis:Issue">Issue</option>
          <option value="ibis:Position">Position</option>
          <option value="ibis:Argument">Argument</option>
          <option value="pm:Goal">Goal</option>
          <option value="pm:Task">Task</option>
          <option value="pm:Target">Target</option>
        </select>
        <input type="text" name="= rdf:value"/>
        <button class="fa fa-plus"/>
      </form>
      <xsl:if test="string-length(normalize-space($issues))">
        <section>
          <h3>Issues</h3>
          <ul>
            <xsl:call-template name="skos:concept-scheme-list-item">
              <xsl:with-param name="resources" select="$issues"/>
              <xsl:with-param name="lprop" select="concat($rdfa:RDF-NS, 'value')"/>
            </xsl:call-template>
          </ul>
        </section>
      </xsl:if>
      <xsl:if test="string-length(normalize-space($positions))">
        <section>
          <h3>Positions</h3>
          <ul>
            <xsl:call-template name="skos:concept-scheme-list-item">
              <xsl:with-param name="resources" select="$positions"/>
              <xsl:with-param name="lprop" select="concat($rdfa:RDF-NS, 'value')"/>
            </xsl:call-template>
          </ul>
        </section>
      </xsl:if>
      <xsl:if test="string-length(normalize-space($arguments))">
        <section>
          <h3>Arguments</h3>
          <ul>
            <xsl:call-template name="skos:concept-scheme-list-item">
              <xsl:with-param name="resources" select="$arguments"/>
              <xsl:with-param name="lprop" select="concat($rdfa:RDF-NS, 'value')"/>
            </xsl:call-template>
          </ul>
        </section>
      </xsl:if>
      <xsl:if test="string-length(normalize-space($goals))">
        <section>
          <h3>Goals</h3>
          <ul>
            <xsl:call-template name="skos:concept-scheme-list-item">
              <xsl:with-param name="resources" select="$goals"/>
              <xsl:with-param name="lprop" select="concat($rdfa:RDF-NS, 'value')"/>
            </xsl:call-template>
          </ul>
        </section>
      </xsl:if>
      <xsl:if test="string-length(normalize-space($tasks))">
        <section>
          <h3>Tasks</h3>
          <ul>
            <xsl:call-template name="skos:concept-scheme-list-item">
              <xsl:with-param name="resources" select="$tasks"/>
              <xsl:with-param name="lprop" select="concat($rdfa:RDF-NS, 'value')"/>
            </xsl:call-template>
          </ul>
        </section>
      </xsl:if>
      <xsl:if test="string-length(normalize-space($targets))">
        <section>
          <h3>Targets</h3>
          <ul>
            <xsl:call-template name="skos:concept-scheme-list-item">
              <xsl:with-param name="resources" select="$targets"/>
              <xsl:with-param name="lprop" select="concat($rdfa:RDF-NS, 'value')"/>
            </xsl:call-template>
          </ul>
        </section>
      </xsl:if>
      <section>
        <h3>Concepts</h3>
        <form method="POST" action="" accept-charset="utf-8">
          <input type="hidden" name="$ SUBJECT $" value="$NEW_UUID_URN"/>
          <input type="hidden" name="skos:inScheme :" value="{$subject}"/>
          <input type="hidden" name="rdf:type :" value="skos:Concept"/>
	  <input type="hidden" name="dct:created ^xsd:dateTime $" value="$NEW_TIME_UTC"/>
	  <input type="hidden" name="dct:creator :" value="{$user}"/>
          <input type="text" name="= skos:prefLabel"/>
          <button class="fa fa-plus"/>
        </form>
        <xsl:if test="string-length(normalize-space($concepts))">
          <ul>
            <xsl:call-template name="skos:concept-scheme-list-item">
              <xsl:with-param name="resources" select="$concepts"/>
              <xsl:with-param name="lprop" select="concat($SKOS, 'prefLabel')"/>
            </xsl:call-template>
          </ul>
        </xsl:if>
      </section>
    </article>
    <figure id="force" class="aside"/>
  </main>

  <!--<h1>wtf <xsl:value-of select="$space"/></h1>-->
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

</xsl:stylesheet>
