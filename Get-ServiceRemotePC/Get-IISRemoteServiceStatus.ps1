$servers = @("L01-CRM01","L01-CRM02","L01-CRM03","L01-TELRC01",
            "L01-TELRC02","L01-STATE01","L01-STATE02","L01-DBT01")

$result = New-Object System.Collections.Generic.List[System.Object]
foreach ($srv in $servers)
{
    $result.Add(@(Get-Service -Name W3SVC -ComputerName $srv | select {$srv},name,starttype,status))
    
}

Write-Host "****************************"
$result | Sort-Object {$_.Status} | Format-Table -Property @{Label= "Сервер";Expression={$srv}},`
                                    @{Label= "Имя службы"; Expression={$_.name}},`
                                    @{Label= "Тип запуска"; Expression={$_.Starttype}},`
                                    @{Label= "Статус"; Expression={$_.Status}}