<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:rdfa="http://www.w3.org/ns/rdfa#"
                xmlns:xc="https://makethingsmakesense.com/asset/transclude#"
		xmlns:x="urn:x-dummy:"
                xmlns:str="http://xsltsl.org/string"
                xmlns:uri="http://xsltsl.org/uri"
		xmlns="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="html str uri rdfa xc x">

<xsl:import href="rdfa"/>
<xsl:import href="transclude"/>

<x:doc>
  <h1>RDFa Utilities</h1>
  <p>This stylesheet handles the type-agnostic templates for XHTML+RDFa.</p>
</x:doc>

<xsl:output
    method="xml" media-type="application/xhtml+xml"
    indent="yes" omit-xml-declaration="no"
    encoding="utf-8" doctype-public=""/>

<xsl:variable name="RDF" select="$rdfa:RDF-NS"/>
<xsl:variable name="RDFS" select="$rdfa:RDFS-NS"/>
<xsl:variable name="DCT"  select="'http://purl.org/dc/terms/'"/>
<xsl:variable name="FOAF" select="'http://xmlns.com/foaf/0.1/'"/>
<xsl:variable name="ORG"  select="'http://www.w3.org/ns/org#'"/>
<xsl:variable name="PROV" select="'http://www.w3.org/ns/prov#'"/>
<xsl:variable name="QB"   select="'http://purl.org/linked-data/cube#'"/>
<xsl:variable name="SIOC" select="'http://rdfs.org/sioc/ns#'"/>
<xsl:variable name="SKOS" select="'http://www.w3.org/2004/02/skos/core#'"/>
<xsl:variable name="XHV"  select="'http://www.w3.org/1999/xhtml/vocab#'"/>
<xsl:variable name="XSD"  select="$rdfa:XSD-NS"/>

<x:lprops>
  <x:prop uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#value"/>
  <x:prop uri="http://www.w3.org/2004/02/skos/core#prefLabel"/>
  <x:prop uri="http://www.w3.org/2000/01/rdf-schema#label"/>
  <x:prop uri="http://purl.org/dc/terms/title"/>
  <x:prop uri="http://purl.org/dc/terms/identifier"/>
  <x:prop uri="http://xmlns.com/foaf/0.1/name"/>
</x:lprops>

<xsl:variable name="rdfa:LABEL-PREDS" select="document('')/xsl:stylesheet/x:lprops/x:prop/@uri"/>

<x:doc>
  <h2>Utilities</h2>
</x:doc>

<x:doc>
  <h3>str:safe-first-token</h3>
  <p>Returns a (normalized) first token, or the only token if it's the only token.</p>
</x:doc>

<xsl:template name="str:safe-first-token">
  <xsl:param name="tokens">
    <xsl:message terminate="yes">`tokens` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="delimiter" select="' '"/>

  <xsl:variable name="_">
    <xsl:choose>
      <xsl:when test="$delimiter != ' '">
        <xsl:variable name="_1" select="translate($tokens, '&#x09;&#x0a;&#x0d;&#x20;', '&#xf109;&#xf10a;&#xf10d;&#xf120;')"/>
        <xsl:variable name="_2" select="normalize-space(translate($_1, $delimiter, ' '))"/>
        <xsl:variable name="_3" select="translate($_2, ' ', $delimiter)"/>
        <xsl:value-of select="translate($_3, '&#xf109;&#xf10a;&#xf10d;&#xf120;', '&#x09;&#x0a;&#x0d;&#x20;')"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="normalize-space($tokens)"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="contains($_, $delimiter)">
      <xsl:value-of select="substring-before($_, $delimiter)"/>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="$_"/></xsl:otherwise>
  </xsl:choose>

</xsl:template>

<x:doc>
  <h3>str:token-union</h3>
</x:doc>

<xsl:template name="str:token-union">
  <xsl:param name="left"/>
  <xsl:param name="right"/>

  <xsl:variable name="lpad" select="concat(' ', normalize-space($left), ' ')"/>
  <xsl:variable name="first">
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$right"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="out">
    <xsl:choose>
      <xsl:when test="string-length($first) and contains($lpad, concat(' ', $first, ' '))">
        <xsl:value-of select="$left"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($left, ' ', $first)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="rest" select="substring-after(normalize-space($right), ' ')"/>
  <xsl:choose>
    <xsl:when test="string-length($rest)">
      <xsl:call-template name="str:token-union">
        <xsl:with-param name="left" select="$out"/>
        <xsl:with-param name="right" select="$rest"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="$out"/></xsl:otherwise>
  </xsl:choose>

</xsl:template>

<x:doc>
  <h3>str:token-minus</h3>
</x:doc>

<xsl:template name="str:token-minus">
  <xsl:param name="tokens"/>
  <xsl:param name="minus"/>

  <xsl:if test="string-length(normalize-space($tokens))">

    <xsl:variable name="padded" select="concat(' ', normalize-space($tokens), ' ')"/>

    <xsl:choose>
      <xsl:when test="string-length(normalize-space($minus))">

        <xsl:variable name="minus-first">
          <xsl:text> </xsl:text>
          <xsl:call-template name="str:safe-first-token">
            <xsl:with-param name="tokens" select="$minus"/>
          </xsl:call-template>
          <xsl:text> </xsl:text>
        </xsl:variable>

        <xsl:variable name="out">
          <xsl:choose>
            <xsl:when test="contains($padded, $minus-first)">
              <xsl:value-of select="substring-before($padded, $minus-first)"/>
              <xsl:text> </xsl:text>
              <xsl:call-template name="str:token-minus">
                <xsl:with-param name="tokens" select="substring-after($padded, $minus-first)"/>
                <xsl:with-param name="minus" select="$minus-first"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$padded"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="minus-rest" select="substring-after(normalize-space($minus), ' ')"/>

        <xsl:choose>
          <xsl:when test="string-length($minus-rest)">
            <xsl:call-template name="str:token-minus">
              <xsl:with-param name="tokens" select="normalize-space($out)"/>
              <xsl:with-param name="minus" select="$minus-rest"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space($out)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($tokens)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<x:doc>
  <h3>rdfa:merge-one-prefix</h3>
</x:doc>

<xsl:template name="rdfa:merge-one-prefix">
  <xsl:param name="prefixes">
    <xsl:message terminate="yes">`prefixes` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="prefix">
    <xsl:message terminate="yes">`prefix` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="namespace">
    <xsl:message terminate="yes">`namespace` parameter required</xsl:message>
  </xsl:param>

  <xsl:variable name="p" select="concat(' ', normalize-space($prefixes), ' ')"/>
  <xsl:variable name="x" select="concat(' ', normalize-space($prefix), ' ')"/>
  <xsl:variable name="n" select="concat(' ', normalize-space($namespace), ' ')"/>

  <xsl:value-of select="normalize-space($prefixes)"/>
  <xsl:if test="not(contains($p, $n))">
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="contains($p, $x)">
	<xsl:value-of select="substring($prefix, 1, string-length($prefix) - 1)"/>
	<xsl:text>0:</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="normalize-space($prefix)"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:value-of select="normalize-space($namespace)"/>
  </xsl:if>
</xsl:template>

<x:doc>
  <h3>rdfa:merge-prefixes</h3>
</x:doc>

<xsl:template match="html:*" mode="rdfa:merge-prefixes" name="rdfa:merge-prefixes">
  <xsl:param name="prefixes">
    <xsl:apply-templates select="." mode="rdfa:prefix-stack"/>
  </xsl:param>
  <xsl:param name="with" select="''"/>

  <xsl:variable name="p" select="normalize-space($prefixes)"/>
  <xsl:variable name="w" select="normalize-space($with)"/>

  <xsl:choose>
    <xsl:when test="string-length($p) and string-length($w)">
      <xsl:variable name="prefix">
	<xsl:call-template name="str:safe-first-token">
	  <xsl:with-param name="tokens" select="$w"/>
	</xsl:call-template>
      </xsl:variable>
      <xsl:variable name="namespace">
	<xsl:call-template name="str:safe-first-token">
	  <xsl:with-param name="tokens" select="substring-after($w, ' ')"/>
	</xsl:call-template>
      </xsl:variable>

      <xsl:variable name="pfx-out">
	<xsl:call-template name="rdfa:merge-one-prefix">
	  <xsl:with-param name="prefixes" select="$p"/>
	  <xsl:with-param name="prefix" select="$prefix"/>
	  <xsl:with-param name="namespace" select="$namespace"/>
	</xsl:call-template>
      </xsl:variable>

      <xsl:variable name="rest" select="normalize-space(substring(substring-after($w, ' '), string-length($namespace) + 1))"/>

      <xsl:choose>
	<xsl:when test="string-length($rest)">
	  <xsl:call-template name="rdfa:merge-prefixes">
	    <xsl:with-param name="prefixes" select="$pfx-out"/>
	    <xsl:with-param name="with" select="$rest"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise><xsl:value-of select="$pfx-out"/></xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="string-length($w)"><xsl:value-of select="$w"/></xsl:when>
    <xsl:when test="string-length($p)"><xsl:value-of select="$p"/></xsl:when>
  </xsl:choose>

</xsl:template>

<x:doc>
  <h3>rdfa:multi-object-resources</h3>
</x:doc>

<xsl:template match="html:*" mode="rdfa:multi-object-resources">
  <xsl:param name="current"    select="."/>
  <xsl:param name="base" select="normalize-space(($current/ancestor-or-self::html:html/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="subjects" select="$base"/>
  <xsl:param name="predicates" select="''"/>
  <xsl:param name="single"     select="false()"/>
  <xsl:param name="raw"        select="false()"/>
  <xsl:param name="traverse"   select="false()"/>
  <xsl:param name="debug"      select="$rdfa:DEBUG"/>
  <xsl:param name="prefixes">
    <xsl:apply-templates select="$current" mode="rdfa:prefix-stack"/>
  </xsl:param>

  <xsl:variable name="p" select="normalize-space($predicates)"/>
  <xsl:variable name="first">
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$p"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$first">
    <xsl:if test="$debug">
      <xsl:message>rdfa:multi-object-resources testing predicate <xsl:value-of select="$first"/></xsl:message>
    </xsl:if>
    <xsl:variable name="_">
      <xsl:choose>
	<xsl:when test="starts-with($first, '^')">
	  <xsl:apply-templates select="$current" mode="rdfa:subject-resources">
	    <xsl:with-param name="base" select="$base"/>
	    <xsl:with-param name="object" select="$subjects"/>
	    <xsl:with-param name="predicate" select="substring-after($first, '^')"/>
	    <xsl:with-param name="single" select="$single"/>
	    <xsl:with-param name="debug" select="$debug"/>
	    <xsl:with-param name="raw" select="true()"/>
	    <xsl:with-param name="traverse" select="$traverse"/>
	    <xsl:with-param name="prefixes" select="$prefixes"/>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
	<xsl:apply-templates select="$current" mode="rdfa:object-resources">
	  <xsl:with-param name="base" select="$base"/>
	  <xsl:with-param name="subject" select="$subjects"/>
	  <xsl:with-param name="predicate" select="$first"/>
	  <xsl:with-param name="single" select="$single"/>
	  <xsl:with-param name="debug" select="$debug"/>
	  <xsl:with-param name="raw" select="true()"/>
	  <xsl:with-param name="traverse" select="$traverse"/>
	  <xsl:with-param name="prefixes" select="$prefixes"/>
	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:variable name="rest" select="substring-after($p, ' ')"/>
    <xsl:if test="$rest">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="$current" mode="rdfa:multi-object-resources">
	<xsl:with-param name="current" select="$current"/>
	<xsl:with-param name="base" select="$base"/>
	<xsl:with-param name="subjects" select="$subjects"/>
	<xsl:with-param name="predicates" select="$rest"/>
	<xsl:with-param name="single" select="$single"/>
	<xsl:with-param name="debug" select="$debug"/>
	<xsl:with-param name="raw" select="$raw"/>
	<xsl:with-param name="traverse" select="$traverse"/>
	<!--<xsl:with-param name="continue" select="$continue"/>-->
	<xsl:with-param name="prefixes" select="$prefixes"/>
      </xsl:apply-templates>
    </xsl:if>
    </xsl:variable>

    <xsl:if test="$debug">
      <xsl:message>rdfa:multi-object-resources raw output: <xsl:value-of select="$_"/></xsl:message>
    </xsl:if>

    <xsl:call-template name="str:unique-tokens">
      <xsl:with-param name="string" select="$_"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<x:doc>
  <h3>rdfa:get-type</h3>
</x:doc>

<xsl:template match="html:*" mode="rdfa:get-type" name="rdfa:get-type">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
    </xsl:apply-templates>
  </xsl:param>

  <xsl:apply-templates select="." mode="rdfa:object-resources">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="subject" select="$subject"/>
    <xsl:with-param name="predicate" select="$rdfa:RDF-TYPE"/>
  </xsl:apply-templates>
</xsl:template>

<!-- okay actual templates now -->

<x:doc>
  <h3>default <code>&lt;head&gt;</code></h3>
</x:doc>

<xsl:template match="html:head">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <head>
  <xsl:apply-templates select="@*" mode="xc:attribute">
    <xsl:with-param name="base"          select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
  </xsl:apply-templates>

  <xsl:apply-templates select="html:title|html:base">
    <xsl:with-param name="base"          select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>

  <xsl:variable name="metas">
    <xsl:apply-templates select="." mode="rdfa:get-meta">
      <xsl:with-param name="base"          select="$base"/>
      <xsl:with-param name="resource-path" select="$resource-path"/>
      <xsl:with-param name="rewrite"       select="$rewrite"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:if test="$metas">
    <xsl:apply-templates select="." mode="rdfa:add-meta-meta">
      <xsl:with-param name="base"          select="$base"/>
      <xsl:with-param name="resource-path" select="$resource-path"/>
      <xsl:with-param name="rewrite"       select="$rewrite"/>
      <xsl:with-param name="targets"       select="$metas"/>
    </xsl:apply-templates>
  </xsl:if>

  <xsl:apply-templates select="html:*[not(self::html:title|self::html:base)]">
    <xsl:with-param name="base"          select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
  </xsl:apply-templates>

  <xsl:apply-templates select="." mode="rdfa:head-extra">
    <xsl:with-param name="base"          select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
  </xsl:apply-templates>

  </head>
</xsl:template>

<xsl:template name="rdfa:head-extra"/>

<x:doc>
  <h3>rdfa:get-meta</h3>
</x:doc>

<xsl:template match="html:*" mode="rdfa:get-meta">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="debug" select="false()"/>
    </xsl:apply-templates>
  </xsl:param>

  <xsl:variable name="top">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="predicate" select="concat($XHV, 'top')"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="_">
    <xsl:call-template name="str:unique-tokens">
      <xsl:with-param name="string" select="concat($subject, ' ', $top)"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:message>get-meta: <xsl:value-of select="$_"/></xsl:message>

  <xsl:apply-templates select="." mode="rdfa:find-relations">
    <xsl:with-param name="resources" select="$_"/>
    <xsl:with-param name="predicate" select="concat($XHV, 'meta')"/>
  </xsl:apply-templates>
</xsl:template>

<x:doc>
  <h3>rdfa:add-meta-meta</h3>
</x:doc>

<xsl:template match="html:*" mode="rdfa:add-meta-meta">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
  <xsl:param name="targets">
    <xsl:message terminate="yes">Required parameter `targets`</xsl:message>
  </xsl:param>

  <xsl:variable name="first">
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$targets"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:message>add-meta-meta: <xsl:value-of select="$targets"/></xsl:message>

  <xsl:variable name="meta" select="document($first)"/>

  <xsl:apply-templates select="$meta/html:html/html:head/html:*[not(self::html:title|self::html:base)]">
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
  </xsl:apply-templates>

  <xsl:variable name="rest" select="substring-after(normalize-space($targets), ' ')"/>
  <xsl:if test="$rest">
    <xsl:apply-templates select="." mode="rdfa:add-meta-meta">
      <xsl:with-param name="base"          select="$base"/>
      <xsl:with-param name="resource-path" select="$resource-path"/>
      <xsl:with-param name="rewrite"       select="$rewrite"/>
      <xsl:with-param name="main"          select="$main"/>
      <xsl:with-param name="heading"       select="$heading"/>
      <xsl:with-param name="targets"       select="$rest"/>
    </xsl:apply-templates>
  </xsl:if>

</xsl:template>

<x:doc>
  <h2>rdfa:find-relations</h2>
  <p>Retrieve the objects of a number of subjects and a given predicate.</p>
</x:doc>

<xsl:template match="html:*" mode="rdfa:find-relations">
  <xsl:param name="resources"  select="''"/>
  <xsl:param name="predicate" select="$rdfa:RDF-TYPE"/>
  <xsl:param name="reverse"   select="false()"/>
  <xsl:param name="state"     select="''"/>

  <xsl:variable name="first">
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$resources"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="string-length($first)">
      <xsl:variable name="doc">
        <xsl:call-template name="uri:document-for-uri">
          <xsl:with-param name="uri" select="$first"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="root" select="document($doc)/*"/>

      <xsl:variable name="out">
        <xsl:value-of select="concat($state, ' ')"/>
        <xsl:choose>
          <xsl:when test="$reverse">
            <xsl:message>reverse: <xsl:value-of select="$first"/></xsl:message>
            <xsl:apply-templates select="$root" mode="rdfa:subject-resources">
              <xsl:with-param name="object" select="$first"/>
              <!--<xsl:with-param name="base" select="$doc"/>-->
              <xsl:with-param name="predicate" select="$predicate"/>
              <!--<xsl:with-param name="debug" select="true()"/>-->
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$root" mode="rdfa:object-resources">
              <xsl:with-param name="subject" select="$first"/>
              <!--<xsl:with-param name="base" select="$doc"/>-->
              <xsl:with-param name="predicate" select="$predicate"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="rest" select="normalize-space(substring-after(normalize-space($resources), ' '))"/>

      <!--<xsl:message>first: <xsl:value-of select="$first"/> rest: <xsl:value-of select="$rest"/></xsl:message>-->

      <xsl:apply-templates select="." mode="rdfa:find-relations">
        <xsl:with-param name="resources" select="normalize-space($rest)"/>
        <xsl:with-param name="predicate" select="$predicate"/>
        <xsl:with-param name="reverse" select="$reverse"/>
        <xsl:with-param name="state" select="$out"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <!--<xsl:message><xsl:value-of select="normalize-space($state)"/></xsl:message>-->

      <xsl:call-template name="str:unique-tokens">
        <xsl:with-param name="string" select="normalize-space($state)"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<x:doc>
  <h3>rdfa:filter-by-predicate-object</h3>
</x:doc>

<xsl:template match="html:*" mode="rdfa:filter-by-predicate-object">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="subjects" select="''"/>
  <xsl:param name="predicate">
    <xsl:message terminate="yes">required parameter `predicate`</xsl:message>
  </xsl:param>
  <xsl:param name="object">
    <xsl:message terminate="yes">required parameter `object`</xsl:message>
  </xsl:param>
  <xsl:param name="literal" select="false()"/>
  <xsl:param name="traverse" select="true()"/>
  <xsl:param name="state" select="''"/>
  <xsl:param name="debug" select="false()"/>

  <xsl:variable name="first">
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$subjects"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="string-length($first)">
      <xsl:variable name="doc">
        <xsl:choose>
          <xsl:when test="$traverse">
            <xsl:call-template name="uri:document-for-uri">
              <xsl:with-param name="uri" select="$first"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise><xsl:value-of select="$base"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <!--<xsl:variable name="root" select="(not($traverse) and .) or document($doc)/*"/>-->
      <xsl:variable name="root" select="document($doc)/*"/>

      <xsl:variable name="objects">
        <xsl:apply-templates select="$root" mode="rdfa:object-resources">
          <xsl:with-param name="subject" select="$first"/>
          <xsl:with-param name="base" select="$doc"/>
          <xsl:with-param name="predicate" select="$predicate"/>
        </xsl:apply-templates>
      </xsl:variable>

      <xsl:if test="$debug">
        <xsl:message>found objects for <xsl:value-of select="$first"/>: <xsl:value-of select="$objects"/></xsl:message>
      </xsl:if>

      <xsl:variable name="test">
        <xsl:variable name="_">
          <xsl:call-template name="str:token-intersection">
            <xsl:with-param name="left" select="$object"/>
            <xsl:with-param name="right" select="$objects"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:value-of select="normalize-space($_)"/>
      </xsl:variable>

      <xsl:variable name="out">
        <xsl:value-of select="$state"/>
        <xsl:if test="string-length($test)">
          <xsl:if test="string-length($state)">
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:value-of select="normalize-space($first)"/>
        </xsl:if>
      </xsl:variable>

      <xsl:variable name="rest" select="normalize-space(substring-after(normalize-space($subjects), ' '))"/>
      <xsl:apply-templates select="." mode="rdfa:filter-by-predicate-object">
        <xsl:with-param name="subjects"  select="$rest"/>
        <xsl:with-param name="predicate" select="$predicate"/>
        <xsl:with-param name="object"    select="$object"/>
        <xsl:with-param name="literal"   select="$literal"/>
        <xsl:with-param name="state"     select="normalize-space($out)"/>
        <xsl:with-param name="traverse"  select="$traverse"/>
        <xsl:with-param name="debug"     select="$debug"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="str:unique-tokens">
        <xsl:with-param name="string" select="normalize-space($state)"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<x:doc>
  <h3>rdfa:filter-by-type</h3>
</x:doc>

<xsl:template match="html:*" mode="rdfa:filter-by-type">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="subjects" select="''"/>
  <xsl:param name="classes"/>
  <xsl:param name="class" select="$classes"/>
  <xsl:param name="state" select="''"/>
  <xsl:param name="traverse" select="true()"/>
  <xsl:param name="continued" select="false()"/>

  <xsl:if test="not(string-length($class))">
    <xsl:message terminate="yes">required parameter `classes` or `class`</xsl:message>
  </xsl:if>

  <xsl:variable name="first">
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$subjects"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="string-length($first)">
    <xsl:variable name="doc">
      <xsl:choose>
        <xsl:when test="$traverse">
          <xsl:call-template name="uri:document-for-uri">
            <xsl:with-param name="uri" select="$first"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$base"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="root" select="document($doc)/*"/>

    <xsl:variable name="types">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="$root" mode="rdfa:object-resources">
        <xsl:with-param name="subject" select="$first"/>
        <xsl:with-param name="base" select="$first"/>
        <xsl:with-param name="predicate" select="$rdfa:RDF-TYPE"/>
      </xsl:apply-templates>
      <xsl:text> </xsl:text>
    </xsl:variable>

    <xsl:variable name="match">
      <xsl:call-template name="str:token-intersection">
        <xsl:with-param name="left" select="$types"/>
        <xsl:with-param name="right" select="$class"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="string-length(normalize-space($match))">
      <xsl:if test="$continued">
	<xsl:text> </xsl:text>
      </xsl:if>
      <xsl:value-of select="$first"/>
    </xsl:if>

    <xsl:variable name="rest" select="substring-after(normalize-space($subjects), ' ')"/>

    <xsl:if test="string-length($rest)">
      <xsl:apply-templates select="." mode="rdfa:filter-by-type">
	<xsl:with-param name="base"      select="$base"/>
	<xsl:with-param name="subjects"  select="$rest"/>
	<xsl:with-param name="classes"   select="$classes"/>
	<xsl:with-param name="traverse"  select="$traverse"/>
	<xsl:with-param name="continued" select="true()"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template name="rdfa:filter-uris-by-authority">
  <xsl:param name="uris" select="''"/>
  <xsl:param name="authority">
    <xsl:message terminate="yes">`authority` parameter required</xsl:message>
  </xsl:param>

  <xsl:variable name="v-domain">
    <xsl:choose>
      <xsl:when test="contains($domain, '/')">
	<xsl:call-template name="uri:get-uri-authority">
	  <xsl:with-param name="uri" select="$authority"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$authority"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="v-uris" select="normalize-space($uris)"/>
  <xsl:if test="string-length($v-uris)">
    <xsl:variable name="first">
      <xsl:call-template name="str:safe-first-token">
	<xsl:with-param name="tokens" select="$v-uris"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="rest" select="substring-after($v-uris, ' ')"/>

    <xsl:variable name="u-authority">
      <xsl:call-template name="uri:get-uri-authority">
	<xsl:with-param name="uri" select="$authority"/>
      </xsl:call-template>
    </xsl:variable>
  </xsl:if>
</xsl:template>

<x:doc>
  <h2>Generic Body</h2>
</x:doc>

<xsl:template match="html:body">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
  <xsl:param name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base"  select="$base"/>
      <xsl:with-param name="debug" select="false()"/>
    </xsl:apply-templates>
  </xsl:param>

  <xsl:param name="type">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="subject"   select="$subject"/>
      <xsl:with-param name="base"      select="$base"/>
      <xsl:with-param name="predicate" select="$rdfa:RDF-TYPE"/>
    </xsl:apply-templates>
  </xsl:param>

  <body>
    <xsl:apply-templates select="@*" mode="xc:attribute">
      <xsl:with-param name="base"          select="$base"/>
      <xsl:with-param name="resource-path" select="$resource-path"/>
      <xsl:with-param name="rewrite"       select="$rewrite"/>
    </xsl:apply-templates>

    <xsl:apply-templates select="." mode="rdfa:body-content">
      <xsl:with-param name="base"          select="$base"/>
      <xsl:with-param name="resource-path" select="$resource-path"/>
      <xsl:with-param name="rewrite"       select="$rewrite"/>
      <xsl:with-param name="main"          select="$main"/>
      <xsl:with-param name="heading"       select="$heading"/>
      <xsl:with-param name="subject"       select="$subject"/>
      <xsl:with-param name="type"          select="$type"/>
    </xsl:apply-templates>
  </body>
</xsl:template>

<x:doc>
  <h2>rdfa:get-label</h2>
  <p>Get the predicate-object pair that constitutes the most appropriate label.</p>
</x:doc>

<xsl:template match="html:*" mode="rdfa:get-label" name="rdfa:get-label">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base"  select="$base"/>
      <xsl:with-param name="debug" select="false()"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="predicates" select="$rdfa:LABEL-PREDS"/>

  <!--<xsl:message>ok wtf <xsl:value-of select="count($predicates)"/></xsl:message>-->

  <xsl:if test="count($predicates)">
    <xsl:variable name="predicate" select="string($predicates[1])"/>

    <xsl:variable name="literal">
      <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
        <xsl:with-param name="base" select="$base"/>
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="predicate" select="$predicate"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length(normalize-space($literal))">
        <xsl:value-of select="concat($predicate, ' ', $literal)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="rdfa:get-label">
          <xsl:with-param name="base" select="$base"/>
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="predicates" select="$predicates[position() &gt; 1]"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template name="rdfa:literal-value">
  <xsl:param name="literal">
    <xsl:message terminate="yes">`literal` parameter required</xsl:message>
  </xsl:param>
  <xsl:value-of select="substring-before($literal, $rdfa:UNIT-SEP)"/>
</xsl:template>

<xsl:template name="rdfa:literal-language">
  <xsl:param name="literal">
    <xsl:message terminate="yes">`literal` parameter required</xsl:message>
  </xsl:param>
  <xsl:variable name="_" select="substring-after($literal, $rdfa:UNIT-SEP)"/>
  <xsl:if test="starts-with($_, '@')">
    <xsl:value-of select="substring-after($_, '@')"/>
  </xsl:if>
</xsl:template>

<xsl:template name="rdfa:literal-datatype">
  <xsl:param name="literal">
    <xsl:message terminate="yes">`literal` parameter required</xsl:message>
  </xsl:param>
  <xsl:variable name="_" select="substring-after($literal, $rdfa:UNIT-SEP)"/>
  <xsl:if test="not(starts-with($_, '@'))">
    <xsl:value-of select="$_"/>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
