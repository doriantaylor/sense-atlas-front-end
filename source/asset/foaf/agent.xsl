<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
		xmlns:ibis="https://vocab.methodandstructure.com/ibis#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
		xmlns:cgto="https://vocab.methodandstructure.com/graph-tool#"
		xmlns:pm="https://vocab.methodandstructure.com/process-model#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:rel="http://purl.org/vocab/relationship/"
                xmlns:org="http://www.w3.org/ns/org#"
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

<xsl:variable name="DCT"   select="'http://purl.org/dc/terms/'"/>
<xsl:variable name="FOAF"  select="'http://xmlns.com/foaf/0.1/'"/>
<xsl:variable name="REL"   select="'http://purl.org/vocab/relationship/'"/>
<xsl:variable name="ORG"   select="'http://www.w3.org/ns/org#'"/>
<xsl:variable name="SIOCT" select="'http://rdfs.org/sioc/types#'"/>

<xsl:template match="html:head" mode="rdfa:head-extra-extra">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>

  <script type="text/javascript" src="/asset/foaf/scripts"></script>

</xsl:template>

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

  <!-- XXX figure out a better way to do this -->
  <xsl:if test="not(@xml:lang)">
    <xsl:attribute name="xml:lang">en</xsl:attribute>
  </xsl:if>

  <xsl:variable name="prefixes">
    <xsl:call-template name="rdfa:merge-prefixes">
      <xsl:with-param name="with" select="concat('dct: ', $DCT)"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="collections">
    <xsl:apply-templates select="." mode="rdfa:multi-object-resources">
      <xsl:with-param name="subjects" select="$subject"/>
      <xsl:with-param name="predicates" select="'dct:isPartOf ^dct:hasPart'"/>
      <xsl:with-param name="prefixes" select="$prefixes"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="space">
    <xsl:if test="string-length(normalize-space($collections))">
      <xsl:apply-templates select="." mode="rdfa:multi-object-resources">
	<xsl:with-param name="subjects" select="$collections"/>
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

  <main>
    <article>
      <hgroup class="self">
        <xsl:call-template name="foaf:name">
          <xsl:with-param name="subject" select="$subject"/>
          <xsl:with-param name="user" select="$user"/>
        </xsl:call-template>
        <!-- accounts/contact info -->
        <!-- web -->
        <!-- social media -->
        <!-- accordion: products -->
        <!-- accordion: other backreferences -->
        <!-- accordion: see also -->
      </hgroup>
      <xsl:call-template name="foaf:relationships">
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="type"    select="$type"/>
        <xsl:with-param name="user"    select="$user"/>
        <xsl:with-param name="collections" select="$collections"/>
      </xsl:call-template>
    </article>
    <figure id="force" class="aside"/>
  </main>

</xsl:template>

<x:doc>
  <h3>foaf:name</h3>
</x:doc>

<xsl:template name="foaf:name">
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="property" select="concat($FOAF, 'name')"/>
  <xsl:param name="user">
    <xsl:message terminate="yes">`user` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="can-write" select="normalize-space($user) != ''"/>

  <xsl:variable name="p-curie">
    <xsl:call-template name="rdfa:make-curie">
      <xsl:with-param name="uri" select="$property"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="name-raw">
    <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="predicate" select="$property"/>
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

  <h1 property="{$p-curie}">
    <xsl:if test="$name-lang != ''">
      <xsl:attribute name="xml:lang">
        <xsl:value-of select="$name-lang"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="$name-dt != ''">
      <xsl:attribute name="datatype">
        <xsl:value-of select="$name-dt"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$can-write">
        <xsl:attribute name="content"><xsl:value-of select="$name"/></xsl:attribute>
        <form accept-charset="utf-8" action="" method="POST">
          <input type="text" name="= {$p-curie}" value="{$name}"/>
          <button class="fa fa-sync"/>
        </form>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$name"/>
      </xsl:otherwise>
    </xsl:choose>
  </h1>
</xsl:template>

<x:doc>
  <h3>foaf:relationships</h3>
  <p>Process all relationship subsets for the given RDF type. May need to be individually implemented on a per-class basis.</p>
</x:doc>

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

  <xsl:call-template name="foaf:rel-subset">
    <xsl:with-param name="subject" select="$subject"/>
    <xsl:with-param name="type" select="concat($FOAF, 'Agent')"/>
    <xsl:with-param name="subset" select="'plain'"/>
    <xsl:with-param name="user" select="$user"/>
    <xsl:with-param name="collections" select="$collections"/>
  </xsl:call-template>
</xsl:template>

<x:doc>
  <h3>foaf:rel-subset</h3>
  <p>Process an individual subset of semantic relations.</p>
</x:doc>

<xsl:template name="foaf:rel-subset">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="type">
    <xsl:message terminate="yes">`type` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="subset">
    <xsl:message terminate="yes">`subset` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="collections">
    <xsl:message terminate="yes">`collections` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="user">
    <xsl:message terminate="yes">`user` parameter required</xsl:message>
  </xsl:param>
  <!--<xsl:param name="focus">
    <xsl:message terminate="yes">`focus` parameter required</xsl:message>
    </xsl:param>-->
  <xsl:variable name="can-write" select="normalize-space($user) != ''"/>

  <xsl:variable name="types-ok">
    <xsl:call-template name="str:token-intersection">
      <xsl:with-param name="left" select="$type"/>
      <xsl:with-param name="right" select="$foaf:CLASSES"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="best-type">
    <!-- XXX DO SOMETHING BETTER -->
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$types-ok"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:comment>type: <xsl:value-of select="$best-type"/> subset: <xsl:value-of select="$subset"/></xsl:comment>

  <!-- do the switcheroo -->
  <xsl:variable name="current" select="."/>
  <xsl:variable name="sequence" select="$skos:SEQUENCE/x:class[@uri = $best-type]"/>
  <section class="relations {$subset}">
  <xsl:for-each select="$foaf:RELATIONS[@subset=$subset][x:class/@uri = $best-type]/x:prop">
    <xsl:variable name="prop" select="."/>
    <xsl:variable name="seqprop" select="($sequence/x:prop[@rev = string($prop/@rev)]|$sequence/x:prop[@uri = string($prop/@uri)])[1]"/>

    <xsl:comment>rel: <xsl:value-of select="$prop/@uri"/> rev: <xsl:value-of select="$prop/@rev"/> sequence: <xsl:value-of select="count($sequence)"/> seqprop: <xsl:value-of select="count($seqprop)"/></xsl:comment>

    <xsl:variable name="reversed" select="count($seqprop/@rev) != 0"/>

    <xsl:variable name="targets">
      <xsl:choose>
        <xsl:when test="$reversed">
          <xsl:apply-templates select="$current" mode="rdfa:subject-resources">
            <xsl:with-param name="object" select="$subject"/>
            <xsl:with-param name="base" select="$base"/>
            <xsl:with-param name="predicate" select="$seqprop/@rev"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$current" mode="rdfa:object-resources">
            <xsl:with-param name="subject" select="$subject"/>
            <xsl:with-param name="base" select="$base"/>
            <xsl:with-param name="predicate" select="$seqprop/@uri"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="has-targets" select="normalize-space($targets) != ''"/>
    <xsl:variable name="uri" select="string(($seqprop/@rev|$seqprop/@uri)[1])"/>


    <xsl:variable name="curie">
      <xsl:call-template name="rdfa:make-curie">
        <xsl:with-param name="uri" select="$uri"/>
        <xsl:with-param name="node" select="$current"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:comment>uri: <xsl:value-of select="$uri"/></xsl:comment>

    <xsl:comment>collections: <xsl:value-of select="$collections"/></xsl:comment>

    <section about="{$uri}">
      <h3>
        <xsl:if test="not($reversed)">
          <xsl:attribute name="property">rdfs:label</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="$seqprop/x:label[1]"/>
      </h3>
      <xsl:if test="$can-write">
        <xsl:apply-templates select="$seqprop" mode="skos:add-relation">
          <xsl:with-param name="base"        select="$base"/>
          <xsl:with-param name="current"     select="$current"/>
          <xsl:with-param name="subject"     select="$subject"/>
          <xsl:with-param name="collections" select="$collections"/>
          <xsl:with-param name="member-rel"  select="''"/>
          <xsl:with-param name="member-rev"  select="concat($DCT, 'hasPart')"/>
          <xsl:with-param name="user"        select="$user"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="$has-targets">
        <xsl:comment>hi</xsl:comment>
        <ul>
	  <xsl:attribute name="about"/>
          <xsl:choose>
            <xsl:when test="$reversed">
              <xsl:attribute name="rev"><xsl:value-of select="$curie"/></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="rel"><xsl:value-of select="$curie"/></xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="$current" mode="skos:link-stack">
              <xsl:with-param name="base"          select="$base"/>
              <xsl:with-param name="resource-path" select="$resource-path"/>
              <xsl:with-param name="rewrite"       select="$rewrite"/>
              <xsl:with-param name="rel"           select="$seqprop/@uri"/>
              <xsl:with-param name="rev"           select="$seqprop/@rev"/>
              <xsl:with-param name="stack"         select="$targets"/>
              <xsl:with-param name="can-write"     select="$can-write"/>
          </xsl:apply-templates>
        </ul>
      </xsl:if>
    </section>
  </xsl:for-each>
  </section>
</xsl:template>

<x:doc>
  <h2>DATA</h2>
  <p>We want to be able to partition the master list of properties so we can put them on two columns. We also have to deal with semantic relations that (unlike IBIS/SKOS) do not have an inverse. So we need a way to represent and label these inverse relations.</p>
</x:doc>

<xsl:variable name="foaf:RELATIONS" select="document('')/xsl:stylesheet/x:select"/>

<xsl:variable name="foaf:CLASSES">
  <xsl:variable name="_">
    <xsl:for-each select="$foaf:RELATIONS/x:class">
      <xsl:value-of select="concat(' ', @uri)"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:call-template name="str:unique-tokens">
    <xsl:with-param name="tokens" select="$_"/>
  </xsl:call-template>
</xsl:variable>

<!-- for plain agents -->
<x:select subset="plain">
  <x:class uri="http://xmlns.com/foaf/0.1/Agent"/>
  <x:prop uri="http://www.w3.org/ns/org#headOf"/>
  <x:prop uri="http://www.w3.org/ns/org#memberOf"/>
</x:select>

<!-- for people -->
<x:select subset="personal">
  <x:class uri="http://xmlns.com/foaf/0.1/Person"/>
  <x:prop uri="http://xmlns.com/foaf/0.1/knows"/>
</x:select>

<x:select subset="professional">
  <x:class uri="http://xmlns.com/foaf/0.1/Person"/>
  <x:prop uri="http://www.w3.org/ns/org#headOf"/>
  <x:prop uri="http://www.w3.org/ns/org#memberOf"/>
  <x:prop uri="http://www.w3.org/ns/org#reportsTo"/>
  <x:prop rev="http://www.w3.org/ns/org#reportsTo">
    <x:label>Has Reports</x:label>
  </x:prop>
</x:select>

<!-- for orgs -->

<x:select subset="people">
  <x:class uri="http://www.w3.org/ns/org#Organization"/>
  <x:class uri="http://www.w3.org/ns/org#FormalOrganization"/>
  <x:class uri="http://www.w3.org/ns/org#OrganizationalUnit"/>
  <x:class uri="http://www.w3.org/ns/org#OrganizationalCollaboration"/>
  <x:prop rev="http://www.w3.org/ns/org#headOf">
    <x:label>Has Head</x:label>
  </x:prop>
  <x:prop uri="http://www.w3.org/ns/org#hasMember"/>
</x:select>

<x:select subset="orgs">
  <x:class uri="http://www.w3.org/ns/org#Organization"/>
  <x:prop uri="http://www.w3.org/ns/org#hasSubOrganization"/>
  <x:prop uri="http://www.w3.org/ns/org#subOrganizationOf"/>
  <x:prop uri="http://www.w3.org/ns/org#linkedTo"/>
</x:select>

<x:select subset="orgs">
  <x:class uri="http://www.w3.org/ns/org#FormalOrganization"/>
  <x:prop uri="http://www.w3.org/ns/org#hasUnit"/>
  <x:prop uri="http://www.w3.org/ns/org#hasSubOrganization"/>
  <x:prop uri="http://www.w3.org/ns/org#subOrganizationOf"/>
  <x:prop uri="http://www.w3.org/ns/org#linkedTo"/>
</x:select>

<x:select subset="orgs">
  <x:class uri="http://www.w3.org/ns/org#OrganizationalUnit"/>
  <x:prop uri="http://www.w3.org/ns/org#unitOf"/>
  <x:prop uri="http://www.w3.org/ns/org#hasSubOrganization"/>
  <x:prop uri="http://www.w3.org/ns/org#subOrganizationOf"/>
  <x:prop uri="http://www.w3.org/ns/org#linkedTo"/>
</x:select>

<x:select subset="orgs">
  <x:class uri="http://www.w3.org/ns/org#OrganizationalCollaboration"/>
  <x:prop uri="http://www.w3.org/ns/org#hasMember"/>
  <x:prop uri="http://www.w3.org/ns/org#hasSubOrganization"/>
  <x:prop uri="http://www.w3.org/ns/org#subOrganizationOf"/>
  <x:prop uri="http://www.w3.org/ns/org#linkedTo"/>
</x:select>

<rdf:RDF>
  <owl:Class rdf:about="http://xmlns.com/foaf/0.1/Agent">
    <owl:equivalentClass rdf:resource="http://purl.org/dc/terms/Agent"/>
  </owl:Class>
  <owl:Class rdf:about="http://xmlns.com/foaf/0.1/Person">
    <rdfs:subClassOf rdf:resource="http://xmlns.com/foaf/0.1/Agent"/>
  </owl:Class>
  <owl:Class rdf:about="http://www.w3.org/ns/org#Organization">
    <owl:equivalentClass rdf:resource="http://xmlns.com/foaf/0.1/Organization"/>
    <rdfs:subClassOf rdf:resource="http://xmlns.com/foaf/0.1/Agent"/>
  </owl:Class>
  <owl:Class rdf:about="http://www.w3.org/ns/org#FormalOrganization">
    <rdfs:subClassOf rdf:resource="http://www.w3.org/ns/org#Organization"/>
  </owl:Class>
  <owl:Class rdf:about="http://www.w3.org/ns/org#OrganizationalUnit">
    <rdfs:subClassOf rdf:resource="http://www.w3.org/ns/org#Organization"/>
  </owl:Class>
  <owl:Class rdf:about="http://www.w3.org/ns/org#OrganizationalCollaboration">
    <rdfs:subClassOf rdf:resource="http://www.w3.org/ns/org#Organization"/>
  </owl:Class>
</rdf:RDF>

</xsl:stylesheet>
