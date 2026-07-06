# 🏗️ XM Single (XM0) templates for Sitecore 10.1 Update-3

XM Single (XM0) templates for [Sitecore 10.1 Update-3][1]. These templates install a full headless stack with the latest cumulative hotfixes[^1] and security bulletins.

## ⭐ Packages Installed

| Package | URL |
| ------- | --- |
| Sitecore 10.1 Update-3 | <https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/101/Sitecore_Experience_Platform_101_Update3> |
| Sitecore Identity Server 8.0.37 | <https://developers.sitecore.com/downloads/Sitecore_Identity/8x/Sitecore_Identity_Server_8037> |
| Sitecore Experience Accelerator 10.1.0 | <https://developers.sitecore.com/downloads/Sitecore_Experience_Accelerator/10x/Sitecore_Experience_Accelerator_1010> |
| Sitecore Headless Rendering 18.0.0 | <https://developers.sitecore.com/downloads/Sitecore_Headless_Rendering/18x/Sitecore_Headless_Rendering_1800> |
| Sitecore Management Services 5.2.129 | <https://developers.sitecore.com/downloads/Sitecore_CLI/7x/Sitecore_CLI_7024> |
| Sitecore PowerShell Extensions 8.0 | <https://github.com/SitecorePowerShell/Console/releases/download/8.0/Sitecore.PowerShell.Extensions-8.0.scwdp.zip> |
| Cumulative hotfix for Sitecore XP 10.1[^1][^2] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1001300> |
| Cumulative hotfix for SXA 10.1.0[^1] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1001756> |
| Cumulative hotfixes for Sitecore Headless Rendering 18[^1] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003204> |
| Security Bulletin SC2025-001-7922[^3] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003633> |

## 📦 Required Files and Packages

1. Unzip [Sitecore Azure Toolkit 3.0.0][2] into the [`./lib/sat`](./lib/sat/) folder.
2. Place the following packages into the [`./packages`](./packages/) folder:
   - `license.xml`
   - `Sitecore 10.1.3 rev. 009558 (XM) (OnPrem)_cm.scwdp.zip` (extract from _Packages for XM Scaled_ for _On Premises deployment_)
   - `Sitecore Experience Accelerator XM 10.1.0.3751.scwdp.zip`
   - `Sitecore Headless Services Server XM 18.0.0 rev. 00473.scwdp.zip`
   - `Sitecore.IdentityServer.8.0.37.scwdp.zip` (_Sitecore Identity Server WDP_ for _On-premises deployments_)
   - `Sitecore.IdentityServer.UpgradeScripts.8.0.zip` (_Identity Server Upgrade Script_ for _On-premises deployments_)
   - `Sitecore.ManagementServices 5.2.129.scwdp.zip`
   - `Sitecore.PowerShell.Extensions-8.0.scwdp.zip`
   - `Sitecore 10.1.4 rev. 013779 PRE (XM) (OnPrem)_cm.delta.scwdp.zip`[^1] (extract from `Sitecore 10.1.4 rev. 013779 (DELTA WDP XM1 packages).zip`)
   - `Sitecore.IdentityServer 8.0 rev. 28 (OnPrem)_identityserver.delta.scwdp.zip`[^1] (extract from `Sitecore 10.1.4 rev. 013779 (DELTA WDP XM1 packages).zip`)
   - `SC Hotfix SXA-8159-1 10.1.0.3751.zip` (Cumulative hotfix for SXA 10.1.0)
   - `SC Hotfix-549890-1 Layout Service 7.1.0.zip` (Cumulative hotfixes for Sitecore Headless Rendering 18)
   - `SC Hotfix-569574-1 GraphQL 5.1.0.zip` (Cumulative hotfixes for Sitecore Headless Rendering 18)

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

### Module Install Notes

> [!WARNING]
> [Sitecore Management Services 5.2.129][3] ships newer versions of Sitecore Services GraphQL DLLs than are included with [Sitecore Headless Services 18][4], so Management Services is installed after Headless Services in [Sitecore 10.1 Update-3][1]. If you install [Sitecore Management Services 3.0.0][5], you must flip the install order of these two modules.

## 🚮 Uninstall

1. Uninstall Sitecore with `XM0-SingleDeveloper.ps1 -Uninstall`.
2. Uninstall Solr with `Solr-SingleDeveloper.ps1 -Uninstall`.

[^1]: Sitecore Support releases new versions of cumulative hotfixes on a regular basis. When they publish a new version, the old versions are removed from their downloads. The cumulative hotfix versions listed here may not reflect the most recent version. If the currently available version does not work with these templates, please open an issue.
[^2]: Use the download link in the _Cumulative hotfix on top of the latest update_ section, not the _Cumulative hotfix on top of any updates_ section.
[^3]: There is no package for this bulletin. The patch is applied through [templates/files/sc2025-001-7922/Web.config.xdt](templates/files/sc2025-001-7922/Web.config.xdt).

[1]: https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/101/Sitecore_Experience_Platform_101_Update3
[2]: https://developers.sitecore.com/downloads/Sitecore_Azure_Toolkit/3x/Sitecore_Azure_Toolkit_300
[3]: https://developers.sitecore.com/downloads/Sitecore_CLI/7x/Sitecore_CLI_7024
[4]: https://developers.sitecore.com/downloads/Sitecore_Headless_Rendering/18x/Sitecore_Headless_Rendering_1800
[5]: https://developers.sitecore.com/downloads/Sitecore_CLI/3x/Sitecore_CLI_300
