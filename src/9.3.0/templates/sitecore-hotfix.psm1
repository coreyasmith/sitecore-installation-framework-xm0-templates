function Invoke-InstallNuGetAssembliesTask {
    <#
    .SYNOPSIS
        Downloads NuGet packages and copies their lib/<framework> assemblies into the destination
        folder (typically the site bin folder). Used for hotfix readme steps that require updating
        Microsoft/NuGet assemblies that the hotfix package itself does not ship.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        # Package specs in the form 'Id/Version/LibFolder', e.g. 'Microsoft.Owin/4.2.2/net45'.
        [Parameter(Mandatory=$true)]
        [string[]]$Packages,

        [Parameter(Mandatory=$true)]
        [string]$Destination
    )

    if (-not (Test-Path $Destination)) {
        throw "The destination folder '$Destination' was not found."
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    # Windows PowerShell 5.1 does not enable TLS 1.2 by default on all systems, and nuget.org requires it.
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    foreach ($packageSpec in $Packages) {
        $id, $version, $libFolder = $packageSpec.Split('/')
        if (-not ($id -and $version -and $libFolder)) {
            throw "Invalid package spec '$packageSpec'. Expected 'Id/Version/LibFolder', e.g. 'Microsoft.Owin/4.2.2/net45'."
        }

        if (-not $PSCmdlet.ShouldProcess($Destination, "Install $id $version ($libFolder) assemblies")) {
            continue
        }

        $nupkgPath = Join-Path ([System.IO.Path]::GetTempPath()) "$id.$version.nupkg"
        $url = "https://api.nuget.org/v3-flatcontainer/$($id.ToLowerInvariant())/$version/$($id.ToLowerInvariant()).$version.nupkg"

        try {
            Write-Information "Downloading $id $version..." -InformationAction:Continue
            Invoke-WebRequest -Uri $url -OutFile $nupkgPath -UseBasicParsing

            $zip = [System.IO.Compression.ZipFile]::OpenRead($nupkgPath)
            try {
                $assemblies = @($zip.Entries | Where-Object { $_.FullName -match "^lib/$([regex]::Escape($libFolder))/[^/]+\.dll$" })
                if (-not $assemblies) {
                    throw "No assemblies found under lib/$libFolder in $id $version."
                }
                foreach ($assembly in $assemblies) {
                    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($assembly, (Join-Path $Destination $assembly.Name), $true)
                    Write-Information "Copied $($assembly.Name) $version to $Destination" -InformationAction:Continue
                }
            }
            finally {
                $zip.Dispose()
            }
        }
        finally {
            Remove-Item $nupkgPath -Force -ErrorAction SilentlyContinue
        }
    }
}

Register-SitecoreInstallExtension -Command Invoke-InstallNuGetAssembliesTask -As InstallNuGetAssemblies -Type Task
