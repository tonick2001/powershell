$user = Read-Host "Введите логин пользователя"
$days = Read-Host "Введите количетсво дней"

$logs = get-eventlog system  -source Microsoft-Windows-Winlogon -After (Get-Date).AddDays(-$days);
$res = @(); 
ForEach ($log in $logs) {
       if($log.instanceid -eq 7001) {$type = "Logon"}`
       Elseif ($log.instanceid -eq 7002){$type="Logoff"}`
       Else {Continue}` 
       $res += New-Object PSObject -Property @{Time = $log.TimeWritten; "Event" = $type;User = (New-Object System.Security.Principal.SecurityIdentifier $Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])}};
#$res

$newres = @()
foreach ($onestring in $res)
{ 
   if ($onestring.User -like "*$user") 
   {
     $newres+=$onestring
   }
}

$newres