<#
.SYNOPSIS
Renames files in subfolders to match the parent folder's name, with special handling for .srt files.

.DESCRIPTION
This PowerShell script traverses all subfolders within a specified main folder, renaming files so their names match the parent folder's name. Files with .mp4, .mkv, .avi extensions are renamed directly. For .srt files, ".eng" is appended before the extension. The script uses LiteralPath for accurate path handling.

.PARAMETER MainFolderPath
The path of the main folder containing subfolders with files to be renamed.

.EXAMPLE
PS> .\RenameFilesToMatchFolder.ps1 -MainFolderPath "C:\Temp\Scripts"

This command renames files in all subfolders under "C:\Temp\Scripts", matching each file's name to its parent folder's name.

.NOTES
Author: TechBase IT
Date Created: 2024-04-25
Date Modified: 2024-04-25
Compatibility: PowerShell 5.1 and up
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$MainFolderPath
)

function Rename-FilesInFolder {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FolderPath
    )
    
    $subFolders = Get-ChildItem -Path $FolderPath -Directory
    
    foreach ($folder in $subFolders) {
        $folderName = $folder.Name
        $files = Get-ChildItem -Path $folder.FullName -File
        
        foreach ($file in $files) {
            $extension = $file.Extension
            $newBaseName = if ($extension -eq ".srt") { "$folderName.eng" } else { $folderName }
            $newFileName = $newBaseName + $extension

            # Using LiteralPath for accurate path handling
            if (-not (Test-Path -LiteralPath (Join-Path -Path $folder.FullName -ChildPath $newFileName))) {
                try {
                    Write-Host "Renaming `"$($file.FullName)`" to `"$newFileName`""
                    Rename-Item -LiteralPath $file.FullName -NewName $newFileName -ErrorAction Stop
                } catch {
                    Write-Warning "Failed to rename `"$($file.FullName)`": $_"
                }
            } else {
                Write-Host "`"$newFileName`" already exists. Skipping..."
            }
        }
    }
}

Rename-FilesInFolder -FolderPath $MainFolderPath