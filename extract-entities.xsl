<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    version="2.0">
    
    <!-- Main template -->
    <xsl:template match="/">
        
        <!-- Generate persons.json -->
        <xsl:result-document href="persons.json" method="text" encoding="UTF-8">
            {
            <xsl:text>"persons": {</xsl:text>
            <xsl:apply-templates select="//tei:teiHeader/tei:profileDesc/tei:particDesc/tei:listPerson/tei:person" mode="person"/>
            <xsl:text>}</xsl:text>
            }
        </xsl:result-document>
        
        <!-- Generate places.json -->
        <xsl:result-document href="places.json" method="text" encoding="UTF-8">
            {
            <xsl:text>"places": {</xsl:text>
            <xsl:apply-templates select="//tei:listPlace/tei:place" mode="place"/>
            <xsl:text>}</xsl:text>
            }
        </xsl:result-document>
        
        <!-- Generate flora.json -->
        <xsl:result-document href="flora.json" method="text" encoding="UTF-8">
            {
            <xsl:text>"flora": {</xsl:text>
            <xsl:apply-templates select="//tei:name[@type='flora']" mode="flora"/>
            <xsl:text>}</xsl:text>
            }
        </xsl:result-document>
        
        <!-- Generate fauna.json -->
        <xsl:result-document href="fauna.json" method="text" encoding="UTF-8">
            {
            <xsl:text>"fauna": {</xsl:text>
            <xsl:apply-templates select="//tei:name[@type='fauna']" mode="fauna"/>
            <xsl:text>}</xsl:text>
            }
        </xsl:result-document>
        
        <!-- Generate zoological.json -->
        <xsl:result-document href="zoological.json" method="text" encoding="UTF-8">
            {
            <xsl:text>"zoological": {</xsl:text>
            <xsl:apply-templates select="//tei:name[@type='zoological']" mode="zoological"/>
            <xsl:text>}</xsl:text>
            }
        </xsl:result-document>
        
    </xsl:template>
    
    <!-- Template for persons -->
    <xsl:template match="tei:person" mode="person">
        <xsl:text>"</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>": {</xsl:text>
        <xsl:text>"name": "</xsl:text><xsl:value-of select="normalize-space(tei:persName)"/><xsl:text>"</xsl:text>
        <xsl:if test="tei:birth/@when">
            <xsl:text>, "birth": "</xsl:text><xsl:value-of select="tei:birth/@when"/><xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:if test="tei:death/@when">
            <xsl:text>, "death": "</xsl:text><xsl:value-of select="tei:death/@when"/><xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:if test="tei:occupation">
            <xsl:text>, "occupation": "</xsl:text><xsl:value-of select="normalize-space(tei:occupation)"/><xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:if test="tei:note">
            <xsl:text>, "note": "</xsl:text><xsl:value-of select="normalize-space(tei:note)"/><xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:text>}</xsl:text>
        <xsl:if test="position() != last()">, </xsl:if>
    </xsl:template>
    
    <!-- Template for places -->
    <xsl:template match="tei:place" mode="place">
        <xsl:text>"</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>": {</xsl:text>
        <xsl:text>"name": "</xsl:text><xsl:value-of select="normalize-space(tei:placeName[1])"/><xsl:text>"</xsl:text>
        <xsl:if test="tei:placeName[@type='modern']">
            <xsl:text>, "modernName": "</xsl:text><xsl:value-of select="normalize-space(tei:placeName[@type='modern'])"/><xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:if test="tei:location/tei:geo">
            <xsl:text>, "geo": "</xsl:text><xsl:value-of select="normalize-space(tei:location/tei:geo)"/><xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:if test="tei:note">
            <xsl:text>, "note": "</xsl:text><xsl:value-of select="normalize-space(tei:note)"/><xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:text>}</xsl:text>
        <xsl:if test="position() != last()">, </xsl:if>
    </xsl:template>
    
    <!-- Template for flora -->
    <xsl:template match="tei:name[@type='flora']" mode="flora">
        <xsl:text>"</xsl:text><xsl:value-of select="generate-id()"/><xsl:text>": {</xsl:text>
        <xsl:text>"name": "</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>", </xsl:text>
        <xsl:text>"description": "No additional information available."</xsl:text>
        <xsl:text>}</xsl:text>
        <xsl:if test="position() != last()">, </xsl:if>
    </xsl:template>
    
    <!-- Template for fauna -->
    <xsl:template match="tei:name[@type='fauna']" mode="fauna">
        <xsl:text>"</xsl:text><xsl:value-of select="generate-id()"/><xsl:text>": {</xsl:text>
        <xsl:text>"name": "</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>", </xsl:text>
        <xsl:text>"description": "No additional information available."</xsl:text>
        <xsl:text>}</xsl:text>
        <xsl:if test="position() != last()">, </xsl:if>
    </xsl:template>
    
    <!-- Template for zoological names -->
    <xsl:template match="tei:name[@type='zoological']" mode="zoological">
        <xsl:text>"</xsl:text><xsl:value-of select="generate-id()"/><xsl:text>": {</xsl:text>
        <xsl:text>"name": "</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>", </xsl:text>
        <xsl:text>"description": "Scientific name of species."</xsl:text>
        <xsl:text>}</xsl:text>
        <xsl:if test="position() != last()">, </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
