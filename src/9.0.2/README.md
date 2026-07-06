# 🏗️ XM Single (XM0) templates for Sitecore 9.0 Update-2

XM Single (XM0) templates for [Sitecore 9.0 Update-2][1]. These templates install a full headless stack with the latest security bulletins.

## ⭐ Packages Installed

| Package | URL |
| ------- | --- |
| Sitecore 9.0 Update-2 | <https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/90/Sitecore_Experience_Platform_90_Update2> |
| Sitecore Experience Accelerator 1.8.1 | <https://developers.sitecore.com/downloads/Sitecore_Experience_Accelerator/18/Sitecore_Experience_Accelerator_181> |
| Sitecore JavaScript Services 11.0.0 | <https://developers.sitecore.com/downloads/Sitecore_JavaScript_Services/110/Sitecore_JavaScript_Services_1100> |
| Sitecore PowerShell Extensions 8.0 | <https://github.com/SitecorePowerShell/Console/releases/download/8.0/Sitecore.PowerShell.Extensions-8.0.scwdp.zip> |
| Security Bulletin SC2023-003-587441 | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003018> |
| Security Bulletin SC2025-001-7922[^1] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003633> |
| Security Bulletin SC2025-002-9109 | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003650> |
| Security Bulletin SC2025-003 | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003667> |

## 📦 Required Files and Packages

1. Place the following packages into the [`./packages`](./packages/) folder:
   - `license.xml`
   - `Sitecore 9.0.2 rev. 180604 (OnPrem)_cm.scwdp.zip` (extract from _Packages for XM Scaled_ for _On Premises deployment_)
   - `Sitecore Experience Accelerator 1.8.1 rev. 190319 for 9.0.scwdp.zip`
   - `Sitecore JavaScript Services Server for Sitecore 9.0 11.0.0 rev. 181031.scwdp.zip`
   - `Sitecore.PowerShell.Extensions-8.0.scwdp.zip`
   - `SC Hotfix 584731-1 for 9.0.2.zip` (Security Bulletin SC2023-003-587441)
   - `Sitecore.Support.PDXP-9109.zip` (Security Bulletin SC2025-002-9109)
   - `Sitecore.Support.9.0-9.3.zip` (Security Bulletin SC2025-003)

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
7. Install the security bulletins with `XM0-SingleDeveloper.ps1 -Update`.

## 🚮 Uninstall

1. Uninstall Sitecore with `XM0-SingleDeveloper.ps1 -Uninstall`.
2. Uninstall Solr with `Solr-SingleDeveloper.ps1 -Uninstall`.

[^1]: There is no package for this bulletin. The patch is applied through [templates/files/sc2025-001-7922/Web.config.xdt](templates/files/sc2025-001-7922/Web.config.xdt).

[1]: https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/90/Sitecore_Experience_Platform_90_Update2
