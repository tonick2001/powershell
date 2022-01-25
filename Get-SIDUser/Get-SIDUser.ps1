function get-sid
{
    Param ( $DSIdentity )
    $ID = new-object System.Security.Principal.NTAccount($DSIdentity)
    return $ID.Translate( [System.Security.Principal.SecurityIdentifier] ).toString()
}
 $admin = get-sid "test01"
 #$admin.SubString(0, $admin.Length - 4)
 $admin.SubString(0, $admin.Length)