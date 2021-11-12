#Создание нового пользователя и добавление его в группу 1С
Write-Host '------------------------'

write-Host "Введите полное ФИО пользователя: " -foregroundcolor red  -NoNewline
$username= Read-Host
Write-Host '------------------------'
 
write-host 'Введите логин пользователя: ' -foregroundcolor red -NoNewline
$userlogin=Read-Host 
Write-Host '------------------------'

write-host 'Введите пароль пользователя: ' -foregroundcolor red -NoNewline
$userpassword=Read-Host  -AsSecureString 
Write-Host '------------------------'


Write-Host 'Введите описание / комментарий: ' -foregroundcolor red -NoNewline
$userinfo = Read-Host 
Write-Host '------------------------'

new-LocalUser -Name $userlogin -Password $userpassword -FullName $username -Description $userinfo `
              -AccountNeverExpires -PasswordNeverExpires -UserMayNotChangePassword


Add-LocalGroupMember -Group "1c_access_UT83" -Member $userlogin
Add-LocalGroupMember -Group "Пользователи удаленного рабочего стола" -Member $userlogin
