#Имя новго соединения
$VPNname = "test-vpn"

#Адрес VPN сервера
$ServerAddress = "8.8.8.8"
#Тип VPN
$VPNType = "sstp"
#Добавление маршрутов если необходимо!

$RemoteNetwork = "172.16.2.0/24; 192.168.50.0/24" # сюдой через ; пишем все подсети



#Устаналвиваем сертификат 
$Scriptpath = Get-Location
$Scriptpath=$Scriptpath.Path + "\CA.crt" 


Import-Certificate -FilePath $Scriptpath -CertStoreLocation Cert:\LocalMachine\Root

#Создаем VPN


$RemoteNetworks = $RemoteNetwork.Split(';') -replace '\s', ''



Add-VpnConnection -Name $VPNname -ServerAddress $ServerAddress -TunnelType $VPNType  -SplitTunneling -Force -RememberCredential -PassThru

#Add-VpnConnection -Name $VPNname -ServerAddress $ServerAddress -TunnelType $VPNType -L2tpPsk $l2tpPsk -SplitTunneling -Force  -PassThru

foreach ($RemoteNetwork in $RemoteNetworks) # Добавляем все подсети к этому VPN
{
    Add-VpnConnectionRoute -ConnectionName $VPNname -DestinationPrefix $RemoteNetwork -PassThru
}

Get-Process powershell | Stop-Process -Force