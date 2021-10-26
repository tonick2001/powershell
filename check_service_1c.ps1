$Logfile = "C:\scripts\Logs\1CAgent.log"
function WriteLog
{
Param ([string]$LogString)
$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$LogMessage = "$Stamp $LogString"
Add-content $LogFile -value $LogMessage
}


#Проверяем запущена ли служба 1С, если не запущена, то пробуем запустить. 
$servicename='1C:Enterprise 8.3 Server Agent (x86-64)'
#$servicename='Spooler'
$staus=(get-service -name $servicename).Status
if ($staus -eq "Stopped")
{
 Set-Service -Name $servicename -Status Running
 WriteLog "Служба агента не запущена, пытаемся запустить"
}

if ($staus -eq "Running")
{
 Set-Service -Name $servicename -Status Running
 WriteLog "Служба агента запущена!"
}
