[CmdletBinding()]Param (
    [Parameter(
        Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
    [ValidatePattern("^DOIT")]
    [String[]]$ComputerName
)

$ModuleName = "DoIT.GeneralFunctions"
$GitHubUri = "https://github.com/jacobdonais/DoIT.GeneralFunctions/archive/master.zip"
$ResourceLocation = "./"
$ZipName = "master.zip"

if (Test-Path -Path ($ResourceLocation + $ZipName)) {
    Write-Verbose "Removing exisiting zip file"
    try {
        Remove-Item -Path ($ResourceLocation + $ZipName) -Recurse -Force -Confirm:$false
        Write-Verbose ".Successfully removed the existing zip file"
    }
    catch {
        Write-Warning "Failed to remove the exisiting zip file"
        break
    }
}

Write-Verbose "Extracting module from GitHub"
try {
    Invoke-WebRequest -Uri $GitHubUri -UseBasicParsing -OutFile ($ResourceLocation + $ZipName)
    Write-Verbose ".Successfully extracted module from GitHub"
}
catch {
    Write-Warning "Failed to extract module from GitHub"
    break
}

if (Test-Path -Path "$($ResourceLocation)$($ModuleName)-master") {
    Write-Verbose "Removing exisiting extracted zip file"
    try {
        Remove-Item -Path "$($ResourceLocation)$($ModuleName)-master" -Recurse -Force -Confirm:$false
        Write-Verbose ".Successfully removed the existing extracted zip file"
    }
    catch {
        Write-Warning "Failed to remove the exisiting extracted zip file"
        break
    }
}

Write-Verbose "Extracting zip file"
try {
    Expand-Archive -Path ($ResourceLocation + $ZipName) -DestinationPath $ResourceLocation
    Write-Verbose ".Successfully extracted zip file"
}
catch {
    Write-Warning "Failed to extract zip file"
    break
}

Write-Verbose "Removing zip file"
try {
    Remove-Item -Path ($ResourceLocation + $ZipName) -Recurse -Force -Confirm:$false
    Write-Verbose ".Successfully removed zip file"
}
catch {
    Write-Warning "Failed to remove zip file"
    break
}

foreach ($Computer in $ComputerName)  {
    Write-Verbose "Performing action on $Computer"
    $InstallPath = "\\$Computer\C$\Program Files\WindowsPowerShell\Modules"

    if (Test-Path -Path ($InstallPath + "\" + $ModuleName)) {
        Write-Verbose "..Removing exisiting module"
        try {
            Remove-Item -Path ($InstallPath + "\" + $ModuleName) -Recurse -Force -Confirm:$false
            Write-Verbose "...Successfully removed the module"
        }
        catch {
            Write-Warning "Failed to remove the exisiting module on $Computer"
            break
        }
    }

    if (Test-Path -Path $InstallPath) {
        Write-Verbose "..Downloading module to module path"
        try {
            Copy-Item -Path "$($ResourceLocation)$($ModuleName)-master\$($ModuleName)" -Destination $InstallPath -Recurse -Force -Confirm:$false
            Write-Verbose "...Successfully downloaded the module"
        }
        catch {
            Write-Warning "Failed to download module on $Computer"
            break
        }
    }
    else {
        Write-Warning "Install Path does not exist on $Computer"
        break
    }

    Write-Verbose "..Confirming module installed correctly"
    if (Test-Path -Path ("$InstallPath\$ModuleName")) {
        Write-Verbose "...Successfully installed module"
    }
    else {
        Write-Warning "Module did not install on $Computer"
    }
}

Write-Verbose "Removing resource files"
try {
    Remove-Item -Path "$($ResourceLocation)$($ModuleName)-master" -Recurse -Force -Confirm:$false
    Write-Verbose ".Successfully removed resource files"
}
catch {
    Write-Warning "Failed to remove resource files"
    break
}