param (
    [string] $pdiskid
)

#$pdiskid = '0'

$diskhealth_list = Get-PhysicalDisk
$disktemp_list = Get-PhysicalDisk | foreach {$_ | Get-StorageReliabilityCounter}

$TableResult = @()
foreach ($disk in $diskhealth_list)
{
    
    #write-host $disk.FriendlyName,$disk.DeviceId
    $Diskname = $disk.FriendlyName
    $Temperature = ($disktemp_list | where {$_.DeviceId -eq $disk.DeviceId}).Temperature
    $DiskID = ($disktemp_list | where {$_.DeviceId -eq $disk.DeviceId}).DeviceId
    $temp= "" | select name, temperature, id
    $temp.name = $Diskname
    $temp.temperature = $Temperature
    $temp.id = $DiskID
    $TableResult += $temp
}

#$TableResult | ft

@($TableResult | where {$_.id -eq $pdiskid}).Temperature
