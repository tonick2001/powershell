[CmdletBinding()]
param (
[Parameter (Mandatory=$true, Position=1)]
[ValidateLength(1,5)]
[string] $portin
)

$global:ErrorActionPreference="SilentlyContinue"


@(Get-NetTCPConnection -LocalPort $portin -State Established).Count
        


        