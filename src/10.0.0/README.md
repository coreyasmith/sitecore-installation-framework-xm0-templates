# 🏗️ XM Single (XM0) templates for Sitecore 10.0

XM Single (XM0) templates for [Sitecore 10.0][1]. These templates install a full headless stack with the latest cumulative hotfixes[^1] and security bulletins.

## ⭐ Packages Installed

| Package | URL |
| ------- | --- |
| Sitecore 10.0 | <https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/100/Sitecore_Experience_Platform_100> |
| Sitecore Identity Server 8.0.37 | <https://developers.sitecore.com/downloads/Sitecore_Identity/8x/Sitecore_Identity_Server_8037> |
| Sitecore Experience Accelerator 10.0.0 | <https://developers.sitecore.com/downloads/Sitecore_Experience_Accelerator/10x/Sitecore_Experience_Accelerator_1000> |
| Sitecore Headless Rendering 15.0.1 | <https://developers.sitecore.com/downloads/Sitecore_Headless_Rendering/150/Sitecore_Headless_Rendering_1501> |
| Sitecore Management Services 2.0.0 | <https://developers.sitecore.com/downloads/Sitecore_CLI/2x/Sitecore_CLI_200> |
| Sitecore PowerShell Extensions 8.0 | <https://github.com/SitecorePowerShell/Console/releases/download/8.0/Sitecore.PowerShell.Extensions-8.0.scwdp.zip> |
| Cumulative hotfix for Sitecore 10.0.0 (XM)[^1] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1001333> |
| Cumulative hotfix for SXA 10.0.0[^1] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1001755> |
| Security Bulletin SC2025-001-7922[^2] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003633> |
| Security Bulletin SC2025-002-9109 | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003650> |
| Security Bulletin SC2025-003 | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003667> |
| Security Bulletin SC2025-004 | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003734> |

## 📦 Required Files and Packages

1. Unzip [Sitecore Azure Toolkit 3.0.0][2] into the [`./lib/sat`](./lib/sat/) folder.
2. Place the following packages into the [`./packages`](./packages/) folder:
   - `license.xml`
   - `Sitecore 10.0.0 rev. 004346 (XM) (OnPrem)_cm.scwdp.zip` (extract from _Packages for XM Scaled_ for _On Premises deployment_)
   - `Sitecore Experience Accelerator XM 10.0.0.3138.scwdp.zip`
   - `Sitecore JavaScript Services Server for Sitecore 10.0.0 XM 15.0.1 rev. 201112.scwdp.zip`
   - `Sitecore.IdentityServer.8.0.37.scwdp.zip` (_Sitecore Identity Server WDP_ for _On-premises deployments_)
   - `Sitecore.IdentityServer.UpgradeScripts.8.0.zip` (_Identity Server Upgrade Script_ for _On-premises deployments_)
   - `Sitecore.ManagementServices 2.0.0-r00202.scwdp.zip`
   - `Sitecore.PowerShell.Extensions-8.0.scwdp.zip`
   - `SC Hotfix 591876-1.zip` (Cumulative hotfix for Sitecore 10.0.0)
   - `SC Hotfix SXA-8159-1 10.0.0.3138.zip` (Cumulative hotfix for SXA 10.0.0)
   - `Sitecore.Support.PDXP-9109.zip` (Security Bulletin SC2025-002-9109)
   - `Sitecore.Support.10.0-10.4.zip` (Security Bulletin SC2025-003)
   - `Sitecore.Support.PDXP-11460.zip` (Security Bulletin SC2025-004)

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
7. Install Sitecore cumulative hotfixes and security bulletins with `XM0-SingleDeveloper.ps1 -Update`.

### 🧹 Postinstall Steps

If the Sitecore PowerShell Extensions buttons on the Launchpad have broken icons:

1. Open `/sitecore/system/Modules/PowerShell/Script Library/SPE/Core/Platform/Upgrade/Compatibility` in the PowerShell ISE.
2. Change `$oldVersion = New-Object System.Version(10,0)` to `$oldVersion = New-Object System.Version(10,1)`.
3. Execute the script.

## 🚮 Uninstall

1. Uninstall Sitecore with `XM0-SingleDeveloper.ps1 -Uninstall`.
2. Uninstall Solr with `Solr-SingleDeveloper.ps1 -Uninstall`.

[^1]: Sitecore Support releases new versions of cumulative hotfixes on a regular basis. When they publish a new version, the old versions are removed from their downloads. The cumulative hotfix versions listed here may not reflect the most recent version. If the currently available version does not work with these templates, please open an issue.
[^2]: There is no package for this bulletin. The patch is applied through [templates/files/sc2025-001-7922/Web.config.xdt](templates/files/sc2025-001-7922/Web.config.xdt).

[1]: https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/100/Sitecore_Experience_Platform_100
[2]: https://developers.sitecore.com/downloads/Sitecore_Azure_Toolkit/3x/Sitecore_Azure_Toolkit_300
