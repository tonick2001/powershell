$input_prod_dataconfiguration_config_xml_path = "F:\test\dataconfiguration.config"
$output_prod_dataconfiguration_config_xml_path = "F:\test\dataconfiguration_test.config"


$ConnectionsString =@{
    name = "Data Source"
    value = "http:\\test.com"
}


#Get xml content
$prod_config_xml_content = New-Object XML
$prod_config_xml_content.Load($input_prod_dataconfiguration_config_xml_path)
$P1_Temp = $prod_config_xml_content.SelectNodes("//parameter")

foreach ($element in $P1_Temp)
{
    if ($element.name -eq "Data Source"){ $element.value=$ConnectionsString["value"]}
}



$prod_config_xml_content.Save($output_prod_dataconfiguration_config_xml_path)