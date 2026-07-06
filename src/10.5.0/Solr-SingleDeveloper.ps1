param (
    [Parameter(Mandatory = $false)]
    [string]$InstallRoot = $PSScriptRoot,

    [Parameter(Mandatory = $false)]
    [switch]$Uninstall
)

# The version of Solr to install.
$SolrVersion = "10.0.0"
# The URL/domain for Solr; used as the CN/SAN on the self-signed SSL certificate.
$SolrDomain = "localhost"
# The Solr port.
$SolrPort = 8983
# The admin password for the Solr instance.
$SolrAdminPassword = "b"
# Prefix prepended to the Solr service name and install folder (leave empty for vanilla "solr-<version>").
$SolrServicePrefix = ""
# The root folder under which Solr is installed. The config appends [SolrServicePrefix]solr-[SolrVersion] (e.g. C:\solr-10.0.0).
$SolrInstallRoot = "C:\Solr"

# The directory to write logs to.
$LogsDirectory = "$InstallRoot\logs"

$solrParams = @{
    Path              = "$PSScriptRoot\Solr-SingleDeveloper.json"
    SolrVersion       = $SolrVersion
    SolrDomain        = $SolrDomain
    SolrPort          = $SolrPort
    SolrAdminPassword = $SolrAdminPassword
    SolrServicePrefix = $SolrServicePrefix
    SolrInstallRoot   = $SolrInstallRoot
}

if (!$Uninstall) {
    Install-SitecoreConfiguration @solrParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Solr-SingleDeveloper.log')
}
else {
    Uninstall-SitecoreConfiguration @solrParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Solr-SingleDeveloper-Uninstall.log')
}
