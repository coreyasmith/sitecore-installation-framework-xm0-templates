param (
    [Parameter(Mandatory = $false)]
    [string]$InstallRoot = "$PSScriptRoot",

    [Parameter(Mandatory = $false)]
    [switch]$Update,

    [Parameter(Mandatory = $false)]
    [switch]$Uninstall
)

# The Prefix that will be used on SOLR, Website and Database instances.
$Prefix = "sc1050"
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
# The admin username for the Solr instance.
$SolrAdminUserName = "admin"
# The admin password for the Solr instance.
$SolrAdminPassword = "b"
# The Folder that Solr has been installed to.
$SolrRoot = "C:\Solr\Solr-10.0.0"
# The Name of the Solr Service.
$SolrService = "Solr-10.0.0"
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
$SitecorePackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore 10.5.0 rev. * (XM) (OnPrem)_cm.scwdp.zip").FullName
# The path to the Identity Server Package to Deploy.
$IdentityServerPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.IdentityServer * rev. 7 (OnPrem)_identityserver.*scwdp.zip").FullName
# The path to the Sitecore Management Services Package to Deploy.
$ManagementServicesPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.ManagementServices*.scwdp.zip").FullName
# The path to the Sitecore Headless Services Package to Deploy.
$HeadlessServicesPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore Headless Services Server XM*.scwdp.zip").FullName
# The path to the Sitecore PowerShell Extensions Package to Deploy.
$SPEPackage = (Get-ChildItem "$SCInstallRoot\packages\Sitecore.PowerShell.Extensions*.scwdp.zip").FullName
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
# Enable the Package Installer and Designer in Sitecore. Sitecore disables them by default.
$EnablePackageInstaller = $true

# The directory to write logs to.
$LogsDirectory = "$SCInstallRoot\logs"

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
    SolrAdminUserName = $SolrAdminUserName
    SolrAdminPassword = $SolrAdminPassword
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
    EnablePackageInstaller = $EnablePackageInstaller
}

# Install SPE via combined partials file.
$speParams = @{
    Path = "$SCInstallRoot\SPE-SingleDeveloper-XM0.json"
    SPEPackage = $SPEPackage
    Prefix = $Prefix
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
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

Push-Location $SCInstallRoot

if (!$Uninstall) {
    Install-SitecoreConfiguration @singleDeveloperParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'XM0-SingleDeveloper.log')
    Install-SitecoreConfiguration @speParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'SPE-SingleDeveloper.log')
    Install-SitecoreConfiguration @managementServicesParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Sitecore.ManagementServices-SingleDeveloper.log')
    Install-SitecoreConfiguration @headlessServicesParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Sitecore.HeadlessServices-SingleDeveloper.log')
} else {
    Uninstall-SitecoreConfiguration @singleDeveloperParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'XM0-SingleDeveloper-Uninstall.log')
}

Pop-Location
