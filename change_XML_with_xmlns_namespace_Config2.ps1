#<?xml version="1.0" encoding="utf-8"?>
#<dataConfiguration>
#  <xmlSerializerSection type="Microsoft.Practices.EnterpriseLibrary.Data.Configuration.DatabaseSettings, Microsoft.Practices.EnterpriseLibrary.Data, Version=1.2.0.0, Culture=neutral, PublicKeyToken=a188677231350af9">
#    <enterpriseLibrary xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" defaultInstance="Rating&amp;Discounting" xmlns="http://www.microsoft.com/practices/enterpriselibrary/08-31-2004/data">


$input_prod_dataconfiguration_config_xml_path = "F:\test\dataconfiguration.config"
$output_prod_dataconfiguration_config_xml_path = "F:\test\dataconfiguration_test.config"


$ConnectionsString =@{
    name = "Data Source"
    value = "test2"
}


#Get xml content
[xml]$prod_config_xml_content = Get-Content -Path $input_prod_dataconfiguration_config_xml_path
$ns = New-Object System.Xml.XmlNamespaceManager($prod_config_xml_content.NameTable);
$ns.AddNamespace("ns","http://www.microsoft.com/practices/enterpriselibrary/08-31-2004/data")
$ds = $prod_config_xml_content.SelectNodes("//ns:parameter", $ns)



foreach ($element in $ds)
{
    if ($element.name -eq "Data Source"){ $element.value=$ConnectionsString["value"]}
    Write-Host $element.value
}



$prod_config_xml_content.Save($output_prod_dataconfiguration_config_xml_path)