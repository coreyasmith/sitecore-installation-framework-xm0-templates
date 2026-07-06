param (
    [Parameter(Mandatory = $false)]
    [string]$InstallRoot = "$PSScriptRoot",

    [Parameter(Mandatory = $false)]
    [switch]$Update,

    [Parameter(Mandatory = $false)]
    [switch]$Uninstall
)

# The Prefix that will be used on SOLR, Website and Database instances.
$Prefix = "sc1001"
# The Password for the Sitecore Admin User. This will be regenerated if left on the default.
$SitecoreAdminPassword = "b"
# The root folder with the license file and WDP files.
$SCInstallRoot = "$InstallRoot"
# Root folder to install the site to. If left on the default [systemdrive]:\\inetpub\\wwwroot will be used
$SitePhysicalRoot = ""
# The Sitecore site instance name.
$SitecoreSiteName = "$prefix.sc"
# Identity Server site name
$IdentityServerSiteName = "$prefix.identityserver"
# The Path to the license file
$LicenseFile = "$SCInstallRoot\packages\license.xml"
# The URL of the Solr Server
$SolrUrl = "https://localhost:8983/solr"
# The Folder that Solr has been installed to.
$SolrRoot = "C:\Solr\Solr-8.4.0"
# The Name of the Solr Service.
$SolrService = "Solr-8.4.0"
# The DNS name or IP of the SQL Instance.
$SqlServer = "localhost"
# A SQL user with sysadmin privileges.
$SqlAdminUser = "sa"
# The password for $SQLAdminUser.
$SqlAdminPassword = "12345"
# Enable encryption for SQL connection. If left empty, default SQL behaviour will be used.
$SqlEncrypt = ""
# Trust the server certificate for SQL connection. If left empty, default SQL behaviour will be used.
$SqlTrustServerCertificate = "true"
# The path to the Sitecore Package to Deploy.
$SitecorePackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore 10.0.1 rev. * (XM) (OnPrem)_cm.scwdp.zip").FullName
# The path to the Identity Server Package to Deploy.
$IdentityServerPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.IdentityServer.8.0.37.scwdp.zip").FullName
# The path to the Sitecore Management Services Package to Deploy.
$ManagementServicesPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.ManagementServices*.scwdp.zip").FullName
# The path to the Sitecore JavaScript Services Server Package to Deploy.
$JavaScriptServicesPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore JavaScript Services Server*.scwdp.zip").FullName
# The path to the Sitecore PowerShell Extensions Package to Deploy.
$SPEPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.PowerShell.Extensions*.scwdp.zip").FullName
# The path to the Sitecore Experience Accelerator (XM) Package to Deploy.
$SXAPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore Experience Accelerator XM*.scwdp.zip").FullName
# The Identity Server password recovery URL, this should be the URL of the CM Instance
$PasswordRecoveryUrl = "https://$SitecoreSiteName"
# The URL of the Identity Server
$SitecoreIdentityAuthority = "https://$IdentityServerSiteName"
# The random string key used for establishing connection with IdentityService. This will be regenerated if left on the default.
$ClientSecret = "SIF-Default"
# Pipe-separated list of instances (URIs) that are allowed to login via Sitecore Identity.
$AllowedCorsOrigins = "https://$SitecoreSiteName"

# The directory to write logs to.
$LogsDirectory = "$SCInstallRoot\logs"

# The path to the Sitecore Azure Toolkit tools folder, used to convert the SXA cumulative hotfix package.
$AzureToolkitToolsPath = "$SCInstallRoot\lib\sat\tools"
# The path to the package for the Identity Server security database upgrade script.
$IdentityServerSecurityPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.IdentityServer.UpgradeScripts.8.0.zip").FullName
# The path to the Sitecore cumulative hotfix Package to Deploy.
$SitecoreCumulativeHotfixPackage = (Get-ChildItem "$SCInstallRoot\packages\SC Hotfix 591876-*.zip").FullName
# The path to the SXA cumulative hotfix Package to Deploy.
$SXACumulativeHotfixPackage = (Get-ChildItem "$SCInstallRoot\packages\SC Hotfix SXA-8159-*.zip").FullName

# The path to the Security Bulletin SC2025-002-9109 Package to Deploy.
$SC2025_002Package = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.Support.PDXP-9109.zip").FullName
# The path to the Security Bulletin SC2025-003 Package to Deploy.
$SC2025_003Package = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.Support.10.0-10.4.zip").FullName
# The path to the Security Bulletin SC2025-004 Package to Deploy.
$SC2025_004Package = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.Support.PDXP-11460.zip").FullName

# Install XM0 via combined partials file.
$singleDeveloperParams = @{
    Path = "$SCInstallRoot\XM0-SingleDeveloper.json"
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SqlEncrypt = $SqlEncrypt
    SqlTrustServerCertificate = $SqlTrustServerCertificate
    SitecoreAdminPassword = $SitecoreAdminPassword
    SolrUrl = $SolrUrl
    SolrRoot = $SolrRoot
    SolrService = $SolrService
    Prefix = $Prefix
    IdentityServerCertificateName = $IdentityServerSiteName
    IdentityServerSiteName = $IdentityServerSiteName
    LicenseFile = $LicenseFile
    SitecorePackage = $SitecorePackage
    IdentityServerPackage = $IdentityServerPackage
    SitecoreSitename = $SitecoreSiteName
    PasswordRecoveryUrl = $PasswordRecoveryUrl
    SitecoreIdentityAuthority = $SitecoreIdentityAuthority
    ClientSecret = $ClientSecret
    AllowedCorsOrigins = $AllowedCorsOrigins
    SitePhysicalRoot = $SitePhysicalRoot
}

# Update the Identity Server tables in the security database.
$identityServerSecurityParams = @{
    Path = "$SCInstallRoot\templates\identityserver-security.json"
    Package = $IdentityServerSecurityPackage
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SqlDbPrefix = $Prefix
}

# Install SPE + SXA via combined partials file.
$sxaParams = @{
    Path = "$SCInstallRoot\SXA-SingleDeveloper-XM0.json"
    SPEPackage = $SPEPackage
    SXAPackage = $SXAPackage
    Prefix = $Prefix
    SitecoreAdminPassword = $SitecoreAdminPassword
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SolrUrl = $SolrUrl
    SolrRoot = $SolrRoot
    SolrService = $SolrService
    SiteName = $SitecoreSiteName
}

# Install Sitecore Management Services on the XM0 CM site.
$managementServicesParams = @{
    Path = "$SCInstallRoot\Sitecore.ManagementServices.json"
    Package = $ManagementServicesPackage
    SiteName = $SitecoreSiteName
}

# Install Sitecore JavaScript Services Server on the XM0 CM site.
$javaScriptServicesParams = @{
    Path = "$SCInstallRoot\Sitecore.JavaScriptServices-XM0.json"
    Package = $JavaScriptServicesPackage
    SiteName = $SitecoreSiteName
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SqlDbPrefix = $Prefix
}

# Install the Sitecore cumulative hotfix.
$sitecoreCumulativeHotfixParams = @{
    Path = "$SCInstallRoot\templates\sitecore-hotfix.json"
    SiteName = $SitecoreSiteName
    SitecoreAdminPassword = $SitecoreAdminPassword
    Package = $SitecoreCumulativeHotfixPackage
}

# Install the SXA cumulative hotfix.
$sxaCumulativeHotfixParams = @{
    Path = "$SCInstallRoot\templates\sxa-module-hotfix.json"
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SqlDbPrefix = $Prefix
    SiteName = $SitecoreSiteName
    Package = $SXACumulativeHotfixPackage
    SatToolsPath = $AzureToolkitToolsPath
}

# Install Security Bulletin SC2025-001-7922.
$sc2025_001Params = @{
    Path = "$SCInstallRoot\templates\sc2025-001-7922.json"
    SiteName = $SitecoreSiteName
}

# Install Security Bulletin SC2025-002-9109.
$sc2025_002Params = @{
    Path = "$SCInstallRoot\templates\sitecore-support-patch.json"
    SiteName = $SitecoreSiteName
    Package = $SC2025_002Package
}

# Install Security Bulletin SC2025-003.
$sc2025_003Params = @{
    Path = "$SCInstallRoot\templates\sitecore-support-patch.json"
    SiteName = $SitecoreSiteName
    Package = $SC2025_003Package
}

# Install Security Bulletin SC2025-004.
$sc2025_004Params = @{
    Path = "$SCInstallRoot\templates\sitecore-support-patch.json"
    SiteName = $SitecoreSiteName
    Package = $SC2025_004Package
    IsWrapper = $false
}

Push-Location $SCInstallRoot

if (!$Uninstall) {
    if (!$Update) {
        Install-SitecoreConfiguration @singleDeveloperParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'XM0-SingleDeveloper.log')
        Install-SitecoreConfiguration @identityServerSecurityParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'IdentityServer-Security.log')
        Install-SitecoreConfiguration @sxaParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'SXA-SingleDeveloper.log')
        Install-SitecoreConfiguration @managementServicesParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Sitecore.ManagementServices-SingleDeveloper.log')
        Install-SitecoreConfiguration @javaScriptServicesParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Sitecore.JavaScriptServices-SingleDeveloper.log')
    } else {
        Install-SitecoreConfiguration @sitecoreCumulativeHotfixParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Sitecore-Cumulative-Hotfix.log')
        Install-SitecoreConfiguration @sxaCumulativeHotfixParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'SXA-Cumulative-Hotfix.log')
        Install-SitecoreConfiguration @sc2025_001Params *>&1 | Tee-Object (Join-Path $LogsDirectory 'SC2025-001-7922.log')
        Install-SitecoreConfiguration @sc2025_002Params *>&1 | Tee-Object (Join-Path $LogsDirectory 'SC2025-002-9109.log')
        Install-SitecoreConfiguration @sc2025_003Params *>&1 | Tee-Object (Join-Path $LogsDirectory 'SC2025-003.log')
        Install-SitecoreConfiguration @sc2025_004Params *>&1 | Tee-Object (Join-Path $LogsDirectory 'SC2025-004.log')
    }
} else {
    Uninstall-SitecoreConfiguration @singleDeveloperParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'XM0-SingleDeveloper-Uninstall.log')
}

Pop-Location
