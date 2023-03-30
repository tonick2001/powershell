# Скрипт переустанавливает или устанавливает zabbix_agent
# Сам агент копируетмя из каталога со скриптом на сервер, а конфиг создается динамически! 
$global:ErrorActionPreference="SilentlyContinue"
# import external variables
$mypath = $MyInvocation.MyCommand.Path
$mypath = Split-Path $mypath -Parent

$error.clear()
$namelog = $MyInvocation.MyCommand.Name
$namelog = $namelog.split(".")[0]
# **********************************************************************
# Конфигурационный файл агента Zabbix
$configvalues =[Ordered] @{
    LogFile = "LogFile=c:\zabbix_agent\zabbix_agent2.log"
    # Параметр не работает на zabbix_agent2
    #EnableRemoteCommands = "EnableRemoteCommands=1"
    Server = "Server=mgts-zabbixs01.mgts.corp.net,mgts-zabbixs02.mgts.corp.net"
    ServerActive = "ServerActive=mgts-zabbixs01.mgts.corp.net,mgts-zabbixs02.mgts.corp.net"
    ListenPort = "ListenPort=10050"
    Timeout = "Timeout=30"

    # TCP connection count
    tcpconcomment = "# TCP connection count"
    tcpconDiscover='UserParameter=tcpcondiscovery,powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\TCP\tcpconDiscover.ps1"'
    tcpconcount='UserParameter=tcpconcount[*],powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\TCP\tcpconcount.ps1" "$1"'
    # Config discovering
    configsDiscoverComment = "# Config FF discovering"
    configsDiscover='UserParameter=configsdiscovery,powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\ConfigDicovering\configsDiscover.ps1"'
    # Process Discovering
    ProcessDiscoverComment = "# Process Discovering"
	ProcessDiscover='UserParameter=processdiscovery,powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\Process\ProcessDiscover.ps1"'
    
    # Integration links monitoring 
    IntegrationComment = "# Integration links monitoring ForiFix"
    getconfigstopath ='UserParameter=getconfigstopath,powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\CheckLinksPortStatus\GetPathConfigToFile.ps1"'
    DicoveringLinks = 'UserParameter=Dicovering.Links,powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\CheckLinksPortStatus\GetLinksFromConfigs.ps1"'
    CheckPortStatus1 = 'UserParameter=CheckPortStatus1[*],powershell -NoProfile -executionpolicy bypass -File "C:\zabbix_agent\scripts\CheckLinksPortStatus\CheckStatusPort.ps1" "$1"'

    # Тэг принадлежности сервера к контуру и системе
    HostMetadata="HostMetadata=win.t1.System"
}
# **********************************************************************
$src_folder_zabbix_agent = "$mypath/zabbix_agent"
$serviceName="Zabbix Agent"

$servers = @("L01-TEST02") 

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
    Write-Output "$("*"*20)"
    Write-Output "Server: $srv"
    if ((Test-NetConnection -ComputerName $srv).PingSucceeded)
    {
        # Проверяем есть ли сервис на сервере
        $testservice = Get-Service -Name "$serviceName*" -ComputerName $srv
        if (!@($testservice).Count -eq 0) 
        {
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Service Zabbix Agent found on $srv"
            Write-Output "Service Zabbix Agent found on $srv"
            # Останавливаем службу
            $ServiceAgentZabbix=Get-Service -Name "$serviceName*" -ComputerName $srv
            Stop-Service $ServiceAgentZabbix
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Stop and Uninstall Service Zabbix Agent on $srv"
            Write-Output "Stop and Uninstall Service Zabbix Agent on $srv"
            
            $cfg = @("\\$srv\C$\zabbix_agent\conf\zabbix_agent2.win.conf")
            # Удаляем службу
            $service = Get-WmiObject -Class Win32_Service -Filter "Name='$($ServiceAgentZabbix.Name)'" -ComputerName $srv
            $service.delete() | Out-Null
            Invoke-Command -ComputerName $srv -ScriptBlock {Remove-Item -Path HKLM:"\SYSTEM\CurrentControlSet\Services\EventLog\Application\Zabbix Agent 2" -Recurse}

            # Удаляем все из каталока агента кроме txt файлов
            Remove-Item -Path "\\$srv\C$\zabbix_agent\" -Exclude *.txt -Recurse -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            Write-Output "Deleted all files in folder zabbix_agent excluding *.txt"
            # Копируем каталог с агентом забикса на сервер
            Copy-Item -Path $src_folder_zabbix_agent -Destination "\\$srv\C$" -Recurse -Force
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Copy Zabbix Agent on $srv"
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Create config Zabbix Agent on $srv"
            Write-Output "Copy Zabbix Agent and Create config Zabbix Agent on $srv"
            # Создаем конфигурационный файл
            foreach ($v in $configvalues.Values)
            {
                if (($v -match "#") -or ($v -match "HostMetadata"))
                {
                    Add-Content -Path $cfg -Value ""     
                }
                Add-Content -Path $cfg -Value $v 
            }
            Add-Content -Path $cfg -Value "" 
            Add-Content -Path $cfg -Value @("Hostname=$srv")
            
            # Устанавливаем службу агента забикса
            $res = Invoke-Command -ComputerName $srv  -ScriptBlock {
                Invoke-Expression -Command:'c:\windows\system32\cmd.exe /c "c:\zabbix_agent\bin\win64\zabbix_agent2.exe --config C:\zabbix_agent\conf\zabbix_agent2.win.conf --install"'
                } -Verbose -ErrorAction SilentlyContinue
             
            IF ($res -match 'installed successfully') 
            {
                Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Successfully Installed Zabbix Agent on $srv"
                Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Start UP Zabbix Agent on $srv"
                Write-Output "Successfully Installed Zabbix Agent! Start UP Zabbix Agent on $srv!"
                Get-Service -Name "$serviceName*" -ComputerName $srv | Start-Service
            }
            ELSEIF ($res -match 'already exists') 
            {
                Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Zabbix Agent Already Exists on $srv"
                Write-Output "Zabbix Agent Already Exists on $srv"
                Write-Output $res
                Get-Service -Name "$serviceName*" -ComputerName $srv | Start-Service
            }
            ELSE {
                Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "ERROR: Zabbix Agent not installed on $srv"
                Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text  $res
                Write-Output "ERROR: Zabbix Agent not installed on $srv"
                Write-Output $res
            }
         
        }
        ELSE{
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Service Zabbix Agent not found on the $srv!"
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Copy agent to [$srv]!"
            Write-Output "Service Zabbix Agent not found on the $srv!"
            Write-Output "Copy agent to [$srv]!"
            Copy-Item -Path $src_folder_zabbix_agent -Destination "\\$srv\C$" -Recurse -Force
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Create config file on [$srv]!"
            Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Install Service zabbix agent to [$srv]!"
            Write-Output "Create config file on [$srv]!"
            Write-Output "Install Service zabbix agent to [$srv]!"
            if (test-path -Path "\\$srv\C$\zabbix_agent\")
            {
                # Удаляем все из каталока агента кроме txt файлов
                Remove-Item -Path "\\$srv\C$\zabbix_agent\" -Exclude *.txt -Recurse -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            } 
            # Копируем каталог с агентом забикса на сервер
            Copy-Item -Path $src_folder_zabbix_agent -Destination "\\$srv\C$" -Recurse -Force   
            $cfg = @("\\$srv\C$\zabbix_agent\conf\zabbix_agent2.win.conf")
            foreach ($v in $configvalues.Values)
            {
                if (($v -match "#") -or ($v -match "HostMetadata"))
                {
                    Add-Content -Path $cfg -Value ""     
                }
                Add-Content -Path $cfg -Value $v 
            }
            Add-Content -Path $cfg -Value "" 
            Add-Content -Path $cfg -Value @("Hostname=$srv")
            
            #Устанавливаем службу агента забикса
            $res = Invoke-Command -ComputerName $srv  -ScriptBlock {
                Invoke-Expression -Command:'c:\windows\system32\cmd.exe /c "c:\zabbix_agent\bin\win64\zabbix_agent2.exe --config C:\zabbix_agent\conf\zabbix_agent2.win.conf --install"'
                } -Verbose -ErrorAction SilentlyContinue
        
            if ($res -match 'installed successfully') 
            {
                Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Successfully Installed Zabbix Agent on $srv"
                Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Start UP Zabbix Agent on $srv"
                Write-Output "Successfully Installed Zabbix Agent on $srv"
                Write-Output "Startup Zabbix Agent on $srv"
                Get-Service -Name "$serviceName*" -ComputerName $srv | Start-Service
            }
            ELSEIF ($res -match 'already exists') 
            {
                Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "Zabbix Agent Already Exists on $srv"
                Write-Output "Zabbix Agent Already Exists on $srv"
                Write-Output $res
                Get-Service -Name "$serviceName*" -ComputerName $srv | Start-Service
            }
            ELSE {
                Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "ERROR: Zabbix Agent not installed on $srv"
                Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text  $res
                Write-Output "ERROR: Zabbix Agent not installed on $srv"
                Write-Output $res
            }
        }
    }
    else {
        Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "The server [$srv] is unavailable!" 
        Write-Output "The server [$srv] is unavailable!"
    }
}
Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "End script"