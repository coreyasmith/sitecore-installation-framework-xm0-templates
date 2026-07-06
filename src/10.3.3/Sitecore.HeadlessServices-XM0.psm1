function Invoke-ExportSifRootCertForNodeTask {
    <#
    .SYNOPSIS
        Ensures the SIF-generated root CA is in the PEM bundle NODE_EXTRA_CA_CERTS
        points at, so Node.js head apps can connect to Sitecore instances that use
        a certificate issued by the SIF root. Appends to the existing bundle if the
        variable is already set; otherwise exports the cert to CertPath and points
        NODE_EXTRA_CA_CERTS at it.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$CertPath,

        [Parameter(Mandatory=$true)]
        [string]$RootDnsName
    )

    # NODE_EXTRA_CA_CERTS is a single file path, but that file may contain multiple
    # concatenated PEM certs. If the variable is already set at any scope, append to
    # that bundle -- setting a User-scope variable here would shadow a Machine-scope
    # one and break whatever certs its bundle supplies. Otherwise fall back to the
    # cert path passed into this task.
    $existingCertPath = $null
    foreach ($scope in 'User', 'Machine', 'Process') {
        $existingCertPath = [Environment]::GetEnvironmentVariable('NODE_EXTRA_CA_CERTS', $scope)
        if ($existingCertPath) { break }
    }
    $targetPath = if ($existingCertPath) { $existingCertPath } else { $CertPath }

    if (-not $PSCmdlet.ShouldProcess($targetPath, "Add SIF root cert to NODE_EXTRA_CA_CERTS bundle")) {
        return
    }

    try {
        Write-Information "Configuring NODE_EXTRA_CA_CERTS for Node.js head apps..." -InformationAction:Continue

        $cert = Invoke-GetCertificateConfigFunction -Id $RootDnsName -CertStorePath "Cert:\LocalMachine\Root"

        if (-not $cert) {
            Write-Warning "SIF root cert '$RootDnsName' not found in Cert:\LocalMachine\Root. Skipping NODE_EXTRA_CA_CERTS setup."
            return
        }

        # Read the whole bundle up front: the duplicate check needs it, and the
        # append needs to know whether the last line is newline-terminated. If the
        # file exists but can't be read, fail rather than blindly append.
        $bundleContent = $null
        if (Test-Path -LiteralPath $targetPath) {
            $bundleContent = Get-Content -LiteralPath $targetPath -Raw -ErrorAction Stop
        }

        # Don't append our cert if it's already present in the bundle.
        $bundleContainsCert = $false
        if ($bundleContent) {
            $pemMatches = [regex]::Matches($bundleContent, '-----BEGIN CERTIFICATE-----(.*?)-----END CERTIFICATE-----', 'Singleline')
            foreach ($pemMatch in $pemMatches) {
                $b64 = ($pemMatch.Groups[1].Value -replace '\s', '')
                try {
                    $bundledCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 (,[Convert]::FromBase64String($b64))
                    if ($bundledCert.Thumbprint -eq $cert.Thumbprint) {
                        $bundleContainsCert = $true
                        break
                    }
                } catch {
                    # Skip malformed entries -- we just don't want false positives.
                }
            }
        }

        if ($bundleContainsCert) {
            Write-Information "'$targetPath' already contains the SIF root cert ($($cert.Thumbprint)). Nothing to do." -InformationAction:Continue
        } else {
            # Build the PEM block, preceded by a comment identifying the cert so
            # anyone reading the bundle later knows what the entry is for. Node
            # (OpenSSL) ignores text outside the BEGIN/END markers.
            $comment = "# SIF root cert '$RootDnsName' (thumbprint $($cert.Thumbprint))"
            $pemBlock = "$comment`n" +
                "-----BEGIN CERTIFICATE-----`n" +
                [Convert]::ToBase64String($cert.RawData, 'InsertLineBreaks') +
                "`n-----END CERTIFICATE-----"
            if ($bundleContent -and -not $bundleContent.EndsWith("`n")) {
                # Never glue the comment onto an unterminated last line -- that
                # would corrupt the previous entry's END marker.
                $pemBlock = "`n$pemBlock"
            }

            $targetDir = Split-Path -Parent $targetPath
            if ($targetDir -and -not (Test-Path -LiteralPath $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }

            Add-Content -LiteralPath $targetPath -Value $pemBlock -Encoding ascii

            if ($existingCertPath) {
                Write-Information "Added SIF root certificate (thumbprint $($cert.Thumbprint)) to the NODE_EXTRA_CA_CERTS bundle at $targetPath" -InformationAction:Continue
            } else {
                Write-Information "Exported SIF root certificate (thumbprint $($cert.Thumbprint)) to $targetPath" -InformationAction:Continue
            }
        }

        if (-not $existingCertPath) {
            [Environment]::SetEnvironmentVariable('NODE_EXTRA_CA_CERTS', $CertPath, 'User')
            Write-Information "Set user environment variable NODE_EXTRA_CA_CERTS to $CertPath" -InformationAction:Continue
            Write-Information "NOTE: Restart your terminal/IDE for Node.js to pick up the new environment variable." -InformationAction:Continue
        }
    } catch {
        Write-Error $_
    }
}

Register-SitecoreInstallExtension -Command Invoke-ExportSifRootCertForNodeTask -As ExportSifRootCertForNode -Type Task
