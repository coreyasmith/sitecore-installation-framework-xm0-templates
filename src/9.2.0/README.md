# 🏗️ XM Single (XM0) templates for Sitecore 9.2 Initial Release

XM Single (XM0) templates for [Sitecore 9.2 Initial Release][1]. These templates install a full headless stack with the latest cumulative hotfixes[^1] and security bulletins.

## ⭐ Packages Installed

| Package | URL |
| ------- | --- |
| Sitecore 9.2 Initial Release | <https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/92/Sitecore_Experience_Platform_92_Initial_Release> |
| Sitecore Identity Server 8.0.37 | <https://developers.sitecore.com/downloads/Sitecore_Identity/8x/Sitecore_Identity_Server_8037> |
| Sitecore Experience Accelerator 1.9.0 | <https://developers.sitecore.com/downloads/Sitecore_Experience_Accelerator/19/Sitecore_Experience_Accelerator_190> |
| Sitecore JavaScript Services 12.0.0 | <https://developers.sitecore.com/downloads/Sitecore_JavaScript_Services/120/Sitecore_JavaScript_Services_1200> |
| Sitecore PowerShell Extensions 8.0 | <https://github.com/SitecorePowerShell/Console/releases/download/8.0/Sitecore.PowerShell.Extensions-8.0.scwdp.zip> |
| Cumulative hotfix for Sitecore 9.2 (XM)[^1] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1001331> |
| Cumulative hotfix for SXA 1.9.0[^1] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1001753> |
| Security Bulletin SC2025-001-7922[^2] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003633> |
| Security Bulletin SC2025-002-9109 | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003650> |
| Security Bulletin SC2025-003 | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003667> |
| Security Bulletin SC2025-004 | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003734> |

## 📦 Required Files and Packages

1. Unzip [Sitecore Azure Toolkit 3.0.0][2] into the [`./lib/sat`](./lib/sat/) folder.
2. Place the following packages into the [`./packages`](./packages/) folder:
   - `license.xml`
   - `Sitecore 9.2.0 rev. 002893 (XM) (OnPrem)_cm.scwdp.zip` (extract from _Packages for XM Scaled_ for _On Premises deployment_)
   - `Sitecore Experience Accelerator XM 1.9.0 rev. 190528 for 9.2.scwdp.zip`
   - `Sitecore JavaScript Services Server for Sitecore 9.2 XM 12.0.0 rev. 190522.scwdp.zip`
   - `Sitecore.IdentityServer.8.0.37.scwdp.zip` (_Sitecore Identity Server WDP_ for _On-premises deployments_)
   - `Sitecore.IdentityServer.UpgradeScripts.8.0.zip` (_Identity Server Upgrade Script_ for _On-premises deployments_)
   - `Sitecore.PowerShell.Extensions-8.0.scwdp.zip`
   - `SC Hotfix 584731-1 for 9.2.0.zip` (Cumulative hotfix for Sitecore 9.2)
   - `SC Hotfix SXA-8159-1 1.9.0 rev. 190528.zip` (Cumulative hotfix for SXA 1.9.0)
   - `Sitecore.Support.PDXP-9109.zip` (Security Bulletin SC2025-002-9109)
   - `Sitecore.Support.9.0-9.3.zip` (Security Bulletin SC2025-003)
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

## 🚮 Uninstall

1. Uninstall Sitecore with `XM0-SingleDeveloper.ps1 -Uninstall`.
2. Uninstall Solr with `Solr-SingleDeveloper.ps1 -Uninstall`.

[^1]: Sitecore Support releases new versions of cumulative hotfixes on a regular basis. When they publish a new version, the old versions are removed from their downloads. The cumulative hotfix versions listed here may not reflect the most recent version. If the currently available version does not work with these templates, please open an issue.
[^2]: There is no package for this bulletin. The patch is applied through [templates/files/sc2025-001-7922/Web.config.xdt](templates/files/sc2025-001-7922/Web.config.xdt).

[1]: https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/92/Sitecore_Experience_Platform_92_Initial_Release
[2]: https://developers.sitecore.com/downloads/Sitecore_Azure_Toolkit/3x/Sitecore_Azure_Toolkit_300
