function Get-LocationScript {    
# В скрипте писать: $Script = Get-LocationScript
    filter Get-ScriptFilePath {
        if ( $psise ){
            $psise.CurrentFile.FullPath
        } else {
            $PSCommandPath
        }
    }

    $HT = @{}
    $HT.Add('PathFile'  ,([string]$( Get-ScriptFilePath              )))
    $HT.Add('PathFolder',([string]$( Split-Path $HT.PathFile -Parent )))
    $HT.Add('File'      ,([string]$( Split-Path $HT.PathFile -Leaf   )))
    $HT.Add('Name'      ,([string]$( $HT.File.Replace('.ps1',$null)  )))
    $HT.Add('LogFile'   ,([string]$( $HT.Name + '.log'               )))
    $HT.Add('LogPath'   ,([string]$( $null                           )))
    $HT.Add('LogExt'    ,([string]$( $null                           )))

    $result = New-Object PSObject -Property $HT
    return $result | select Name,File,PathFile,PathFolder,LogFile,LogPath,LogExt
}

$pathTo = "C:\ZabbixAgent"
$pathFrom = (Get-LocationScript).PathFolder

Copy-Item $pathFrom $pathTo -Force -Recurse

Try {
    if (Get-Service "Zabbix Agent" -ErrorAction Stop) {
        if ((Get-Service "Zabbix Agent").Status -ne "Running") {
            Try {
                Start-Service "Zabbix Agent" -ErrorAction Stop
            } Catch {
                #################
            }
        }
    }
} Catch {
    New-Service -Name "Zabbix Agent" -BinaryPathName '"C:\ZabbixAgent\bin\zabbix_agentd.exe" --config "C:\ZabbixAgent\bin\zabbix_agentd.conf"' -StartupType Automatic -Description "Provides system monitoring"
}