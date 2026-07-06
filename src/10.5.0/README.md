# 🏗️ XM Single (XM0) templates for Sitecore 10.5

XM Single (XM0) templates for [Sitecore 10.5][1]. These templates install a full headless stack.

## ⭐ Packages Installed

| Package | URL |
| ------- | --- |
| Sitecore 10.5 | <https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/105/Sitecore_Experience_Platform_105> |
| Sitecore Headless Rendering 23.0.0 | <https://developers.sitecore.com/downloads/Sitecore_Headless_Rendering/23x/Sitecore_Headless_Rendering_2300> |
| Sitecore Management Services 5.2.129 | <https://developers.sitecore.com/downloads/Sitecore_CLI/7x/Sitecore_CLI_7024> |
| Sitecore PowerShell Extensions 8.0 | <https://github.com/SitecorePowerShell/Console/releases/download/8.0/Sitecore.PowerShell.Extensions-8.0-IAR.scwdp.zip> |

## 📦 Required Files and Packages

1. Place the following packages into the [`./packages`](./packages/) folder:
   - `license.xml`
   - `Sitecore 10.5.0 rev. 014188 (XM) (OnPrem)_cm.scwdp.zip` (extract from _Packages for XM Scaled_ for _On Premises deployment_)
   - `Sitecore Headless Services Server XM 23.0.32.scwdp.zip`
   - `Sitecore.IdentityServer 9.0 rev. 7 (OnPrem)_identityserver.scwdp.zip` (extract from _Packages for XM Scaled_ for _On Premises deployment_)
   - `Sitecore.ManagementServices 5.2.129.scwdp.zip`
   - `Sitecore.PowerShell.Extensions-8.0-IAR.scwdp.zip`

> [!NOTE]
> If you change the packages required for your install:
>
> 1. Update the list of packages above to reflect your install's required packages.
> 2. Run `Validate-Packages.ps1 -UpdateManifest` to update the [`Packages.lock.json`](./Packages.lock.json) file.

## 🚀 Install

1. Validate packages with `Validate-Packages.ps1`.
2. Install Prerequisites: `Install-SitecoreConfiguration -Path Prerequisites.json`.
3. Update variables in [`Solr-SingleDeveloper.ps1`](./Solr-SingleDeveloper.ps1) (e.g., `$SolrPort`).
4. Install Solr with `Solr-SingleDeveloper.ps1`.
5. Update variables in [`XM0-SingleDeveloper.ps1`](./XM0-SingleDeveloper.ps1) (e.g., `$SqlAdminPassword`).
6. Install Sitecore with `XM0-SingleDeveloper.ps1`.

## 🚮 Uninstall

1. Uninstall Sitecore with `XM0-SingleDeveloper.ps1 -Uninstall`.
2. Uninstall Solr with `Solr-SingleDeveloper.ps1 -Uninstall`.

[1]: https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/105/Sitecore_Experience_Platform_105
