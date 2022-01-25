<#
    This is script add HKU Regedit values if users logoff
#>

$userlogin ="admin" 


try {
        New-PSDrive HKU Registry HKEY_USERS -ErrorAction Stop
    }
catch {
    Write-Host "Disk map error"

    }
finally {
    #uses WMI get SID
    $sid=(Get-CimInstance -Class win32_userAccount -Filter "name='$userlogin'").SID    
    #$sid=(Get-LocalUser -Name "admin" | Select-Object Sid).SID
    $pathreg = "\"+$sid+"\Software\Business Objects\Suite 11.5\Crystal Reports\Export\Pdf"

    New-Item -Path HKU:$pathreg -Force | Out-Null
    New-ItemProperty -Path HKU:$pathreg -Name "ForceLargerFonts" -PropertyType "dword" -Value "00000001" 
    }

