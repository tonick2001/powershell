$xmlFile = Get-Content -Encoding UTF8 -Path "C:\RestoreScripts\00\DEBTORS\config\05web.config"
$xml = [xml]$xmlFile


<#
    get all nodes and attributes in XML
#>
function ProcessNode($node) {
    
  Write-Host "Node name: $($node.Name)" -ForegroundColor Magenta
  Write-Host "Node value: $($node.Value)"
  Write-Host "Node attributes: $($node.Attributes)"
  
  foreach ($childNode in $node.ChildNodes) {
    ProcessNode $childNode
  }
}

ProcessNode $xml.DocumentElement



