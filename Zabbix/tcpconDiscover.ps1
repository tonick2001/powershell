$global:ErrorActionPreference="SilentlyContinue"


$tcplisten = Get-NetTCPConnection -State Listen  |
                       Select-Object -Property LocalAddress, LocalPort, 
						        RemoteAddress, RemotePort, State,
                                @{name='Process';expression={(Get-Process -Id $_.OwningProcess).Name}}, CreationTime 

$ports = @{}
foreach ($onetcp in $tcplisten)
{
   
    if ($onetcp.LocalPort -eq 80)
    {
        $ports.Add("$($onetcp.Process) $($onetcp.LocalPort)",$onetcp.LocalPort)
    }
    if ($onetcp.LocalPort -eq 443)
    {
        $ports.Add("$($onetcp.Process) $($onetcp.LocalPort)",$onetcp.LocalPort)
    }
	#REDIS
    if ($onetcp.Process -like  "redis*")
    {
        $ports.Add("$($onetcp.Process) $($onetcp.LocalPort)",$onetcp.LocalPort)
    }
	
	#Rabbit 
    if ($onetcp.Process -like  "RabbitMQ*")
    {
        $ports.Add("$($onetcp.Process) $($onetcp.LocalPort)",$onetcp.LocalPort)
    }
    #SQL 
    if ($onetcp.Process -like  "SQL*")
    {
        $ports.Add("$($onetcp.Process) $($onetcp.LocalPort)",$onetcp.LocalPort)
    }
    

}


#$ports

[string] $discoveryport = "C:\zabbix_agent\tcpcon.json"
[System.Text.Encoding] $Utf8NoBOM = New-Object System.Text.UTF8Encoding $false
[string]$jsonBody= ""

foreach ($port in $ports.Keys)
{
    $cntport = @($tcpconnection | Where-Object {$_.LocalPort -eq $port}).Count 
   
    #$jsonBody += '{"{#PORTNUM}":"' + $port + '", "{#CONCOUNT}":"' + $cntport + '"},'
    $jsonBody += '{"{#PORTNUM}":"' +  $ports.$port + '", "{#SERVICENAME}":"' +  $port + '"},'
    #$jsonBody += '{"{#PORTNUM}":"' + $port +'"},'
}


$jsonBody = $jsonBody.Substring(0,$jsonBody.Length-1)
#$jsonBody

$txt=Get-Content -Path $tmp_file
$txt | ConvertTo-Json



$jsonFull = '{"data":[' + $($jsonBody -replace ',\s$') + ']}'
$jsonFull

[System.IO.File]::WriteAllLines($discoveryport,$jsonFull,$Utf8NoBOM) 
