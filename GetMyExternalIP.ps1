Function Get-MyExternalIP {
param(
[ValidateRange(0,10)][int]$TimeoutSec = 4,
[ValidatePattern("^(http)(s)*\:\/\/")][string[]]$Sites = @(
"http://myexternalip.com/raw",
"https://api.ipify.org/",
"http://www.findmyip.org/",
"http://checkip.dyndns.org",
"http://myip.ru/",
"http://internet.yandex.ru/",
"http://2ip.ru/"
)
)
foreach ($Site in $($Sites | Get-Random -Count $Sites.count))
{
Write-Progress -Activity "Invoke-WebRequest" -Status $Site
try{
$IP = ((Invoke-WebRequest -URI $Site -TimeoutSec $TimeoutSec) | Select-String "(((\d){1,3}\.){3}(\d){1,3})").Matches.Value
} catch{}
if($IP -as [ipaddress]){break}
 
}
 
$IP
}

Get-MyExternalIP