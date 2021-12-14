### This is function searching events security of logon/logoff user 

#Kiriyanova.E.A
function EventLogonLogoffUser {

    param (
        [string] $username, 
        [string] $dateafter,
        [string] $datebefore     
        )
    
    $Events=Get-EventLog security -message "*$username*" -after (Get-date $dateafter) -Before (Get-date $datebefore)  -InstanceId 4624,4634,4647,4779

    $res = @()
    foreach ($event in $Events)
    {
    
        if(($event.InstanceID -eq 4624) -and ($event.ReplacementStrings[8] -eq 10)) {$type="Пользователь успешно вошел на сервер"; $user=$event.ReplacementStrings[5]}` 
            Elseif (($event.InstanceId -eq 4634) -or ($event.InstanceId -eq 4647) -and ($event.ReplacementStrings[4] -eq 10))`
                    {$type="Пользователь успешно вышел с сервера"; $user=$event.ReplacementStrings[1]}`
                Elseif ($event.InstanceId -eq 4779)  {$type="Пользователь отключил сеанс сервера терминала "}
        Else {Continue}

        $res += New-Object -TypeName psobject -Property @{"Time"=$event.TimeWritten;User=$user; Event=$type; EventID=$event.InstanceId; Address=$event.ReplacementStrings[18] }
       
    }
    Write-Output $res
}

$uname = Read-Host "Введите имя пользователя"
$dateafter = Read-Host "Введите с какой даты начать поиск в формате dd/mm/yyyy"
$datebefore = Read-Host "Введите до какой даты нужно искать в формате dd/mm/yyyy"
EventLogonLogoffUser -username $uname -dateafter $dateafter -datebefor $datebefore | export-csv -Encoding UTF8 -Path c:\ps\event_logon_logff_user.csv -NoTypeInformation -Delimiter ";"

