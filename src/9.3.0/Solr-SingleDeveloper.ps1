param (
    [Parameter(Mandatory = $false)]
    [string]$InstallRoot = $PSScriptRoot,

    [Parameter(Mandatory = $false)]
    [switch]$Uninstall
)

# The version of Solr to install.
$SolrVersion = "8.1.1"
# The URL/domain for Solr; used as the CN/SAN on the self-signed SSL certificate.
$SolrDomain = "localhost"
# The Solr port.
$SolrPort = 8983
# Prefix prepended to the Solr service name and install folder (leave empty for vanilla "solr-<version>").
$SolrServicePrefix = ""
# The root folder under which Solr is installed. The config appends [SolrServicePrefix]solr-[SolrVersion] (e.g. C:\solr-8.1.1).
$SolrInstallRoot = "C:\Solr"

# The directory to write logs to.
$LogsDirectory = "$InstallRoot\logs"

$solrParams = @{
    Path              = "$PSScriptRoot\Solr-SingleDeveloper.json"
    SolrVersion       = $SolrVersion
    SolrDomain        = $SolrDomain
    SolrPort          = $SolrPort
    SolrServicePrefix = $SolrServicePrefix
    SolrInstallRoot   = $SolrInstallRoot
}

if (!$Uninstall) {
    Install-SitecoreConfiguration @solrParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Solr-SingleDeveloper.log')
}
else {
    Uninstall-SitecoreConfiguration @solrParams *>&1 | Tee-Object (Join-Path $LogsDirectory 'Solr-SingleDeveloper-Uninstall.log')
}
