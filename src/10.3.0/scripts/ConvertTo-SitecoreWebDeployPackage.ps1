param (
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [string]$AzureToolkitToolsPath = "$PWD\lib\sat\tools",

    [string]$Destination = "$PWD\packages"
)

Import-Module "$AzureToolkitToolsPath\Sitecore.Cloud.Cmdlets.psm1"
Import-Module "$AzureToolkitToolsPath\Sitecore.Cloud.Cmdlets.dll"

# The toolkit cmdlets resolve relative paths against the process working directory rather than the
# PowerShell location, so root them here.
$rootedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
$rootedDestination = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)

ConvertTo-SCModuleWebDeployPackage `
    -Path $rootedPath `
    -Destination $rootedDestination `
    -Force `
    -Verbose `
    -DisableDacPacOptions "*"
