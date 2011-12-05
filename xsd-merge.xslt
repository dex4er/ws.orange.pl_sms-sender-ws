<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema">

    <!-- Stylesheet merges XSD schemas into one document -->
    <!-- Usage: saxonb-xslt -xsl:xsd-merge.xslt -s:input.wsdl -o:output.wsdl -->

    <xsl:output version="1.0" encoding="utf-8" indent="yes" name="xml" />

    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="xsd:schema">
        <xsl:copy-of select="document(xsd:import/@schemaLocation)" />
    </xsl:template>

    <xsl:template match="@*|node()|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()|processing-instruction()|comment()" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
