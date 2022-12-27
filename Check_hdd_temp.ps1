### Check HDD Temp for windows 10

#Get-PhysicalDisk | FT FriendlyName, Size, MediaType, SpindleSpeed, HealthStatus, OperationalStatus, DeviceId -AutoSize
#Get-PhysicalDisk | foreach {$_ | Get-StorageReliabilityCounter | fl}

$diskhealth_list = Get-PhysicalDisk
$disktemp_list = Get-PhysicalDisk | foreach {$_ | Get-StorageReliabilityCounter}

$TableResult = @()
foreach ($disk in $diskhealth_list)
{
    
    #write-host $disk.FriendlyName,$disk.DeviceId
    $Diskname = $disk.FriendlyName
    $Temperature = ($disktemp_list | where {$_.DeviceId -eq $disk.DeviceId}).Temperature
    $temp= "" | select name, temperature
    $temp.name = $Diskname
    $temp.temperature = $Temperature
    $TableResult += $temp
}

$TableResult | ft