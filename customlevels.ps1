# Notes
# This script will scan the Downloads and look in zip files for ogg and egg files to indicate beatsaber zip files.
# Will capture the installation directory from host system then compare the zip files found in Downloads folder to the Custom levels found

# Variables
$app = '*beat saber*'
$fileext = "*.zip"
$filesong = ("*.ogg*","*.egg*")

# Find installation Source
function installation {
    $installlocal = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall| % { Get-ItemProperty $_.PsPath }  | Select InstallLocation | Where-Object {$_.InstallLocation -like $app}
    $installlocal = ($installlocal -replace ‘[@{}]’).Substring(16)
    return $installlocal
}

# Check for BeatSaber files in downloads
function downloads {
    $zip = Get-ChildItem $HOME\Downloads\$fileext
    $ziplist = @("")
    foreach($file in $zip){
        $contains = [IO.Compression.ZipFile]::OpenRead($file.FullName).Entries.FullName #| %{ "$file`:$_" }
        foreach($s in $contains){
            foreach($e in $filesong){
                if($s -like $e){
                    $ziplist += $file
                }
            }
        }
    }
    Write-Host "Beat Saber files found:"
    foreach($w in $ziplist){
        Write-Host $w.BaseName
    }
    return $ziplist
}

# Unzip folders
function expandzip {
    Param(
        [Parameter(position=0)] $source,
        [Parameter(position=1)] $destination
        )
    Expand-Archive -Path $source -DestinationPath ($destination + $source.BaseName)
}

# Compare if exists
# Custom Level Folders
function customlevels {
    Param(
        [Parameter(position=0)] $cuslevel,
        [Parameter(position=1)] $list
    )
    $cuslevel = "$cuslevel\Beat Saber_Data\CustomLevels"
    $levels = Get-ChildItem $cuslevel -Directory

    $list | ForEach-Object {
        if($levels.name -contains $_.name){
            # Compare function
            pass
        } else {
            expandzip -source $_ -destination $cuslevel
        }
    }
}

# Task Sequence
#Get the current list for beatsaber zips

customlevels -cuslevel installation -list downloads

