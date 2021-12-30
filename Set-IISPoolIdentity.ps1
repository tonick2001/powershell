function Set-IISPoolIdentity
{
    param (
        [string] $poolname,
        [string] $user,
        [string] $pwd
    )
    import-module webadministration
    
    $pool = Get-Item "IIS:\AppPools\$poolname"
    $pool.processmodel.identityType = 3
    $pool.processmodel.username  = $user
    $pool.processmodel.password = 
    $pool | set-item
}

Set-IISPoolIdentity -user ".\Администратор" -pwd "P@ssw0rd" -poolname "RDWebAccess" 