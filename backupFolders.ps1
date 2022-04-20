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

# initials
$scriptName = $MyInvocation.MyCommand.Name
$host.ui.RawUI.WindowTitle = $scriptName

# read config file
$configFile = Import-PowerShellDataFile -Path .\Config\config.psd1

# check destination path
if (!(Test-Path -Path $configFile['DestinationPath'])) {
    New-Item -Path $configFile['DestinationPath'] -ItemType Directory
}

# create a robot backup directory
$currentDate = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFolderName = Join-Path -Path $configFile['DestinationPath'] -ChildPath $currentDate
New-Item -Path $backupFolderName -ItemType Directory

# backup each folder
foreach ($oneFolder in $configFile['FolderNames']) {
    Write-Host "Start copy $oneFolder"
    $sourcePath = Join-Path -Path $configFile['SourcePath'] -ChildPath $oneFolder
    $destinationPath = Join-Path -Path $backupFolderName -ChildPath $oneFolder

    robocopy $sourcePath $destinationPath /e

}

# remove old backups
$daysToKeep = $configFile['DaysToKeep'] * (-1)
$allFolders = Get-ChildItem -Path $configFile['DestinationPath'] -Directory | Where-Object { $_.CreationTime -lt (Get-Date).AddDays($daysToKeep) }
foreach ($backupFolder in $allFolders) {
    $folderFullName = $backupFolder.FullName
    Write-Host "Removing $folderFullName"
    Remove-Item $backupFolder.FullName -Recurse
}

Read-Host "Script finished. Press ENTER to exit..."
