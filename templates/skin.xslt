<?xml version="1.0"?>

<xsl:stylesheet 
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
  
  <xsl:param name="baseuri"/> <!-- The base URL of the site -->
  <xsl:param name="path"/> <!-- the path of the file below the base -->
  <xsl:param name="news"/> <!-- absolute URL of the news feed file in the workspace -->
  
  <xsl:variable name="versions" select="document('../data/versions.xml')"/>
  
  <xsl:output
      method="xml"
      version="1.0"
      encoding="utf-8"
      doctype-public="-//W3C//DTD XHTML 1.1//EN"
      doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
      indent="yes"/>
  
  <xsl:template match="html:html">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
	<title>jMock - <xsl:value-of select="/html:html/html:head/html:title"/></title>
	<link media="screen" rel="stylesheet" type="text/css" href="{$rpath}jmock.css"/>
	<link media="print" rel="stylesheet" type="text/css" href="{$rpath}print.css"/>
	<link rel="icon" type="image/png" href="{$rpath}icon.png"/>
	<meta http-equiv="Content-Script-Type" content="text/javascript"/>
	<script type="text/javascript" src="prefs.js"><xsl:comment/></script>
	
	<xsl:copy-of select="html:html/html:head/*[not(name()='title')]"/>
      </head>
      
      <body onload="restorePreferredTestFramework()">
	<div id="banner">
	  <a href="{$rpath}index.html"><img id="logo" src="logo.png" alt="jMock"/></a>
	</div>
	
	<div id="center">
	  <xsl:choose>
	    <xsl:when test="$path = 'index.html'">
	      <xsl:attribute name="class">ContentWithNews</xsl:attribute>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:attribute name="class">Content</xsl:attribute>
	    </xsl:otherwise>
	  </xsl:choose>
	  
	  <div id="content">
	    <xsl:apply-templates select="/html:html/html:body/*"/>
	  </div>
	  <xsl:if test="//html:a">
	  	<div class="LinkFootnotes">
	  		<p class="LinkFootnotesHeader">Links:</p>
	  		<xsl:for-each select="//html:a">
	  			<p>
	  				<xsl:number level="any" format="1" />.
	  				<xsl:value-of select="." />:
	  				
	  				<xsl:if test="not(starts-with(string(@href),'http://'))">
	  					<xsl:value-of select="$baseuri"/>
	  					<xsl:text>/</xsl:text>
	  				</xsl:if><xsl:value-of select="@href"/>
	  			</p>
	  		</xsl:for-each>
	  	</div>
	  </xsl:if>
	</div>
	
	<div id="navigation">
	  <div class="MenuGroup">
	    <h1><a href="download.html">Software</a></h1>
	    <xsl:apply-templates select="$versions"/>
	    <p><a href="{$rpath}repository.html">Source Repository</a></p>
	    <p><a href="{$rpath}license.html">Project License</a></p>
	    <p><a href="{$rpath}versioning.html">Version Numbering</a></p>
	    <p><a href="{$rpath}extensions.html">Extensions</a></p>
	  </div>
	  
	  <div class="MenuGroup">
	    <h1>Documentation</h1>
	    <p><a href="{$rpath}getting-started.html">Getting Started</a></p>
	    <p><a href="{$rpath}cookbook.html">Cookbook</a></p>
	    <p><a href="{$rpath}cheat-sheet.html">Cheat Sheet</a></p>
	    <p><a href="{$rpath}javadoc.html">API Documentation</a></p>
	    <p><a href="{$rpath}articles.html">Articles and Papers</a></p>
	    <p><a href="{$rpath}jmock1.html">jMock 1 Documentation</a></p>
	    <p><a href="http://www.mockobjects.com">About Mock Objects</a></p>
	  </div>
	  
	  <div class="MenuGroup">
	    <h1>User Support</h1>
	    <p><a href="{$rpath}mailing-lists.html">Mailing Lists</a></p>
	    <p><a href="http://www.musketeer-labs.com/">Training</a></p>
	    <p><a href="https://github.com/jmock-developers/jmock-library/issues">Issue Tracker</a></p>
	    <p><a href="{$rpath}news-rss2.xml">News Feed (RSS 2.0)</a></p>
	  </div>
	  
	  <div class="MenuGroup">
	    <h1>Credits</h1>
	    <p><a href="{$rpath}team.html">Development Team</a></p>
	    <p><a href="http://www.github.com">Project hosted by Github</a></p>
            <p><a href="http://tango.freedesktop.org">Icons by the Tango Project</a></p>
	  </div>
	</div>
	
	<xsl:if test="$path = 'index.html'">
	  <div id="news">
	    <div class="NewsGroup">
	      <h1>Recent News</h1>
	      <xsl:for-each select="document('../content/news-rss2.xml')/rss/channel/item[position() &lt;= 5]">
		<div class="NewsItem">
		  <h2 class="NewsTitle"><a><xsl:attribute name="href"><xsl:value-of select="link"/></xsl:attribute><xsl:value-of select="title"/></a></h2>
		  <p class="NewsDate"><xsl:value-of select="pubDate"/></p>
		  <div class="NewsText"><xsl:copy-of select="html:body/node()"/></div>
		</div>
	      </xsl:for-each>	    
	      <p class="NewsMore"><a href="{$rpath}news-rss2.xml">News feed (RSS 2.0)</a></p>
	    </div>
	  </div>
	</xsl:if>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="html:a">
    <xsl:copy-of select="."/><sup class="LinkFootnoteRef"><xsl:number level="any" format="1"/></sup>
  </xsl:template>
  
  <xsl:template match="html:span[@class='Version 2']">
  	<xsl:value-of select="$versions//branch[@id='2']/@stable"/>
  </xsl:template>
  
  <xsl:template match="html:span[@class='Version 1']">
  	<xsl:value-of select="$versions//branch[@id=1]/@stable"/>
  </xsl:template>
  
  <xsl:template match="branch">
    <h2><xsl:value-of select="."/></h2>
    <ul>
      <xsl:for-each select="@unstable">
	    <li><a href="{$rpath}download.html">Unstable: <xsl:value-of select="."/></a></li>
      </xsl:for-each>
      <xsl:for-each select="@stable">
	    <li><a href="{$rpath}download.html">Stable: <xsl:value-of select="."/></a></li>
      </xsl:for-each>
    </ul>
  </xsl:template>
  
  <xsl:template match="html:div[@class='Raw']|html:div[@class='JUnit3']|html:div[@class='JUnit4']">
  	<div>
  	  <xsl:apply-templates select="@*"/>
  	  
      <div class="ExampleTestFrameworkSelector">
      	   Show for:
      	   <a class="SelectorJUnit3" href="javascript:selectTestFramework('JUnit3')">JUnit 3</a><a class="SelectorJUnit4" href="javascript:selectTestFramework('JUnit4')">JUnit 4</a><a class="SelectorRaw" href="javascript:selectTestFramework('Raw')">Other</a>
	  </div>

	  <xsl:apply-templates/>
	  
  	</div>
  </xsl:template>
  
</xsl:stylesheet>
