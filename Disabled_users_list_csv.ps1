Function Disabled_users()
{

    
    $userscsv = Get-Content -Path "C:\ps\kpro-users_FULL.csv" 
    $users = ConvertFrom-Csv -InputObject $userscsv -Delimiter ';'
    
    $users_server = Get-LocalUser | select name 
    foreach ($item in $users_server)
    {
        if (($item.name -ne "Администратор") -and ($item.name -ne "Гость") -and ($item.name -ne "DefaultAccount") `
            -and ($item.name -ne "WDAGUtilityAccount") -and ($item.name -ne "Administrator1C"))
        {
            #Write-Host $item.name
            foreach ($user in $users) {
                if ($item.name -ne $user.name)`
                    {Disable-LocalUser -Name $item.name}
                else {Enable-LocalUser -Name $item.name}  
                 
            }
        }

    }
}


Disabled_users
