#*****************************************************************
#
#   Script Name:  createFolderAndPermissions.ps1
#   Version:  1.0
#   Author:  John G@llo
#   Date:  September 23,  2014
#
#   Description:  Used to create folder on a given location and grant 
#	Domain Admins Full Control and grant specific access (e.g. Modify) 
#	to a user(optional)
#
#	Mandatory parameters:
#	FolderPath 
#	Folder
#
#	Optional parameters (in case you want to grant access to a user besides Domain Admins)
# 	UserName
#	Permissions
#
# 	Use Cases:
#	1) Create Home Directories and grant the user access, as well as Domain Admins
#	C:\> createFolderAndPermissions.ps1 -FolderPath X:\ -Folder "john" -UserName "john" -Permission Modify
#
#	2) Create a directory and grant access to only domain admins
#	C:\> createFolderAndPermissions.ps1 -FolderPath 'G:\teamfolders' -Folder "myteam"
#	
#*****************************************************************

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$FolderPath,
	
   [Parameter(Mandatory=$True)]
   [string]$Folder,
   
   [Parameter(Mandatory=$False)]
   [string]$UserName,
   
   [Parameter(Mandatory=$False)]
   [string]$Permission
)
# Variables
$MyDomain = 'CPGNY'

# Create a new folder under given path
New-Item -Name $Folder -ItemType Directory -Path $FolderPath | Out-Null

# Gather existing ACL
$ACL = Get-Acl "$FolderPath\$Folder"

# Remove inheritance
$ACL.SetAccessRuleProtection($true, $false)
		
# Remove existing ACL's
$ACL.Access | ForEach { [Void]$ACL.RemoveAccessRule($_) }

# Prepare new ACL's
$ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$MyDomain\Domain Admins","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
if($UserName -and $Permission){
	$ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$MyDomain\$UserName","$Permission", "ContainerInherit, ObjectInherit", "None", "Allow")))
}
# Set new ACL's
Set-Acl "$FolderPath\$Folder" $ACL

