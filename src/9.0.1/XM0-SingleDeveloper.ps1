param (
    [Parameter(Mandatory = $false)]
    [string]$InstallRoot = "$PSScriptRoot",

    [Parameter(Mandatory = $false)]
    [switch]$Update,

    [Parameter(Mandatory = $false)]
    [switch]$Uninstall
)

# The Prefix that will be used on SOLR, Website and Database instances.
$Prefix = "sc901"
# The Password for the Sitecore Admin User. This will be regenerated if left on the default.
$SitecoreAdminPassword = "b"
# The root folder with the license file and WDP files.
$SCInstallRoot = "$InstallRoot"
# The Sitecore site instance name.
$SitecoreSiteName = "$prefix.sc"
# The Path to the license file
$LicenseFile = "$SCInstallRoot\packages\license.xml"
# The URL of the Solr Server
$SolrUrl = "https://localhost:8983/solr"
# The Folder that Solr has been installed to.
$SolrRoot = "C:\Solr\Solr-6.6.1"
# The Name of the Solr Service.
$SolrService = "Solr-6.6.1"
# The DNS name or IP of the SQL Instance.
$SqlServer = "localhost"
# A SQL user with sysadmin privileges.
$SqlAdminUser = "sa"
# The password for $SQLAdminUser.
$SqlAdminPassword = "12345"
# The path to the Sitecore Package to Deploy.
$SitecorePackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore 9.0.1 rev. * (OnPrem)_cm.scwdp.zip").FullName
# The path to the Sitecore JavaScript Services Server Package to Deploy.
$JavaScriptServicesPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore JavaScript Services Tech Preview Server*.zip").FullName
# The path to the Sitecore PowerShell Extensions Package to Deploy.
$SPEPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.PowerShell.Extensions*.scwdp.zip").FullName
# The path to the Sitecore Experience Accelerator Package to Deploy.
$SXAPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore Experience Accelerator 1.*.scwdp.zip").FullName

# The directory to write logs to.
$LogsDirectory = "$SCInstallRoot\logs"

# The path to the Sitecore Azure Toolkit tools folder, used to convert the JavaScript Services package.
$AzureToolkitToolsPath = "$SCInstallRoot\lib\sat\tools"
# The path to the Security Bulletin SC2023-003-587441 Package to Deploy.
$SC2023_003Package = (Get-ChildItem "$SCInstallRoot\packages\SC Hotfix 584731-1*.zip").FullName
# The path to the Security Bulletin SC2025-002-9109 Package to Deploy.
$SC2025_002Package = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.Support.PDXP-9109.zip").FullName
# The path to the Security Bulletin SC2025-003 Package to Deploy.
$SC2025_003Package = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.Support.9.0-9.3.zip").FullName

# Install XM0 via combined partials file.
$singleDeveloperParams = @{
    Path = "$SCInstallRoot\XM0-SingleDeveloper.json"
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SitecoreAdminPassword = $SitecoreAdminPassword
    SolrUrl = $SolrUrl
    SolrRoot = $SolrRoot
    SolrService = $SolrService
    Prefix = $Prefix
    LicenseFile = $LicenseFile
    SitecorePackage = $SitecorePackage
    SitecoreSitename = $SitecoreSiteName
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
    SiteName = $SitecoreSiteName
}

# Install Sitecore JavaScript Services Server on the XM0 CM site.
$javaScriptServicesParams = @{
    Path = "$SCInstallRoot\Sitecore.JavaScriptServices-XM0.json"
    Package = $JavaScriptServicesPackage
    SatToolsPath = $AzureToolkitToolsPath
    SiteName = $SitecoreSiteName
    SitecoreAdminPassword = $SitecoreAdminPassword
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SqlDbPrefix = $Prefix
}

# Install Security Bulletin SC2023-003-587441.
$sc2023_003Params = @{
    Path = "$SCInstallRoot\templates\sitecore-hotfix.json"
    SiteName = $SitecoreSiteName
    SitecoreAdminPassword = $SitecoreAdminPassword
    Package = $SC2023_003Package
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

Push-Location $SCInstallRoot

if (!$Uninstall) {
    if (!$Update) {
        Install-SitecoreConfiguration @singleDeveloperParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'XM0-SingleDeveloper.log')
        Install-SitecoreConfiguration @sxaParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'SXA-SingleDeveloper.log')
        Install-SitecoreConfiguration @javaScriptServicesParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Sitecore.JavaScriptServices-SingleDeveloper.log')
    } else {
        Install-SitecoreConfiguration @sc2023_003Params *>&1 | Tee-Object (Join-Path $LogsDirectory 'SC2023-003-587441.log')
        Install-SitecoreConfiguration @sc2025_001Params *>&1 | Tee-Object (Join-Path $LogsDirectory 'SC2025-001-7922.log')
        Install-SitecoreConfiguration @sc2025_002Params *>&1 | Tee-Object (Join-Path $LogsDirectory 'SC2025-002-9109.log')
        Install-SitecoreConfiguration @sc2025_003Params *>&1 | Tee-Object (Join-Path $LogsDirectory 'SC2025-003.log')
    }
} else {
    Uninstall-SitecoreConfiguration @singleDeveloperParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'XM0-SingleDeveloper-Uninstall.log')
}

Pop-Location
