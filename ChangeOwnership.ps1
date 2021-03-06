#*****************************************************************
#
#   Script Name:  ChangeOwnership.ps1
#   Version:  1.0
#   Author:  John G@llo
#   Date:  December 16,  2014
#
#   Description:  Used to change ownership on folder to a specific user
#   It also has a function to recursively change ownership in a folder
#   that contains user folders (e.g. profiles/ home drives)
#
#	Mandatory parameters:
#	 FolderPath 
#	 Folder
#
#	Optional parameters (in case you want to grant access to a user besides Domain Admins)
# 	 UserName
#	 Permissions
#
# 	Usage:
#	1) Source powershell script (since it is only functions)
#   . .\ChangeOwnership.ps1
#
#   2) Change folder ownership
#   .\ChangeFolderOwner -Folder "\\cpgnyfiler2\shares\user\jgallo" -Owner cpg_jgallo
#
#   3) On a folder that contains user profiles or home drives, change the ownership based on user/folder name
#
#	2) Create a directory and grant access to only domain admins
#	.\RepairEntireProfilesFolder.ps1 -ProfilePath "\\cpgnyfiler2\shares\user"
#	
#*****************************************************************


function ChangeFolderOwner() {
<#
.SYNOPSIS
Change folder Ownership
.DESCRIPTION
Uses SubInACL (required) utility to recursively change folder ownership 
.PARAMETER Folder
The path to the folder to be changed (e.g. \\FILER\Users\.
.PARAMETER Owner
The user who will own the folder
.EXAMPLE
.\ChangeFolderOwner -Folder "\\cpgnyfiler2\shares\user\jgallo" -Owner cpg_jgallo
#>
    Param(
        [Parameter(Mandatory=$True)]$Folder,
        [Parameter(Mandatory=$True)]$Owner,
        [string]$SubInACL = "C:\Program Files\Windows Resource Kits\Tools\subinacl.exe"
    )

    Write-Host "Changing Ownership on $Folder to $Owner ..."
    #Write-Host "& `'$SubInACL`' /file "$Folder" /setowner=cpgny\$Owner"
    & $SubInACL /file "$Folder" /setowner=cpgny\$Owner
    & $SubInACL /subdirectories "$Folder\*.*" /setowner=cpgny\$Owner
}

function RepairEntireProfilesFolder {
<#
.SYNOPSIS
Repairs user profile ownership recursively
.DESCRIPTION
Uses SubInACL (required) utility to recursively repair user profile folder ownership 
.PARAMETER ProfilePath (Mandatory)
The path where the profiles sit (e.g. \\FILER\Users\.
.EXAMPLE
.\RepairEntireProfilesFolder.ps1 -ProfilePath "\\cpgnyfiler2\shares\user"
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)][string]$ProfilePath
    )
    Get-ChildItem $ProfilePath | % {
        # Use/uncomment 'if' statement if you want to test just one user/folder
        #if ($_.Name -eq 'jgallo'){
            $FullPath = "$ProfilePath\$_"
            ChangeFolderOwner -Folder "$ProfilePath\$_" -Owner $_
        #}
    }
}
