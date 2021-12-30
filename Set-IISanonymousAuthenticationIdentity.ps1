function Set-IISanonymousAuthenticationIdentity
{
    param (
        [string]$user, 
        [string]$pwd , 
        [string]$iisSiteName
       )


    Import-Module WebAdministration
        
    Set-webconfigurationproperty /system.webServer/security/authentication/anonymousAuthentication  -Name Enabled -value True -PSPath "IIS:\Sites\$iisSiteName\"
    Set-webconfigurationproperty /system.webServer/security/authentication/anonymousAuthentication  -Name username -value $user -PSPath "IIS:\Sites\$iisSiteName\"
    Set-webconfigurationproperty /system.webServer/security/authentication/anonymousAuthentication  -Name password -value $pwd -PSPath "IIS:\Sites\$iisSiteName\"

}

Set-IISanonymousAuthenticationIdentity -user "./Администратор" -pwd "P@ssw0rd" -iisSiteName "Default Web Site\RDWeb"

#get-webconfigurationproperty /system.webServer/security/authentication/anonymousAuthentication   -PSPath "IIS:\Sites\$iisSiteName" -Name Enabled
#get-webconfigurationproperty /system.webServer/security/authentication/anonymousAuthentication   -PSPath "IIS:\Sites\$iisSiteName" -Name username