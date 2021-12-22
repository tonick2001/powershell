$input_prod_framework_machine_config_xml_path = "F:\test\machine1.config"
$output_prod_framework_machine_config_xml_path = "F:\test\machine_test1.config"


$identity = @{
    
    impersonate="true"
    userName ="test" 
    pwd = "testpass"
}

$sessionState =@{
    Data_Source = "Integrated Security=SSPI;Data Source=ff-test-db01;Max Pool Size=1000;"     
}



#Get xml content
$prod_config_xml_content=[xml] (Get-Content -Encoding UTF8 -Path $input_prod_framework_machine_config_xml_path)


#user&password
$P1_FORIS_Temp=$prod_config_xml_content.configuration."system.web".identity
$P1_FORIS_Temp.userName = $identity["userName"]
$P1_FORIS_Temp.password = $identity["pwd"]
$P1_FORIS_Temp.impersonate = $identity["impersonate"]

#change datasource
$P1_FORIS_Temp=$prod_config_xml_content.configuration."system.web".sessionState
$P1_FORIS_Temp.sqlConnectionString = $sessionState["Data_Source"]


$prod_config_xml_content.Save($output_prod_framework_machine_config_xml_path)    