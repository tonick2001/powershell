
#Скрипт просмотра агентов на серверах!
cls
$Error.clear()

$servers = @("L01-CRM01","L01-CRM02","L01-CRM03","L01-TEL01")

$hashtable = @{}
foreach ($srv in $servers)
{
    $srt= Invoke-Command -ComputerName $srv -ScriptBlock {$cmd =  "C:\zabbix_agent\bin\win64\zabbix_agentd.exe" 
                 $cmdex=& $cmd -V
                 [string]$versionstring=$cmdex | Select-String "(\d\.\d\.\d)" 
                 return $versionstring}
    try
    {
        
         $hashtable.Add($srv,($srt.Substring(38,6).Trim()))
    }
    catch {Write-Host $Error}
}

Write-Host "Версия Zabbix агента на серверах:"
$hashtable | Format-Table -Property @{Label= "Сервер"; Expression={$_.name}},@{Label= "Версия Агента"; Expression={$_.value}} -AutoSize



