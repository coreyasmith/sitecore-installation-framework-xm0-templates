function Invoke-ConvertSitecoreModuleTask {
    <#
    .SYNOPSIS
        Converts a Sitecore module package to a Web Deploy package with the
        Sitecore Azure Toolkit and writes it to Destination as
        module.scwdp.zip. Accepts the hotfix zip as published by Sitecore:
        either the module package itself, or a wrapper zip that nests the
        module package beside its readme (the shape varies between hotfix
        releases).
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$SatToolsPath,

        [Parameter(Mandatory=$true)]
        [string]$Destination
    )

    if (-not $PSCmdlet.ShouldProcess("Convert '$Path' to a Web Deploy package")) {
        return
    }

    try {
        Get-ChildItem -LiteralPath $SatToolsPath -Recurse -File | Unblock-File

        Import-Module (Join-Path $SatToolsPath 'Sitecore.Cloud.Cmdlets.psm1') -ErrorAction Stop
        Import-Module (Join-Path $SatToolsPath 'Sitecore.Cloud.Cmdlets.dll') -ErrorAction Stop

        # A module package carries package.zip at its root; the wrapper shape
        # nests the module package as its only inner zip.
        $extractPath = Join-Path $Destination 'extract'
        Expand-Archive -LiteralPath $Path -DestinationPath $extractPath -Force
        if (Test-Path -LiteralPath (Join-Path $extractPath 'package.zip')) {
            $modulePath = $Path
        } else {
            $innerZips = @(Get-ChildItem -LiteralPath $extractPath -File -Filter '*.zip')
            if ($innerZips.Count -ne 1) {
                throw "Cannot locate the module package in '$Path': expected package.zip or a single nested zip, found $($innerZips.Count) nested zips."
            }
            $modulePath = $innerZips[0].FullName
        }

        Write-Information "Converting '$modulePath' to a Web Deploy package..." -InformationAction:Continue
        $scwdpPath = ConvertTo-SCModuleWebDeployPackage -Path $modulePath -Destination $Destination -Force -DisableDacPacOptions '*'

        # Move the scwdp to a fixed name so the deploy task can reference it.
        Move-Item -LiteralPath $scwdpPath -Destination (Join-Path $Destination 'module.scwdp.zip') -Force
        Remove-Item -LiteralPath $extractPath -Recurse -Force
    } catch {
        Write-Error $_
    }
}

function Invoke-DisableConfigFilesTask {
    <#
    .SYNOPSIS
        Disables config files by giving them a .example extension.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$RootDirectoryPath,

        [Parameter(Mandatory=$false)]
        [AllowEmptyCollection()]
        [string[]]$Path = @()
    )

    foreach ($relativePath in $Path) {
        $source = Join-Path $RootDirectoryPath $relativePath

        if (-not (Test-Path -LiteralPath $source)) {
            continue
        }

        if (-not $PSCmdlet.ShouldProcess($source, 'Disable config file')) {
            continue
        }

        Write-Information "Disabling '$relativePath'..." -InformationAction:Continue
        Copy-Item -LiteralPath $source -Destination ($source + '.example') -Force
        Remove-Item -LiteralPath $source -Force
    }
}

Register-SitecoreInstallExtension -Command Invoke-ConvertSitecoreModuleTask -As ConvertSitecoreModule -Type Task
Register-SitecoreInstallExtension -Command Invoke-DisableConfigFilesTask -As DisableConfigFiles -Type Task
