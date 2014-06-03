<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>
<xsl:template match="/">
  <dl>
  <xsl:for-each select="/ROWSET/*">
    <dt><xsl:value-of select="./*[1]"/></dt>
    <dd><xsl:value-of select="./*[2]"/></dd>
  </xsl:for-each>
  </dl>
</xsl:template>
</xsl:stylesheet>
