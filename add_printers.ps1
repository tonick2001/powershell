$printerName = "Chel-Agalakova-UchCentr"
$portName = "192.168.20.201"
#get
$driverName = "Kyocera Monochrome Personal XPS Class Driver"
$groupName = ""

$checkPortExists = Get-Printerport -Name $portname -ErrorAction SilentlyContinue
if (-not $checkPortExists) {
Add-PrinterPort -name $portName -PrinterHostAddress $portName }


Add-Printer -Name $printerName -PortName $portName -DriverName $driverName
