<#
.SYNOPSIS
    Backup folders
.DESCRIPTION
    Script backups folders and removes old backups
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    -
.OUTPUTS
    -
.NOTES
    author: Martin Pucovski (martinautomates.com)
#>

# ==============================
#
# SETTINGS and CONSTANTS
#

# how many days should the old backups be kept
[int32] $daysToKeep = 7

# names of folders that should be backed up
[array] $folderNames = @(
                        "test"
                        "test2"
                        )

# source path
[string] $sourceFolder = "C:\sourcePath"

# destination path
[string] $destinationFolder = "C:\destinationPath"

# ==============================

$scriptName = $MyInvocation.MyCommand.Name
$host.ui.RawUI.WindowTitle = $scriptName

# check destination path
if (!(Test-Path -Path $destinationFolder)) {
    New-Item -Path $destinationFolder -ItemType Directory
}

# create a robot backup directory
$currentDate = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFolderName = Join-Path -Path $destinationFolder -ChildPath $currentDate
New-Item -Path $backupFolderName -ItemType Directory

# backup each folder
foreach ($oneFolder in $folderNames) {
    Write-Host "Start copy $oneFolder"
    $sourcePath = Join-Path -Path $sourceFolder -ChildPath $oneFolder
    $destinationPath = Join-Path -Path $backupFolderName -ChildPath $oneFolder

    robocopy $sourcePath $destinationPath /e

}

# remove old backups
$daysToKeep = $daysToKeep * (-1)
$allFolders = Get-ChildItem -Path $destinationFolder -Directory | Where-Object {$_.CreationTime -lt (Get-Date).AddDays($daysToKeep)}
foreach ($backupFolder in $allFolders) {
    $folderFullName = $backupFolder.FullName
    Write-Host "Removing $folderFullName"
    Remove-Item $backupFolder.FullName -Recurse
}

Read-Host "Script finished. Press ENTER to exit..."