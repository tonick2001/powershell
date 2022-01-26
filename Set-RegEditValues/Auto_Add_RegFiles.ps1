<#  
    This is script add values HKU regedit for active and unactive users
#>

$ErrorActionPreference = "Stop"
$pathreg = "TempHive\Software\Business Objects\Suite 11.5\Crystal Reports\Export\Pdf"

$user = "TestUser"

$regtype = "dword"
$regvalue = "00000001"

$remote_server = "rds2"

#Variables script block for remote startup
$scriptblock = {
            param($login, $regtype1, $regvalue1)
            
            function get-sid
                {
                    Param ( $DSIdentity )
                    $ID = new-object System.Security.Principal.NTAccount($DSIdentity)
                    return $ID.Translate( [System.Security.Principal.SecurityIdentifier] ).toString()
                }
            $admin = get-sid $login
            $sid=$admin.SubString(0, $admin.Length)
            $pathreg2 = $sid+"\Software\Business Objects\Suite 11.5\Crystal Reports\Export\Pdf"

            if (Test-Path -Path Registry::HKEY_USERS\$pathreg2)
               {
                    if (!(Get-ItemProperty -Path Registry::HKEY_USERS\$pathreg2 -name "ForceLargerFonts" -ErrorAction SilentlyContinue))
                        { 
                            New-ItemProperty -Path Registry::HKEY_USERS\$pathreg2 -Name "ForceLargerFonts" -PropertyType $regtype1 -Value $regvalue1 
                        }
                    else{
                           Set-ItemProperty -Path Registry::HKEY_USERS\$pathreg2 -Name "ForceLargerFonts" -Value $regvalue1  -Force
                        }
               }
            else
                {
                    New-Item -Path Registry::HKEY_USERS\$pathreg2 -Force | Out-Null
                    New-ItemProperty -Path Registry::HKEY_USERS\$pathreg2 -Name "ForceLargerFonts" -PropertyType $regtype1 -Value $regvalue1
                }
            }
#end scriptblock


if (Test-Path -Path Registry::HKEY_LOCAL_MACHINE\$pathreg) 
 {reg unload HKLM\TempHive}

try
{   #if the user session is not active on the remote server and all processes are stopped
    #upload the remote HKEY_USERS branch of the registry to the local server
    reg load HKLM\TempHive \\$remote_server\C$\Users\$user\ntuser.dat
    if (Test-Path -Path Registry::HKEY_LOCAL_MACHINE\$pathreg)
   {
        if (!(Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\$pathreg -name "ForceLargerFonts" -ErrorAction SilentlyContinue))
            {
                New-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\$pathreg -Name "ForceLargerFonts" -PropertyType $regtype -Value $regvalue
            }
        else{
                Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\$pathreg -Name "ForceLargerFonts" -Value $regvalue -Force
            }
   }  
else
   {
        New-Item -Path Registry::HKEY_LOCAL_MACHINE\$pathreg -Force | Out-Null
        New-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\$pathreg -Name "ForceLargerFonts" -PropertyType $regtype -Value $regvalue
   }
    reg unload HKLM\TempHive 
}
catch{
    #remote start script if user session is active on remote server or some process is running
    Invoke-Command -ComputerName $remote_server -ScriptBlock $scriptblock -ArgumentList ($user,$regtype,$regvalue)
}

#garbage collector
[gc]::collect()