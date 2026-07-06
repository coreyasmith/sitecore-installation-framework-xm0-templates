param (
    [Parameter(Mandatory = $false)]
    [string]$InstallRoot = "$PSScriptRoot",

    [Parameter(Mandatory = $false)]
    [switch]$Update,

    [Parameter(Mandatory = $false)]
    [switch]$Uninstall
)

# The Prefix that will be used on SOLR, Website and Database instances.
$Prefix = "sc1032"
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
$SolrRoot = "C:\Solr\Solr-8.11.2"
# The Name of the Solr Service.
$SolrService = "Solr-8.11.2"
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
$SitecorePackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore 10.3.2 rev. * (XM) (OnPrem)_cm.scwdp.zip").FullName
# The path to the Identity Server Package to Deploy.
$IdentityServerPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.IdentityServer.9.0.7.scwdp.zip").FullName
# The path to the Sitecore Management Services Package to Deploy.
$ManagementServicesPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.ManagementServices*.scwdp.zip").FullName
# The path to the Sitecore Headless Services Package to Deploy.
$HeadlessServicesPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore Headless Services Server XM*.scwdp.zip").FullName
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
# The parameter for the installing delta WDP packages
[bool]$Update = $Update.IsPresent
# The elastic pool name for deploy databases from the SQL Azure.
$DeployToElasticPoolName = ""

# The directory to write logs to.
$LogsDirectory = "$SCInstallRoot\logs"

# The path to the Sitecore Azure Toolkit tools folder, used to convert the cumulative hotfix packages.
$AzureToolkitToolsPath = "$SCInstallRoot\lib\sat\tools"
# The path to the package for the Identity Server security database upgrade script.
$IdentityServerSecurityPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.IdentityServer.UpgradeScripts.9.0.zip").FullName
# The path to the SXA cumulative hotfix Package to Deploy.
$SXACumulativeHotfixPackage = (Get-ChildItem "$SCInstallRoot\packages\SC Hotfix*SXA*.zip").FullName
# The path to the Headless Services Layout Service cumulative hotfix Package to Deploy.
$HeadlessServicesCumulativeHotfixLayoutServicePackage = (Get-ChildItem "$SCInstallRoot\packages\SC Hotfix*Layout Service*.zip").FullName
# The path to the Headless Services GraphQL cumulative hotfix Package to Deploy.
$HeadlessServicesCumulativeHotfixGraphQLPackage = (Get-ChildItem "$SCInstallRoot\packages\SC Hotfix*GraphQL*.zip").FullName

if ($Update) {
    $SitecorePackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore 10.3.* PRE (XM) (OnPrem)_cm.cumulative.delta.scwdp.zip").FullName
    $IdentityServerPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.IdentityServer * rev. * (OnPrem)_identityserver.cumulative.delta.scwdp.zip").FullName
}

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
    Update = $Update
    DeployToElasticPoolName = $DeployToElasticPoolName
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

# Install Sitecore Headless Services on the XM0 CM site.
$headlessServicesParams = @{
    Path = "$SCInstallRoot\Sitecore.HeadlessServices-XM0.json"
    Package = $HeadlessServicesPackage
    SiteName = $SitecoreSiteName
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SqlDbPrefix = $Prefix
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

# Install the Headless Services Layout Service cumulative hotfix.
$headlessServicesCumulativeHotfixLayoutServiceParams = @{
    Path = "$SCInstallRoot\templates\sitecore-module-hotfix.json"
    Package = $HeadlessServicesCumulativeHotfixLayoutServicePackage
    SiteName = $SitecoreSiteName
    SatToolsPath = $AzureToolkitToolsPath
}

# Install the Headless Services GraphQL cumulative hotfix.
$headlessServicesCumulativeHotfixGraphQLParams = @{
    Path = "$SCInstallRoot\templates\sitecore-module-hotfix.json"
    Package = $HeadlessServicesCumulativeHotfixGraphQLPackage
    SiteName = $SitecoreSiteName
    SatToolsPath = $AzureToolkitToolsPath
}

Push-Location $SCInstallRoot

if (!$Uninstall) {
    Install-SitecoreConfiguration @singleDeveloperParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'XM0-SingleDeveloper.log')
    Install-SitecoreConfiguration @identityServerSecurityParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'IdentityServer-Security.log')
    Install-SitecoreConfiguration @sxaParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'SXA-SingleDeveloper.log')
    Install-SitecoreConfiguration @managementServicesParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Sitecore.ManagementServices-SingleDeveloper.log')
    Install-SitecoreConfiguration @headlessServicesParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Sitecore.HeadlessServices-SingleDeveloper.log')
    if ($Update) {
        Install-SitecoreConfiguration @sxaCumulativeHotfixParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'SXA-Cumulative-Hotfix.log')
        Install-SitecoreConfiguration @headlessServicesCumulativeHotfixLayoutServiceParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Sitecore.HeadlessServices-CumulativeHotfix-LayoutService.log')
        Install-SitecoreConfiguration @headlessServicesCumulativeHotfixGraphQLParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Sitecore.HeadlessServices-CumulativeHotfix-GraphQL.log')
    }
} else {
    Uninstall-SitecoreConfiguration @singleDeveloperParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'XM0-SingleDeveloper-Uninstall.log')
}

Pop-Location
