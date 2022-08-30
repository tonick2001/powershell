$global:ErrorActionPreference="SilentlyContinue"
#import external variables
$mypath = $MyInvocation.MyCommand.Path
$mypath = Split-Path $mypath -Parent

$error.clear()
$namelog = $MyInvocation.MyCommand.Name
$namelog = $namelog.split(".")[0]

#Конфигурационный файл агента Zabbix
$configvalues = @{
    LogFile = "LogFile=c:\zabbix_agent\zabbix_agentd.log"
    EnableRemoteCommands = "EnableRemoteCommands=1"
    Server = "Server=mgts-zabbixs01.mgts.corp.net"
    ListenPort = "ListenPort=10050"
    ServerActive = "ServerActive=mgts-zabbixs01.mgts.corp.net"
    
    #external
    #UserParameter=tcpcondiscovery,powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\tcpconDiscover.ps1"
    tcpconDiscover='UserParameter=tcpcondiscovery,powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\tcpconDiscover.ps1"'
    tcpconcount='UserParameter=tcpconcount[*],powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\tcpconcount.ps1" "$1"'
    #configsDiscover='UserParameter=configsdiscovery,powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\configsDiscover.ps1"'
	ProcessDiscover='UserParameter=processdiscovery,powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\ProcessDiscover.ps1"'
    #msmqdiscovery='msmqdiscovery,powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\MSMQDiscovering.ps1"'
    #msmqmessagecount='msmqmessagecount[*],powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\MSMQMessageCount.ps1" "$1"'

    #Тэг принадлежности сервера к контуру и системе
    #HostMetadata="HostMetadata=win.t1.eadr"
	#HostMetadata="HostMetadata=win.t1.msb"
    HostMetadata="HostMetadata=win.t1.forisfix"
    #HostMetadata="HostMetadata=win.t2.wspa"
    #HostMetadata="HostMetadata=win.t2.wfm"
    #HostMetadata="HostMetadata=win.t1.wfm"
    #HostMetadata="HostMetadata=win.t2.forisfix"
    #HostMetadata="HostMetadata=win.t1.ssrs"
    
    


}
$src_folder_zabbix_agent = "$mypath/zabbix_agent"
$serviceName="Zabbix Agent"
#Список серверов
$servers = @("TEST-FF-SL")

#Function Write Log
function Add-WriteLog {
    param (
        [string] $logpath,
        [string] $text,
        [string] $logname
    )
    #Create log folder
    $testlogpath=Test-Path -Path $logpath
    if (!$testlogpath) {
        New-Item -Path $logpath -ItemType "directory"
    }
    $logpathname = "$logpath\$logname"
    Add-Content -Path "$logpathname-$((Get-Date).Year)-$((Get-Date).Month)-$((Get-Date).Day).log"`
            -Value "[$((Get-Date).TimeOfDay)] $text"
    }

Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "*****************************************************"
Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Start script"



foreach ($srv in $servers)
{
    if ((Test-NetConnection -ComputerName $srv).PingSucceeded)
    {
        #Проверяем есть ли севрис на сервере
        if (!@(Get-Service -Name $serviceName -ComputerName $srv).Count -eq 0) 
        {
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Service Zabbix Agent found on $srv"
            #Останавливаем службу
            $ServiceAgentZabbix=Get-Service -Name $serviceName -ComputerName $srv
            Stop-Service $ServiceAgentZabbix
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Stop Service Zabbix Agent on $srv"
            
            $cfg = @("\\$srv\C$\zabbix_agent\conf\zabbix_agentd.win.conf")
            #Удаляем службу
            $service = Get-WmiObject -Class Win32_Service -Filter "Name='zabbix agent'" -ComputerName $srv
            $service.delete() | Out-Null
            #Копируем каталог с агентом забикса на сервер
            Copy-Item -Path $src_folder_zabbix_agent -Destination "\\$srv\C$" -Recurse -Force
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Copy Zabbix Agent on $srv"
            
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Create config Zabbix Agent on $srv"
            #Создаем конфигурационный файл
            if (Test-Path -Path $cfg)
            {
                Remove-Item -Path $cfg -Force
                foreach ($v in $configvalues.Values)
                {
                    Add-Content -Path $cfg -Value $v
                }
                Add-Content -Path $cfg -Value @("Hostname=$srv")
            }
            else {
                foreach ($v in $configvalues.Values)
                {
                    Add-Content -Path $cfg -Value $v 
                }
                Add-Content -Path $cfg -Value @("Hostname=$srv")
            }
           
            #Устанавливаем службу агента забикса
            try {
                Invoke-Command -ComputerName TEST-FF-SIEBEL  -ScriptBlock {
                    Invoke-Expression -Command:'cmd.exe /c "c:\zabbix_agent\bin\win64\zabbix_agentd.exe --config C:\zabbix_agent\conf\zabbix_agentd.win.conf --install"'
                    } -Verbose -ErrorAction stop
                }
                catch 
                {
                    
                    if ($_.Exception.Message -match 'installed successfully') 
                    {
                        $installSuccess = $true
                    }
                    ELSEIF ($_.Exception.Message -match 'already exists') 
                    {
                        $alreadyExists = $true
                    }
                    ELSE {
                        $alreadyExists = $false
                    }
                    if ($installSuccess) 
                    {
                        Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Successfully Installed Zabbix Agent on $srv"
                        Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Start UP Zabbix Agent on $srv"
                        Get-Service -Name $serviceName -ComputerName $srv | Start-Service
                    }
                    ELSEIF ($alreadyExists) 
                    {
                        Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Zabbix Agent Already Exists on $srv"
                        Get-Service -Name $serviceName -ComputerName $srv | Start-Service
                    }
                    ELSE {
                        Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "ERROR: Zabbix Agent not installed on $srv"
                        Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text  $_.Exception.Message
                    }
                }   
            
            
        }
        else{
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Service Zabbix Agent not found on the $srv!"
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Copy agent to [$srv]!"
            Copy-Item -Path $src_folder_zabbix_agent -Destination "\\$srv\C$" -Recurse -Force
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Create config file on [$srv]!"
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Install Service zabbix agent to [$srv]!"
            
            $cfg = @("\\$srv\C$\zabbix_agent\conf\zabbix_agentd.win.conf")
                if (Test-Path -Path $cfg)
                {
                    Remove-Item -Path $cfg -Force
                    foreach ($v in $configvalues.Values)
                    {
                        Add-Content -Path $cfg -Value $v
                    }
                    Add-Content -Path $cfg -Value @("Hostname=$srv")
                }
                else {
                    foreach ($v in $configvalues.Values)
                    {
                        Add-Content -Path $cfg -Value $v 
                    }
                    Add-Content -Path $cfg -Value @("Hostname=$srv")
                }
                
                
            #Устанавливаем службу агента забикса
            try {
                Invoke-Command -ComputerName TEST-FF-SIEBEL  -ScriptBlock {
                    Invoke-Expression -Command:'cmd.exe /c "c:\zabbix_agent\bin\win64\zabbix_agentd.exe --config C:\zabbix_agent\conf\zabbix_agentd.win.conf --install"'
                    } -Verbose -ErrorAction stop
                }
                catch 
                {
                    
                    if ($_.Exception.Message -match 'installed successfully') 
                    {
                        $installSuccess = $true
                    }
                    ELSEIF ($_.Exception.Message -match 'already exists') 
                    {
                        $alreadyExists = $true
                    }
                    ELSE {
                        $alreadyExists = $false
                    }
                    if ($installSuccess) 
                    {
                        Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Successfully Installed Zabbix Agent on $srv"
                        Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Start UP Zabbix Agent on $srv"
                        Get-Service -Name $serviceName -ComputerName $srv | Start-Service
                    }
                    ELSEIF ($alreadyExists) 
                    {
                        Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Zabbix Agent Already Exists on $srv"
                        Get-Service -Name $serviceName -ComputerName $srv | Start-Service
                    }
                    ELSE {
                        Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "ERROR: Zabbix Agent not installed on $srv"
                        Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text  $_.Exception.Message
                    }
                }
 
        }
    }
    else {
        Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "The server [$srv] is unavailable!" 
       

    }
}

Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "End script"