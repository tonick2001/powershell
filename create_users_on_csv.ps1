$userscsv = Get-Content -Path "C:\ps\kpro-users_FULL.csv" 
$users = ConvertFrom-Csv -InputObject $userscsv -Delimiter ';'

foreach ($user in $users) {

    $pwd =  $user.Password | ConvertTo-SecureString -AsPlainText -Force
    New-LocalUser -fullname $user.Fullname -name $user.Name -Password $pwd -PasswordNeverExpires -AccountNeverExpires -UserMayNotChangePassword
    Add-LocalGroupMember -Group "Пользователи удаленного рабочего стола" -Member $user.Name
    
}
