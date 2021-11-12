Function RDP_Resetfailure($server)
{
    $ts = qwinsta /server:$server
    $td = $ts | where { ($_ -like "*Disc*" -or $_ -like "*ƒиск*" -or $_ -like "*®б™*") -and $_ -notlike "*services*" -and $_ -notlike "*јдминистратор*" -and $_ -notlike "*Administrator1C*" -and  $_ -notlike "*А§ђ®≠®бва†вЃа*"}
    $tdselect = $td # ƒл€ отладки или внесени€ в лог: Login Id State
    
    foreach ($session in $td | Select-String '\s\d+\s')
    {
        $ID = $session.Matches[0].Value.Replace(' ','')
        Write-Host "Reset RDP Failture session ID: $ID"      #отладка просмотр id сессии
        $session.Line      #отладка просмотр сессии
        rwinsta $ID /server:$server            # сброс зависших сессий, раскомментируйте эту строку
    }
}
 
$server = "127.0.0.1"
RDP_Resetfailure($server)