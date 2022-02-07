$login="testuser"
$pass = ConvertTo-SecureString "Parol22" -AsPlainText -Force  
$doman = "domain.net"

$duser=$domain+"\"+$login



$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $duser, $pass

$s = New-PSSession -ComputerName "L01-MG02" -Credential $cred
Invoke-Command -Session $s -ScriptBlock {C:\RestoreScripts\05_MsmqQueue.ps1}
Remove-PSSession -Session $s