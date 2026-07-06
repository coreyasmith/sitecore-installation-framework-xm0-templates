<#
.SYNOPSIS
    Verifies that the packages required for an install are present and unmodified.

.DESCRIPTION
    Reads the required files from the README, then checks them against the SHA-256 hashes
    recorded in Packages.lock.json. Run it before installing, or when an install fails, to rule
    out a missing, renamed, corrupt, or incorrect package.

.PARAMETER InstallRoot
    The version folder that contains the README and the packages folder.

.PARAMETER ManifestPath
    The hash manifest to check the packages against.

.PARAMETER UpdateManifest
    Rewrites the manifest from the files currently in the packages folder. Run it after you change
    the packages listed in the README.

.EXAMPLE
    .\Validate-Packages.ps1
#>
param (
    [Parameter(Mandatory = $false)]
    [string]$InstallRoot,

    [Parameter(Mandatory = $false)]
    [string]$ManifestPath,

    [Parameter(Mandatory = $false)]
    [switch]$UpdateManifest
)

$ErrorActionPreference = "Stop"

# Windows PowerShell leaves $PSScriptRoot empty in parameter defaults, so the paths that depend
# on it are resolved here instead.
if (!$InstallRoot) { $InstallRoot = $PSScriptRoot }
if (!$ManifestPath) { $ManifestPath = Join-Path -Path $PSScriptRoot -ChildPath "Packages.lock.json" }

$readmePath = Join-Path -Path $InstallRoot -ChildPath "README.md"
$packagesPath = Join-Path -Path $InstallRoot -ChildPath "packages"

# The required files are the backticked entries under the "Required Files and Packages" heading.
function Get-RequiredPackage {
    param ([string]$Path)

    $required = @()
    $inSection = $false

    foreach ($line in (Get-Content -LiteralPath $Path)) {
        if ($line -match "^## .*Required Files and Packages") { $inSection = $true; continue }
        if ($inSection -and $line -match "^## ") { break }
        if ($inSection -and $line -match "^\s+- ``([^``]+)``") { $required += $Matches[1] }
    }

    return $required
}

# The license file is unique to the person installing, so it is checked for presence only.
function Test-UserSpecificPackage {
    param ([string]$Name)

    return $Name -eq "license.xml"
}

# Sitecore republishes cumulative hotfixes and delta packages under the same file name, so a
# hash mismatch on one of those is a warning rather than a failure.
function Test-RepublishedPackage {
    param ([string]$Name)

    return ($Name -like "SC Hotfix*") -or ($Name -like "*.delta.scwdp.zip")
}

# Scores how much two file names have in common, used to suggest what a missing package may
# have been confused with.
function Get-NameSimilarity {
    param ([string]$Name, [string]$Other)

    $separators = [regex]"[^A-Za-z0-9]+"
    $nameTokens = @($separators.Split($Name.ToLowerInvariant()) | Where-Object { $_ })
    $otherTokens = @($separators.Split($Other.ToLowerInvariant()) | Where-Object { $_ })

    if ($nameTokens.Count -eq 0 -or $otherTokens.Count -eq 0) { return 0 }

    $shared = @($nameTokens | Where-Object { $otherTokens -contains $_ }).Count

    return $shared / [Math]::Max($nameTokens.Count, $otherTokens.Count)
}

function Format-JsonString {
    param ([string]$Value)

    return '"' + ($Value -replace "\\", "\\" -replace '"', '\"') + '"'
}

function Write-Manifest {
    param ([string]$Path, [string]$Version, [object[]]$Packages)

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("{")
    $lines.Add("    ""Version"": $(Format-JsonString $Version),")
    $lines.Add("    ""Packages"": [")

    for ($index = 0; $index -lt $Packages.Count; $index++) {
        $package = $Packages[$index]
        $length = if ($null -eq $package.Length) { "null" } else { $package.Length }
        $hash = if ($null -eq $package.Sha256) { "null" } else { Format-JsonString $package.Sha256 }
        $comma = if ($index -lt $Packages.Count - 1) { "," } else { "" }

        $lines.Add("        {")
        $lines.Add("            ""Name"": $(Format-JsonString $package.Name),")
        $lines.Add("            ""Length"": $length,")
        $lines.Add("            ""Sha256"": $hash")
        $lines.Add("        }$comma")
    }

    $lines.Add("    ]")
    $lines.Add("}")

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($lines -join "`r`n") + "`r`n", $encoding)
}

function Write-Result {
    param ([string]$Status, [string]$Message, [string]$Color)

    Write-Host ("  {0,-9}{1}" -f $Status, $Message) -ForegroundColor $Color
}

function Write-Detail {
    param ([string]$Message)

    Write-Host ("           {0}" -f $Message) -ForegroundColor DarkGray
}

if (!(Test-Path -LiteralPath $readmePath)) { throw "The README was not found at '$readmePath'." }
if (!(Test-Path -LiteralPath $packagesPath)) { throw "The packages folder was not found at '$packagesPath'." }

$version = Split-Path -Path $InstallRoot -Leaf
$required = Get-RequiredPackage -Path $readmePath
$present = @(Get-ChildItem -LiteralPath $packagesPath -File | Where-Object { $_.Name -ne ".gitkeep" })

if ($required.Count -eq 0) { throw "No required packages were found in '$readmePath'." }

if ($UpdateManifest) {
    $entries = @()

    foreach ($name in $required) {
        $file = $present | Where-Object { $_.Name -eq $name }
        if ($null -eq $file) { throw "'$name' is required by the README but is not in the packages folder." }

        if (Test-UserSpecificPackage -Name $name) {
            $entries += [PSCustomObject]@{ Name = $name; Length = $null; Sha256 = $null }
        }
        else {
            Write-Host "Hashing $name"
            $entries += [PSCustomObject]@{
                Name = $name
                Length = $file.Length
                Sha256 = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
            }
        }
    }

    Write-Manifest -Path $ManifestPath -Version $version -Packages $entries
    Write-Host "Wrote $($entries.Count) packages to $ManifestPath" -ForegroundColor Green

    return
}

if (!(Test-Path -LiteralPath $ManifestPath)) { throw "The package manifest was not found at '$ManifestPath'." }

$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$failures = 0
$warnings = 0

Write-Host ""
Write-Host "Sitecore $version packages in $packagesPath"
Write-Host ""
Write-Host "Required by the README"

foreach ($name in $required) {
    $expected = $manifest.Packages | Where-Object { $_.Name -eq $name }
    $file = $present | Where-Object { $_.Name -eq $name }

    if ($null -eq $file) {
        Write-Result -Status "MISSING" -Message $name -Color Red
        $failures++

        $candidate = $present |
            Where-Object { $required -notcontains $_.Name } |
            Sort-Object -Property @{ Expression = { Get-NameSimilarity -Name $name -Other $_.Name } } -Descending |
            Select-Object -First 1

        if ($null -ne $candidate -and (Get-NameSimilarity -Name $name -Other $candidate.Name) -ge 0.5) {
            Write-Detail "you have a similarly named file: $($candidate.Name)"
        }

        continue
    }

    if (Test-UserSpecificPackage -Name $name) {
        Write-Result -Status "SKIPPED" -Message "$name (unique to you, checked for presence only)" -Color DarkGray
        continue
    }

    if ($null -eq $expected -or $null -eq $expected.Sha256) {
        Write-Result -Status "UNKNOWN" -Message "$name (no hash on record, run with -UpdateManifest)" -Color Yellow
        $warnings++
        continue
    }

    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash

    if ($hash -eq $expected.Sha256) {
        Write-Result -Status "OK" -Message $name -Color Green
        continue
    }

    if (Test-RepublishedPackage -Name $name) {
        Write-Result -Status "CHANGED" -Message "$name (Sitecore republishes this package, so a newer build may still install)" -Color Yellow
        $warnings++
    }
    else {
        Write-Result -Status "WRONG" -Message "$name (the file does not match the package these templates install)" -Color Red
        $failures++
    }

    Write-Detail "expected $($expected.Sha256) ($($expected.Length) bytes)"
    Write-Detail "found    $hash ($($file.Length) bytes)"
}

# The versions whose README asks for the Sitecore Azure Toolkit need it to convert packages,
# either before the install or during it.
if ((Get-Content -LiteralPath $readmePath -Raw) -match "lib/sat") {
    $toolkitPath = Join-Path -Path $InstallRoot -ChildPath "lib\sat\tools\Sitecore.Cloud.Cmdlets.psm1"

    Write-Host ""
    Write-Host "Tools required by the README"

    if (Test-Path -LiteralPath $toolkitPath) {
        Write-Result -Status "OK" -Message "Sitecore Azure Toolkit in lib\sat" -Color Green
    }
    else {
        Write-Result -Status "MISSING" -Message "Sitecore Azure Toolkit in lib\sat (unzip it there, see the README)" -Color Red
        $failures++
    }
}

$stale = @($manifest.Packages | Where-Object { $required -notcontains $_.Name })

if ($stale.Count -gt 0) {
    Write-Host ""
    Write-Host "Recorded in the manifest but no longer required by the README"

    foreach ($entry in $stale) {
        Write-Result -Status "STALE" -Message "$($entry.Name) (regenerate the manifest with -UpdateManifest)" -Color Yellow
        $warnings++
    }
}

$extra = @($present | Where-Object { $required -notcontains $_.Name })

if ($extra.Count -gt 0) {
    Write-Host ""
    Write-Host "Other files in the packages folder"

    foreach ($file in $extra) {
        Write-Result -Status "EXTRA" -Message $file.Name -Color DarkGray
    }
}

# The install scripts look their packages up by wildcard, so a pattern that matches nothing or
# more than one file breaks the install even when every required file is in place.
Write-Host ""
Write-Host "Package lookups in the install scripts"

foreach ($script in (Get-ChildItem -LiteralPath $InstallRoot -Filter "*.ps1" -File | Where-Object { $_.FullName -ne $PSCommandPath })) {
    $patterns = [ordered]@{}

    foreach ($line in (Get-Content -LiteralPath $script.FullName)) {
        if ($line -notmatch 'Get-ChildItem\s+"\$SCInstallRoot\\packages\\(?<pattern>[^"]+)"(?<rest>.*)$') { continue }

        $pattern = $Matches.pattern
        $exclude = @()

        if ($Matches.rest -match '-Exclude\s+(?<exclude>[^\)]+)') {
            $exclude = @($Matches.exclude -split "," | ForEach-Object { $_.Trim().Trim('"') })
        }

        $patterns[$pattern] = $exclude
    }

    foreach ($pattern in $patterns.Keys) {
        $lookup = @{ Path = (Join-Path -Path $packagesPath -ChildPath $pattern); ErrorAction = "SilentlyContinue" }
        if ($patterns[$pattern].Count -gt 0) { $lookup.Exclude = $patterns[$pattern] }

        $matched = @(Get-ChildItem @lookup)

        if ($matched.Count -eq 1) {
            Write-Result -Status "OK" -Message $pattern -Color Green
        }
        elseif ($matched.Count -eq 0) {
            Write-Result -Status "NONE" -Message "$pattern (nothing matches, see the preparation steps in the README)" -Color Yellow
            $warnings++
        }
        else {
            Write-Result -Status "MANY" -Message "$pattern (matches $($matched.Count) files, leave only the one you are installing)" -Color Red
            $failures++

            foreach ($file in $matched) { Write-Detail $file.Name }
        }
    }
}

Write-Host ""

if ($failures -gt 0) {
    Write-Host "$failures problem(s) and $warnings warning(s). Fix the problems above before installing." -ForegroundColor Red
    exit 1
}

if ($warnings -gt 0) {
    Write-Host "No problems and $warnings warning(s). Review the warnings above before installing." -ForegroundColor Yellow
    exit 0
}

Write-Host "Everything the README requires is in place." -ForegroundColor Green
exit 0
