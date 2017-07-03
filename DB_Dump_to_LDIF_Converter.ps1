# DB_Dump_to_LDIF_Converter.ps1
# This tool is used to take JSON dump files from MySQL and creates an LDIF file for OpenLDAP import
# Currently duplicate accounts and non-ldap related accounts that have LDIFs will need to be deleted manually prior to use

# LDIF File Export REPO
$ldifFolder = "F:\openLDAP\user_ldifs"
$ldifFile = "users.ldif"

# LDIF Format
function ldifTemplate([string]$userName, [string]$firstName, [string]$lastName)
    {
# Don't change spacing for the string blocks. It's one of the few times that spacing matters in PowerShell!
@"
dn: uid=$userName,ou=People,dc=trainingandbeyond,dc=local
objectClass: top
objectClass: inetOrgPerson
cn: $userName
sn: $lastName
userPassword: {crypt}thisIsTemporaryButHopefullyStillTooHardToCrackJustInCase

"@
# Don't change spacing for the string blocks. It's one of the few times that spacing matters in PowerShell!
    }

# Create custom object of unique accounts from user file dumps
$users1 = (Get-Content .\user_list.json | Out-String | ConvertFrom-Json)
$users2 = ((Get-Content .\other_user_list.json | Out-String) -Replace "eid", "username" | ConvertFrom-Json) # Manipulate as needed
$userList = $users1 + $users2

# Manipulate values below as needed depending on source information
foreach ($user in $userList)
    {
        $username = $user.username
        $first_name = $user.first_name
        $last_name = $user.last_name
        ldifTemplate -userName $username -firstName $first_name -lastName $last_name | Out-File $ldifFolder\$ldifFile -Encoding UTF8 -Append
    }
