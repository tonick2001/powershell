$info = @{}
try {
        $t=Invoke-Command -ComputerName t2-merc-fe01  -ScriptBlock {
            Invoke-Expression -Command:'c:\windows\system32\cmd.exe /c C:\"Program Files"\Redis\redis-cli.exe info'
            } -Verbose -ErrorAction stop
        #Write-Host $t | Select-String -Pattern "used_memory"
        $t_split = $t -split " "
        

        foreach ($str in $t_split)
        {
        $temp = $str -split ":"
        $info.add($temp[0],$temp[1])
        }

        ConvertTo-Json $info
    }

catch 
     {
        $_.Exception.Message
     }