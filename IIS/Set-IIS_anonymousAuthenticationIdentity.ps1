$global:ErrorActionPreference="SilentlyContinue"

$mypath = $MyInvocation.MyCommand.Path
$mypath = Split-Path $mypath -Parent

$error.clear()
$namelog = $MyInvocation.MyCommand.Name
$namelog = $namelog.split(".")[0]

$Env:DelLog = 0; 
#Function Write Log
function Add-WriteLog {
    param (
        [ValidateNotNullOrEmpty()] [Parameter(Mandatory=$True)] [string] $logpath,
        [Parameter(Mandatory=$True)] [string] $Message,
        [ValidateNotNullOrEmpty()] [Parameter(Mandatory=$True)] [string] $logname,
        [ValidateSet("ERROR", "Warning", "Success")] [Parameter(Mandatory=$True)] [string] $Result,
        [string] $PathConfig = "",
        [string] $OldValue = "",
        [string] $NewValue = "",
        [string] $e_error = ""
    )
    #Create log folder
    $logpathname = "$logpath\$logname.json";
    $testlogpath=Test-Path -Path $logpath
    if (!$testlogpath) {
        New-Item -Path $logpath -ItemType "directory";
    }
    else {
        if ($Env:DelLog -eq 0) {
            Remove-Item -Path $logpathname -ErrorAction Ignore
            $Env:DelLog = 1
        }    
    }

    $date = "$(Get-Date -Format dd-MM-yyyy)";
    $time = "$(Get-Date  -Format HH:mm:ss)" ;
    $Time_Stamp = $date +" "+ $time;
    
    $NewLogData  = [Ordered] @{
            'Time' = $Time_stamp; 
            'Message' = $Message; 
            'PathConfig' = $PathConfig; 
            'OldValue' = $OldValue;
            'NewValue' = $NewValue;
            'Error' = $e_error;
            'Result' = $Result;} 
    
    $CurrentLog = Get-Content -Path $logpathname -Raw -ErrorAction Ignore | ConvertFrom-Json; 

    if (([string]::IsNullOrEmpty($CurrentLog)))
    {    
  
       $CurrentLog =  @{
            'ServerName' = $Env:Computername;
            'ScriptName' = $logname;
            'ConfigDataLog' = @();
         }
    }
	
    $CurrentLog.ConfigDataLog += $NewLogData 
    $CurrentLog | ConvertTo-Json | Out-File $logpathname;
}

# ****************body****************************
Add-WriteLog -logpath "$mypath\Log" -logname $namelog -message "Startup script" -Result "Success";

try {
    #include external variables file
    . $mypath"./external_variables.ps1";
    Add-WriteLog -logpath "$mypath\Log" -logname $namelog -message "File external_variables.ps1 found" -Result "Success";
}
catch {
    Add-WriteLog -logpath "$mypath\Log" -logname $namelog -message "File external_variables.ps1 not found" -Result "ERROR";
    Break;
}
#*************************************************
try {
    import-module webadministration;
    Add-WriteLog -logpath "$mypath\Log" `
                -logname $namelog `
                -message "import-module webadministration!" `
                -Result "Success";
}
catch{
    Add-WriteLog -logpath "$mypath\Log" `
                -logname $namelog `
                -message "import-module webadministration failed!"  `
                -Result "Error" `
                -e_error $Error[0].Exception;
    break;
}
#Method changed authority settings
function Set-IISanonymousAuthenticationIdentity
{
    param (
        [string]$user, 
        [string]$pwd , 
        [string]$iisSiteName
       )
    Set-webconfigurationproperty /system.webServer/security/authentication/anonymousAuthentication  -Name Enabled -value True -PSPath "IIS:\Sites\$iisSiteName\"
    Set-webconfigurationproperty /system.webServer/security/authentication/anonymousAuthentication  -Name username -value $user -PSPath "IIS:\Sites\$iisSiteName\"
    Set-webconfigurationproperty /system.webServer/security/authentication/anonymousAuthentication  -Name password -value $pwd -PSPath "IIS:\Sites\$iisSiteName\"

}

$unlockOutput = Get-WebConfiguration -Filter /system.webServer/security/authentication/anonymousAuthentication -PSPath MACHINE/WEBROOT/APPHOST | Select-Object enabled
# check locked settings
if (!$unlockOutput.enabled)
{
    Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/security/authentication/anonymousAuthentication" -Name enabled -Value "True"
    Add-WriteLog -logpath "$mypath\Log" `
                -logname $namelog `
                -message "Unlock success" `
                -Result "Success";
}
foreach ($iisname in $iss_service)
{
    try{
        Set-IISanonymousAuthenticationIdentity -user $username -pwd $pass -iisSiteName "Default Web Site\$iisname"
        Add-WriteLog -logpath "$mypath\Log" `
                     -logname $namelog `
                     -message "Login has been chaged for $iisname!" `
                     -Result "Success";
        $uname = get-webconfigurationproperty /system.webServer/security/authentication/anonymousAuthentication -Name username  -PSPath "IIS:\Sites\Default Web Site\$iisname\"
        if (!($uname.value -eq $username))
        {
            
            Add-WriteLog -logpath "$mypath\Log" `
                        -logname $namelog `
                        -message "Login don't chaged for $iisname!" `
                        -Result "ERROR";
        }
    }
    catch{
        Add-WriteLog -logpath "$mypath\Log" `
                    -logname $namelog `
                    -message "Change password for $iisname failed"  `
                    -Result "Error" `
                    -e_error $Error[0].Exception;
         
    }

}
$unlockOutput = Get-WebConfiguration -Filter /system.webServer/security/authentication/anonymousAuthentication -PSPath MACHINE/WEBROOT/APPHOST | Select-Object enabled
if ($unlockOutput.enabled)
{
    Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/security/authentication/anonymousAuthentication" -Name enabled -Value "False"
    Add-WriteLog -logpath "$mypath\Log" `
                -logname $namelog `
                -message "lock success" `
                -Result "Success";
}

Add-WriteLog -logpath "$mypath\Log" `
                -logname $namelog `
                -message "Stop script" `
                -Result "Success" ;
