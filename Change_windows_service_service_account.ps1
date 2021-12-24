[string]$username = "User"
[string]$pwd = "passWord"
[string]$service="AdobeARMservice"

function Change-ServiceAccount
{
    param (
        [string]$account,
        [string]$password,
        [string]$service

    )
    
    $temp = "name='$service'"
    $svc=gwmi win32_service -filter $temp
    $svc.StopService()
    Start-Sleep -s 5
    $svc.change($null,$null,$null,$null,$null,$null,$account,$password,$null,$null,$null)
    $svc.StartService()
}


Change-ServiceAccount -account $username -password $pwd -service $service