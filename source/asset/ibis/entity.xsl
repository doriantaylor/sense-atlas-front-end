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
<xsl:variable name="PM"   select="'https://vocab.methodandstructure.com/process-model#'"/>

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
  <h3>ibis:entity-heading</h3>
</x:doc>

<xsl:template name="ibis:entity-heading">
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="type">
    <xsl:message terminate="yes">`type` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="value">
    <xsl:message terminate="yes">`value` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="can-write">
    <xsl:message terminate="yes">`can-write` parameter required</xsl:message>
  </xsl:param>

  <h1 class="heading">
    <xsl:choose>
      <xsl:when test="$can-write">
        <xsl:call-template name="ibis:banner">
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="show-icon" select="false()"/>
        </xsl:call-template>
        <xsl:call-template name="ibis:upgrade-downgrade">
          <xsl:with-param name="subject" select="$subject"/>
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="can-write" select="$can-write"/>
        </xsl:call-template>
        <form accept-charset="utf-8" action="" class="description" method="POST">
          <textarea class="heading" name="= rdf:value"><xsl:value-of select="substring-before($value, $rdfa:UNIT-SEP)"/></textarea>
          <button class="fa fa-sync" aria-label="Save Text" title="Save Text"></button>
        </form>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="ibis:banner">
          <xsl:with-param name="type" select="$type"/>
        </xsl:call-template>
        <p>
          <xsl:attribute name="property">rdf:value</xsl:attribute>
          <xsl:value-of select="substring-before($value, $rdfa:UNIT-SEP)"/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </h1>
</xsl:template>

<x:doc>
  <h3>ibis:banner</h3>
</x:doc>

<xsl:template name="ibis:banner">
  <xsl:param name="type">
    <xsl:message terminate="yes">`type` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="show-icon" select="true()"/>


  <xsl:variable name="label">
    <xsl:call-template name="skos:get-class-label">
      <xsl:with-param name="class" select="$type"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="icon">
    <xsl:call-template name="skos:get-class-label">
      <xsl:with-param name="class" select="$type"/>
      <xsl:with-param name="icon" select="true()"/>
    </xsl:call-template>
  </xsl:variable>

  <p role="banner">
    <xsl:value-of select="$label"/>
    <xsl:text> </xsl:text>
    <xsl:if test="$show-icon">
      <span role="presentation" class="fa"><xsl:value-of select="$icon"/></span>
    </xsl:if>
  </p>
</xsl:template>

<x:doc>
  <h3>ibis:upgrade-downgrade</h3>
  <p>This handles <code>ibis:Issue</code> → <code>pm:Goal</code> → <code>pm:Target</code> and back, as well as a toggle for <code>ibis:Argument</code>. The toggle for <code>ibis:Position</code> ↔ <code>pm:Task</code> are in the former's template.</p>
  <p>Note that upgrading is straightforward but <em>downgrading</em> is going to be tricky.</p>
  <ul>
    <li>Downgrading a <code>pm:Target</code> to a <code>pm:Goal</code> will mean changing (plus inverses) any <code>pm:anchors</code> to <code>ibis:specializes</code>, and <code>pm:initiates</code> to <code>ibis:response</code>, and removing <code>pm:budget</code> and <code>pm:due</code>.</li>
    <li>Downgrading a <code>pm:Goal</code> to an <code>ibis:Issue</code> (or <code>ibis:Argument</code>) involves changing any <code>pm:wanted-by</code> to <code>ibis:endorsed-by</code>.</li>
    <li><code>ibis:Argument</code> will behave like a decorator class which is toggled on and off, except if the only other class is <code>ibis:Issue</code>, in which case <code>ibis:Argument</code> replaces it.</li>
    <li>May as well add <code>ibis:Invariant</code> as another decorator class since we're in here.</li>
    <li>Since goals and targets are <em>not</em> invariant, <code>ibis:Invariant</code> should be removed if you upgrade an issue or argument to a goal or target.</li>
    <li>The <code>ibis:Invariant</code> toggle should also be disabled for <code>pm:Goal</code> and <code>pm:Target</code>.</li>
    <li>The issue icon should change from issue to argument if it is an argument (?).</li>
  </ul>
</x:doc>

<xsl:template name="ibis:upgrade-downgrade">
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="type">
    <xsl:message terminate="yes">`type` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="can-write">
    <xsl:message terminate="yes">`can-write` parameter required</xsl:message>
  </xsl:param>

  <xsl:variable name="types-padded" select="concat(' ', normalize-space($type), ' ')"/>

  <xsl:variable name="core-types">
    <xsl:variable name="_">
      <xsl:call-template name="str:token-intersection">
        <xsl:with-param name="left" select="$type"/>
        <xsl:with-param name="right" select="concat($IBIS, 'Issue ', $PM, 'Goal ', $PM, 'Target')"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length(normalize-space($_))">
        <xsl:value-of select="$_"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($IBIS, 'Issue')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="core-padded" select="concat(' ', normalize-space($core-types), ' ')"/>

  <xsl:variable name="pm-test">
    <xsl:call-template name="str:token-intersection">
      <xsl:with-param name="left" select="$type"/>
      <xsl:with-param name="right" select="concat($PM, 'Goal ', $PM, 'Target')"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="is-pm" select="normalize-space($pm-test) != ''"/>
  <xsl:variable name="is-argument" select="contains($types-padded, concat(' ', $IBIS, 'Argument '))"/>

  <nav role="menu">
    <form xsl:use-attribute-sets="cgto:form-post-self">
      <!-- downgrade from target or goal to issue (or argument) -->
      <xsl:call-template name="ibis:downgrade-target">
        <xsl:with-param name="subject" select="$subject"/>
      </xsl:call-template>
      <xsl:call-template name="ibis:downgrade-goal">
        <xsl:with-param name="subject" select="$subject"/>
      </xsl:call-template>
      <xsl:variable name="class-name">
        <xsl:choose>
          <xsl:when test="$is-argument">fa-comments</xsl:when>
          <xsl:otherwise>fa-exclamation-triangle</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <button class="fa {$class-name}">
        <xsl:choose>

          <xsl:when test="$is-pm and not($is-argument)">
            <!-- only add the name if this is true, that way we keep value for css -->
            <xsl:attribute name="name">rdf:type :</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="disabled">disabled</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:attribute name="value">ibis:Issue</xsl:attribute>
        </button>
    </form>
    <form xsl:use-attribute-sets="cgto:form-post-self">
      <!-- remove ibis:Invariant -->
      <input type="hidden" name="- rdf:type :" value="ibis:Invariant"/>
      <!-- unconditionally remove ibis:Issue -->
      <input type="hidden" name="- rdf:type :" value="ibis:Issue"/>
      <!-- downgrade from target to goal (if target) -->
      <xsl:call-template name="ibis:downgrade-target">
        <xsl:with-param name="subject" select="$subject"/>
      </xsl:call-template>
      <button name="rdf:type :" value="pm:Goal" class="fa fa-flag-checkered">
        <xsl:choose>
          <xsl:when test="contains($core-padded, concat(' ', $PM, 'Goal '))">
            <xsl:attribute name="disabled">disabled</xsl:attribute>
            <xsl:attribute name="aria-label">Goal</xsl:attribute>
            <xsl:attribute name="title">Goal</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="aria-label">Change to Goal</xsl:attribute>
            <xsl:attribute name="title">Change to Goal</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </button>
    </form>
    <form xsl:use-attribute-sets="cgto:form-post-self">
      <!-- remove ibis:Invariant -->
      <input type="hidden" name="- rdf:type :" value="ibis:Invariant"/>
      <!-- unconditionally remove pm:Goal and ibis:Issue -->
      <input type="hidden" name="- rdf:type :" value="ibis:Issue"/>
      <input type="hidden" name="- rdf:type :" value="pm:Goal"/>
      <button name="rdf:type :" value="pm:Target" class="fa fa-bullseye">
        <xsl:choose>
          <xsl:when test="contains($core-padded, concat(' ', $PM, 'Target '))">
            <xsl:attribute name="disabled">disabled</xsl:attribute>
            <xsl:attribute name="aria-label">Target</xsl:attribute>
            <xsl:attribute name="title">Target</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="aria-label">Change to Target</xsl:attribute>
            <xsl:attribute name="title">Change to Target</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </button>
    </form>
    <menu>
      <li>
        <form xsl:use-attribute-sets="cgto:form-post-self">
          <xsl:variable name="css-class">
            <xsl:text>fa </xsl:text>
            <xsl:choose>
              <xsl:when test="$is-argument">fa-exclamation-triangle</xsl:when>
              <xsl:otherwise>fa-comments</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <!-- add or remove ibis:Argument class, or replace with ibis:Issue if no other classes -->
          <input type="hidden" name="rdf:type :" value="ibis:Issue">
            <xsl:if test="$is-pm or not($is-argument)">
              <xsl:attribute name="disabled">disabled</xsl:attribute>
            </xsl:if>
          </input>

          <button>
            <xsl:choose>
              <xsl:when test="$is-argument">
                <xsl:attribute name="class">
                  <xsl:value-of select="concat($css-class, ' toggled')"/>
                </xsl:attribute>
                <xsl:attribute name="name">- rdf:type :</xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="class">
                  <xsl:value-of select="$css-class"/>
                </xsl:attribute>
                <xsl:attribute name="name">rdf:type :</xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="value">ibis:Argument</xsl:attribute>
            <xsl:attribute name="aria-label">Toggle Argument</xsl:attribute>
            <xsl:attribute name="title">Toggle Argument</xsl:attribute>
          </button>
        </form>
      </li>
      <li>
        <form xsl:use-attribute-sets="cgto:form-post-self">
          <!-- disable if pm:Goal or pm:Target -->
          <xsl:variable name="is-invariant" select="contains($types-padded, concat(' ', $IBIS, 'Invariant '))"/>
          <xsl:variable name="toggled">
            <xsl:if test="$is-invariant"><xsl:text> toggled</xsl:text></xsl:if>
          </xsl:variable>
          <button class="fa fa-mountain{$toggled}" aria-label="Toggle Invariant" title="Toggle Invariant">
            <xsl:choose>
              <xsl:when test="$is-invariant">
                <xsl:attribute name="name">- rdf:type :</xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="name">rdf:type :</xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="value">ibis:Invariant</xsl:attribute>
            <xsl:if test="$is-pm">
              <xsl:attribute name="disabled">disabled</xsl:attribute>
            </xsl:if>
          </button>
        </form>
      </li>
    </menu>
  </nav>
</xsl:template>

<x:doc>
  <h3>ibis:downgrade-target</h3>
</x:doc>

<xsl:template name="ibis:downgrade-target">
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>

  <xsl:variable name="specializes">
    <xsl:apply-templates select="." mode="rdfa:multi-object-resources">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="predicates" select="concat($PM, 'anchors ^', $PM, 'anchored-by')"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:if test="string-length($specializes)">
    <xsl:call-template name="ibis:hidden-fields">
      <xsl:with-param name="name">- pm:anchors :</xsl:with-param>
      <xsl:with-param name="values" select="$specializes"/>
    </xsl:call-template>
    <xsl:call-template name="ibis:hidden-fields">
      <xsl:with-param name="name">-! pm:anchored-by :</xsl:with-param>
      <xsl:with-param name="values" select="$specializes"/>
    </xsl:call-template>
    <xsl:call-template name="ibis:hidden-fields">
      <xsl:with-param name="name">ibis:specializes :</xsl:with-param>
      <xsl:with-param name="values" select="$specializes"/>
    </xsl:call-template>
  </xsl:if>

  <xsl:variable name="response">
    <xsl:apply-templates select="." mode="rdfa:multi-object-resources">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="predicates" select="concat($PM, 'initiates ^', $PM, 'initiated-by')"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:if test="string-length($specializes)">
    <xsl:call-template name="ibis:hidden-fields">
      <xsl:with-param name="name">- pm:initiates :</xsl:with-param>
      <xsl:with-param name="values" select="$response"/>
    </xsl:call-template>
    <xsl:call-template name="ibis:hidden-fields">
      <xsl:with-param name="name">-! pm:initiated-by :</xsl:with-param>
      <xsl:with-param name="values" select="$response"/>
    </xsl:call-template>
    <xsl:call-template name="ibis:hidden-fields">
      <xsl:with-param name="name">ibis:response :</xsl:with-param>
      <xsl:with-param name="values" select="$response"/>
    </xsl:call-template>
  </xsl:if>

  <input type="hidden" name="- pm:budget"/>
  <input type="hidden" name="- pm:due"/>
  <input type="hidden" name="- rdf:type :" value="pm:Target"/>
</xsl:template>

<x:doc>
  <h3>ibis:downgrade-goal</h3>
</x:doc>

<xsl:template name="ibis:downgrade-goal">
  <xsl:param name="subject">
    <xsl:message terminate="yes">`subject` parameter required</xsl:message>
  </xsl:param>

  <xsl:variable name="endorsed-by">
    <xsl:apply-templates select="." mode="rdfa:multi-object-resources">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="predicates" select="concat($PM, 'wanted-by ^', $PM, 'wants')"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:if test="string-length($endorsed-by)">
    <xsl:call-template name="ibis:hidden-fields">
      <xsl:with-param name="name">- pm:wanted-by :</xsl:with-param>
      <xsl:with-param name="values" select="$endorsed-by"/>
    </xsl:call-template>
    <xsl:call-template name="ibis:hidden-fields">
      <xsl:with-param name="name">-! pm:wants :</xsl:with-param>
      <xsl:with-param name="values" select="$endorsed-by"/>
    </xsl:call-template>
    <xsl:call-template name="ibis:hidden-fields">
      <xsl:with-param name="name">ibis:endorsed-by :</xsl:with-param>
      <xsl:with-param name="values" select="$endorsed-by"/>
    </xsl:call-template>
  </xsl:if>

  <!--<input type="hidden" name="- pm:budget"/>
  <input type="hidden" name="- pm:due"/>-->
  <input type="hidden" name="- rdf:type :" value="pm:Goal"/>
</xsl:template>


<x:doc>
  <h3>ibis:hidden-fields</h3>
</x:doc>

<xsl:template name="ibis:hidden-fields">
  <xsl:param name="name">
    <xsl:message terminate="yes">`name` parameter required</xsl:message>
  </xsl:param>
  <xsl:param name="values">
    <xsl:message terminate="yes">`values` parameter required</xsl:message>
  </xsl:param>

  <xsl:variable name="first">
    <xsl:call-template name="str:safe-first-token">
      <xsl:with-param name="tokens" select="$values"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="string-length($first)">
    <input type="hidden" name="{$name}" value="{$first}"/>
  </xsl:if>

  <xsl:variable name="rest" select="substring-after(normalize-space($values), ' ')"/>
  <xsl:if test="string-length($rest)">
    <xsl:call-template name="ibis:hidden-fields">
      <xsl:with-param name="name" select="$name"/>
      <xsl:with-param name="values" select="$rest"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<x:doc>
  <h3>ibis:downgrade-goal</h3>
</x:doc>

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
  <h3>ibis:one-endorsement</h3>
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
