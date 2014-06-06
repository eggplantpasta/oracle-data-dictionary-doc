<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 <xsl:output method="html"/>
 <xsl:template match="/">
   <table>
     <thead><tr>
       <xsl:for-each select="/ROWSET/ROW[1]/*">
         <th><xsl:value-of disable-output-escaping="yes" select="translate(name(),'_',' ')" /></th>
         <xsl:text>&#10;</xsl:text>
       </xsl:for-each>
     </tr></thead><tbody>
     <xsl:for-each select="/ROWSET/*">
       <tr>
         <xsl:for-each select="./*">
           <td><xsl:value-of disable-output-escaping="yes" select="text()"/></td>
           <xsl:text>&#10;</xsl:text>
         </xsl:for-each>
      </tr>
     </xsl:for-each>
   </tbody></table>
 </xsl:template>
</xsl:stylesheet>
