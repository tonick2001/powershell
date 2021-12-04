#Скрипт добавляет пользователям ПК на которых им разрешено работать! 
$access_logon_allowed_pc = "KAB-2,KAB-3,KAB-4,KAB-5,KAB-6,KABINET-1,RENTGEN,SRV-1C,RECEPTION-02"

foreach ($username in (Get-ADGroupMember "Group_Doctors").name)
{   
   #Write-Host $s
   Set-ADUser $username -LogonWorkstations $access_logon_allowed_pc
   get-aduser $username -Properties LogonWorkstations | ft Name, LogonWorkstations
}
