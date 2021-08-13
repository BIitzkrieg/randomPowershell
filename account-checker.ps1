# Script to Query AD, and tell you if an account exists in AD, the users department, and when their password was last reset. Useful for Credential Dump Notifications.
# takes SAM account names, or email addresses as input
# Andrew Danis - Novemeber 5th, 2020

function Main-Function{
Import-Module ActiveDirectory
#set your list of accounts
$UserList = get-content -Path C:\Users\danisac\Desktop\passwords\passwords.txt

Foreach ($Item in $UserList) {
$user = $null

$user = (get-aduser -LDAPFilter "(&(objectclass=user)(proxyAddresses=smtp:$Item))" | Select samaccountname | ft -HideTableHeaders | Out-String).TrimStart().TrimEnd()
if ($user){
    (Get-ADUser -Filter { cn -eq $user} -Properties SamAccountName, Department, passwordlastset | Select samaccountname,Department,passwordlastset | ft -HideTableHeaders | Out-String).TrimStart().TrimEnd()
    }
    else{
    "$item does not exist"
    }
}
}

try{
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$elevated = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($elevated -eq $true){
        echo "User is elevated, installing RSAT Tools"
        echo ""
        Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
        echo "Installed RSAT Tools. Run script with standard privileged Powershell window to query AD."
        exit
    }
    if ($elevated -eq $false){
    echo "user is not elevated, trying to query AD."
    echo ""
    sleep -Seconds 2
    Main-Function
    }
}
Catch{
$ErrorMessage = $_.Exception.Message
echo $ErrorMessage, "Run as admin to install RSAT Tools. Then, run script with standard privileges. Optionally, run ""Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"" in a seperate elevated PS window."
echo ""
exit
}
