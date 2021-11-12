Function RDP_Resetfailure($server)
{
    $ts = qwinsta /server:$server
    $td = $ts | where { ($_ -like "*Disc*" -or $_ -like "*����*" -or $_ -like "*��*") -and $_ -notlike "*services*" -and $_ -notlike "*�������������*" -and $_ -notlike "*Administrator1C*" -and  $_ -notlike "*�����������*"}
    $tdselect = $td # ��� ������� ��� �������� � ���: Login Id State
    
    foreach ($session in $td | Select-String '\s\d+\s')
    {
        $ID = $session.Matches[0].Value.Replace(' ','')
        Write-Host "Reset RDP Failture session ID: $ID"      #������� �������� id ������
        $session.Line      #������� �������� ������
        rwinsta $ID /server:$server            # ����� �������� ������, ���������������� ��� ������
    }
}
 
$server = "127.0.0.1"
RDP_Resetfailure($server)