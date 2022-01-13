#import external variables
$mypath = $MyInvocation.MyCommand.Path
$mypath = Split-Path $mypath -Parent

$servers = @("l01-crm-trns01", "l01-TELRC01")

$foldername = "RestoreScripts\"
$src_file = $mypath+"\files\test.txt"

foreach ($srv in $servers)
{
    $pathsrv = "\\"+$srv+"\C$\"+$foldername
    
    if (!(Test-Path -Path $pathsrv))
    {
       New-Item -Path $pathsrv -ItemType Directory
       Copy-Item -Path $src_file -Destination $pathsrv
    }
    else
    {
       Copy-Item -Path $src_file -Destination $pathsrv 
    }
}