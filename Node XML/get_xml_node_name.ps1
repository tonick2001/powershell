$xml = [xml]'<Board Title="Система управления взаимоотношениями с клиентами" panels_height="">
  <Panel allow_roles="" allow_users="" deny_roles="" deny_users="" SecurityFunction="Customer" Name="Customer" Title="Абоненты" Src="http://test.net/Customer/Search" />
</Board>'

$panels = Select-Xml -Xml $xml -XPath "//Panel"
$ar = @();
foreach ($panel in $panels.Node) {
 
  $test = $panel.OuterXml -split " ";
 
  foreach ($param in $test)
  {
    if ($param -match '\w+=')
    {
        $matches = [regex]::Matches($param, "\w+=")
        $matches = [regex]::Matches($matches.value, "\w+(?=)")
        $ar += $matches.value
    }

  }

  $ar
}