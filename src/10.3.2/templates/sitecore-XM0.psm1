# Windows gates performance counter data reads (HKEY_PERFORMANCE_DATA) through the
# DACL on this key and its language subkeys.
$PerflibKeyPath = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib'

function Invoke-GrantPerfDataAccessTask {
    <#
    .SYNOPSIS
        Grants an account read access to performance counter data by adding its
        SID directly to the Perflib key DACL. A direct ACE takes effect
        immediately, unlike Performance Monitor Users membership, which only
        enters an app pool's token after a WAS restart because WAS caches the
        token built for the first worker process.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Identity
    )

    if (-not $PSCmdlet.ShouldProcess("Grant '$Identity' read access to performance counter data")) {
        return
    }

    try {
        $sid = (New-Object System.Security.Principal.NTAccount($Identity)).Translate([System.Security.Principal.SecurityIdentifier])
        $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
            $PerflibKeyPath,
            [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,
            [System.Security.AccessControl.RegistryRights]'ReadPermissions,ChangePermissions')

        try {
            $acl = $key.GetAccessControl('Access')
            $readKey = [System.Security.AccessControl.RegistryRights]::ReadKey
            $existingRule = $acl.GetAccessRules($true, $false, [System.Security.Principal.SecurityIdentifier]) |
                Where-Object { $_.IdentityReference -eq $sid -and $_.AccessControlType -eq 'Allow' -and ($_.RegistryRights -band $readKey) -eq $readKey }

            if ($existingRule) {
                Write-Information "'$Identity' already has read access to performance counter data." -InformationAction:Continue
                return
            }

            $rule = New-Object System.Security.AccessControl.RegistryAccessRule (
                $sid,
                $readKey,
                [System.Security.AccessControl.InheritanceFlags]::ContainerInherit,
                [System.Security.AccessControl.PropagationFlags]::None,
                [System.Security.AccessControl.AccessControlType]::Allow)
            $acl.AddAccessRule($rule)
            $key.SetAccessControl($acl)
            Write-Information "Granted '$Identity' read access to performance counter data." -InformationAction:Continue
        } finally {
            $key.Close()
        }
    } catch {
        Write-Error $_
    }
}

function Invoke-RevokePerfDataAccessTask {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Identity
    )

    if (-not $PSCmdlet.ShouldProcess("Revoke '$Identity' read access to performance counter data")) {
        return
    }

    try {
        $sid = (New-Object System.Security.Principal.NTAccount($Identity)).Translate([System.Security.Principal.SecurityIdentifier])
        $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
            $PerflibKeyPath,
            [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,
            [System.Security.AccessControl.RegistryRights]'ReadPermissions,ChangePermissions')

        try {
            $acl = $key.GetAccessControl('Access')
            $existingRule = $acl.GetAccessRules($true, $false, [System.Security.Principal.SecurityIdentifier]) |
                Where-Object { $_.IdentityReference -eq $sid }

            if (!$existingRule) {
                Write-Information "'$Identity' has no access entries for performance counter data." -InformationAction:Continue
                return
            }

            $acl.PurgeAccessRules($sid)
            $key.SetAccessControl($acl)
            Write-Information "Revoked '$Identity' read access to performance counter data." -InformationAction:Continue
        } finally {
            $key.Close()
        }
    } catch [System.Security.Principal.IdentityNotMappedException] {
        Write-Information "'$Identity' does not exist; there is no performance counter access to revoke." -InformationAction:Continue
    } catch {
        Write-Error $_
    }
}

Register-SitecoreInstallExtension -Command Invoke-GrantPerfDataAccessTask -As GrantPerfDataAccess -Type Task
Register-SitecoreInstallExtension -Command Invoke-RevokePerfDataAccessTask -As RevokePerfDataAccess -Type Task
