 #Get xml content
    $WFMInetpubNVGWeb_content=[xml] (Get-Content -Encoding UTF8 -Path $wfm_inetpubnvgweb_src)

    #Get prod values and change test values
    try
    {   
        $nodeproxy = $WFMInetpubNVGWeb_content.SelectSingleNode('//proxy')
        $nodeproxy.ParentNode.InnerXml = $nodeproxy.ParentNode.InnerXml.Replace($nodeproxy.OuterXml, $nodeproxy.OuterXml.Insert(0,"<!--").Insert($nodeproxy.OuterXml.Length+4, "-->"))
    }
    catch
    {
        Add-WriteLog -logpath "$mypath\Log" -logname $namelog -text "The [proxy] property was not found!"
    }