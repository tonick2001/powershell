

$input_appsettings_json_path="F:\test\appsettings.json"
$output_appsettings_json_path="F:\test\appsettings_test.json"

$Variables_json = @{
    ds="Data Source=test-t1-fflsn;Persist Security Info=False;Integrated Security=True"
    RestServiceCreateDoc = "http://load-Tel/edo/api/Contract"
    MSB = "http://test-ilscsm/"
}



$json_content = Get-Content -Encoding UTF8 -Path $input_appsettings_json_path | Out-String | ConvertFrom-Json


$json_content.URLs.RestServiceCreateDoc = $Variables_json["RestServiceCreateDoc"]
$json_content.URLs.Msb = $Variables_json["MSB"]
$json_content.ConnectionStrings.DefaultConnectionString = $Variables_json["ds"]



$json_content |ConvertTo-Json| Out-File $output_appsettings_json_path


 

 
 

