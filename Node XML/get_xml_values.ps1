$xmlFile = Get-Content -Encoding UTF8 -Path "C:\RestoreScripts\00\DEBTORS\config\05web.config"
$xml = [xml]$xmlFile

$nodes = $xml.SelectNodes("//*[@*]")
foreach ($node in $nodes) 
{
    if (($node.Attributes.Count -gt 0) -or ($node.Value.Count -gt 0))
    {
        Write-host "Node: $($node.ParentNode.Name)/$($node.LocalName)" -ForegroundColor Magenta
        foreach ($attribute in $node.Attributes) 
        {
            Write-Host "$($attribute.Name) = $($attribute.Value)"
        }

        if (($node.Value.Count -gt 0) -and ($node.Value -notlike $attribute.Value))
        {
            Write-Host "Value = $($node.Value)"
        }
    }
}

