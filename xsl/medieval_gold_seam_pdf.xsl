<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mpese="http://mpese.ac.uk"
    xmlns:c="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:saxon="http://saxon.sf.net/" extension-element-prefixes="saxon"
    exclude-result-prefixes="xs" version="2.0">

    <!-- Footnote number counter -->
    <xsl:variable name="counter" select="0" saxon:assignable="yes"/>

    <!-- font and sizes -->
    <xsl:variable name="font">Times</xsl:variable>
    <xsl:variable name="subheading-size">14pt</xsl:variable>
    <xsl:variable name="text-size">12pt</xsl:variable>
    <xsl:variable name="list-size">11pt</xsl:variable>
    <xsl:variable name="note-size">10pt</xsl:variable>
    <xsl:variable name="tiny-size">8pt</xsl:variable>


    <!-- match root - create FO document -->
    <xsl:template match="/">
        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="b2022-text-A4" margin-top="1cm"
                    margin-bottom="1cm" margin-left="2.5cm" margin-right="2.5cm">
                    <fo:region-body region-name="xsl-region-body" margin-bottom="1cm"
                        margin-top="1cm"/>
                    <fo:region-before region-name="xsl-region-before" extent="1cm"/>
                    <fo:region-after region-name="xsl-region-after" extent="1cm"/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="b2022-text-A4" initial-page-number="1">
                <fo:static-content flow-name="xsl-region-before">
                    <fo:block font-family="{$font}" font-size="{$note-size}" text-align="center"
                        >Beyond 2022</fo:block>
                </fo:static-content>
                <fo:static-content flow-name="xsl-region-after">
                    <fo:block font-family="{$font}" font-size="{$note-size}" text-align="center">
                        <fo:page-number/>
                    </fo:block>
                </fo:static-content>
                <fo:flow flow-name="xsl-region-body">
                    <xsl:call-template name="header"/>
                    <xsl:call-template name="body"/>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>

    <xsl:template match="tei:text">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:p">
        <fo:block font-family="{$font}" text-align="justify" font-size="{$text-size}"
            space-before="6pt" space-after="6pt">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="tei:gap">
        <xsl:choose>
            <xsl:when test=".[@reason != 'blank page' and @reason != 'blank membrane']">
                <xsl:text>[...]</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:unclear">
        <xsl:text>[...]</xsl:text>
    </xsl:template>

    <xsl:template match="tei:supplied"> [<xsl:apply-templates/>] </xsl:template>

    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="tei:head">
        <fo:block font-family="{$font}" text-align="center" font-size="14pt" space-before="6pt"
            space-after="6pt">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <!-- Start of new pages or membranes -->
    <xsl:template match="tei:pb">
        <fo:block font-family="{$font}" text-align="center" font-size="12pt" space-before="6pt"
            space-after="6pt">
            <xsl:text>[</xsl:text>
            <xsl:choose>
                <xsl:when test=".[@type = 'membrane']">
                    <xsl:text>m. </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>m. </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="@n"/>
            <xsl:choose>
                <xsl:when
                    test="./following-sibling::*[1][@reason = 'blank page' or @reason = 'blank membrane']">
                    <xsl:text> blank</xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:text>]</xsl:text>
        </fo:block>
    </xsl:template>

    <xsl:template match="tei:opener">
        <fo:block font-family="{$font}" text-align="left" font-size="12pt" space-before="6pt"
            space-after="6pt">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="tei:ab">
        <fo:block font-family="{$font}" text-align="left" margin-left="12px" font-size="10pt"
            space-before="4pt" space-after="4pt">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="tei:closer">
        <fo:block font-family="{$font}" text-align="right" font-size="12pt" space-before="6pt"
            space-after="6pt">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>


    <xsl:template match="tei:note">
        <xsl:choose>
            <xsl:when test=".[@type = 'footnote']">
                <saxon:assign name="counter" select="$counter + 1"/>
                <fo:footnote>
                    <fo:inline font-size="6pt" baseline-shift="super">
                        <xsl:value-of select="$counter"/>
                    </fo:inline>
                    <fo:footnote-body>
                        <fo:block text-indent="1cm" font-size="10pt">
                            <fo:inline font-size="6pt" baseline-shift="super" margin-right="5px">
                                <xsl:value-of select="$counter"/>
                            </fo:inline>
                            <xsl:apply-templates/>
                        </fo:block>
                    </fo:footnote-body>
                </fo:footnote>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:ref">
        <fo:basic-link external-destination="url({/@target/string()})" text-decoration="underline"
            color="blue">
            <xsl:apply-templates/>
        </fo:basic-link>
    </xsl:template>

    <!-- ===== NAMED TEMPLATES ===== -->

    <!-- title of the document -->
    <xsl:template name="title">
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="normalize-space(//tei:fileDesc/tei:titleStmt/tei:title) eq ''"
                    >Untitled</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="//tei:fileDesc/tei:titleStmt/tei:title"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="date">
            <xsl:choose>
                <xsl:when
                    test="normalize-space(//tei:profileDesc/tei:creation/tei:date[1]/string()) eq ''"
                    >No date</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="//tei:profileDesc/tei:creation/tei:date[1]/string()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <fo:block font-family="{$font}" font-size="16pt" text-align="center" font-weight="bold">
            <xsl:value-of select="$title"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$date"/>
        </fo:block>
    </xsl:template>

    <xsl:template name="repository-id">
        <fo:block font-family="{$font}" space-before="12pt" font-size="10pt" text-align="left">
            <xsl:value-of
                select="normalize-space(//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:repository)"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of
                select="normalize-space(//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:settlement)"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of
                select="normalize-space(//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno[1])"/>
            <xsl:text>. </xsl:text>
            <xsl:value-of
                select="normalize-space(//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:msName)"/>
            <xsl:text> </xsl:text>
            <xsl:value-of
                select="normalize-space(//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:p)"
            />
        </fo:block>
    </xsl:template>

    <xsl:template name="transcript">
        <xsl:for-each select="//tei:text">
            <xsl:apply-templates/>
        </xsl:for-each>
    </xsl:template>

    <!-- body of the PDF -->
    <xsl:template name="body">
        <xsl:call-template name="transcript"/>
    </xsl:template>

    <!-- header of the PDF -->
    <xsl:template name="header">
        <xsl:call-template name="title"/>
        <xsl:call-template name="repository-id"/>
        <!--<xsl:call-template name="author"/>-->
    </xsl:template>



</xsl:stylesheet>
