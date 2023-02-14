<# 
    Get xml node value with xml namespace
    <enterpriseLibrary.databaseSettings 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
        xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
        defaultInstance="SQL" 
        xmlns="http://www.microsoft.com/practices/enterpriselibrary/08-31-2004/data">
        <parameters>
            <parameter name="database" value="rating_discounting" isSensitive="false" />
            <parameter name="Integrated Security" value="True" isSensitive="false" />
            <parameter name="server" value="F1.net" isSensitive="false" />
        </parameters>
    </enterpriseLibrary.databaseSettings>
#>
$xml=[xml] (Get-Content -Encoding UTF8 -Path 'C:\data.config')
$xpath = "//el:parameter[@name='server']"
$nsManager = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$nsManager.AddNamespace("el", "http://www.microsoft.com/practices/enterpriselibrary/08-31-2004/data")
$server = $xml.SelectSingleNode($xpath, $nsManager) #.value
Write-Output $server