# 🏗️ XM Single (XM0) templates for Sitecore 10.2 Update-2

XM Single (XM0) templates for [Sitecore 10.2 Update-2][1]. These templates install a full headless stack with the latest cumulative hotfixes[^1] and security bulletins.

## ⭐ Packages Installed

| Package | URL |
| ------- | --- |
| Sitecore 10.2 Update-2 | <https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/102/Sitecore_Experience_Platform_102_Update2> |
| Sitecore Identity Server 8.0.37 | <https://developers.sitecore.com/downloads/Sitecore_Identity/8x/Sitecore_Identity_Server_8037> |
| Sitecore Experience Accelerator 10.2.0 | <https://developers.sitecore.com/downloads/Sitecore_Experience_Accelerator/10x/Sitecore_Experience_Accelerator_1020> |
| Sitecore Headless Rendering 20.0.2 | <https://developers.sitecore.com/downloads/Sitecore_Headless_Rendering/20x/Sitecore_Headless_Rendering_2002> |
| Sitecore Management Services 5.2.129 | <https://developers.sitecore.com/downloads/Sitecore_CLI/7x/Sitecore_CLI_7024> |
| Sitecore PowerShell Extensions 8.0 | <https://github.com/SitecorePowerShell/Console/releases/download/8.0/Sitecore.PowerShell.Extensions-8.0-IAR.scwdp.zip> |
| Cumulative hotfix for Sitecore XP 10.2[^1] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1001439> |
| Cumulative hotfix for SXA 10.2.0[^1] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1001757> |
| Cumulative hotfixes for Sitecore Headless Rendering 20[^1] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003202> |
| Security Bulletin SC2025-001-7922[^2] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003633> |

## 📦 Required Files and Packages

1. Unzip [Sitecore Azure Toolkit 3.0.0][2] into the [`./lib/sat`](./lib/sat/) folder.
2. Place the following packages into the [`./packages`](./packages/) folder:
   - `license.xml`
   - `Sitecore 10.2.2 rev. 010645 (XM) (OnPrem)_cm.scwdp.zip` (extract from _Packages for XM Scaled_ for _On Premises deployment_)
   - `Sitecore Experience Accelerator XM 10.2.0 rev. 04247.scwdp.zip`
   - `Sitecore Headless Services Server XM 20.0.2 rev. 00545.scwdp.zip`
   - `Sitecore.IdentityServer.8.0.37.scwdp.zip` (_Sitecore Identity Server WDP_ for _On-premises deployments_)
   - `Sitecore.IdentityServer.UpgradeScripts.8.0.zip` (_Identity Server Upgrade Script_ for _On-premises deployments_)
   - `Sitecore.ManagementServices 5.2.129.scwdp.zip`
   - `Sitecore.PowerShell.Extensions-8.0-IAR.scwdp.zip`
   - `Sitecore 10.2.3 rev. 013888 PRE (XM) (OnPrem)_cm.delta.scwdp.zip`[^1] (extract from `Sitecore 10.2.3 rev. 013888 (DELTA WDP XM1 packages).zip`)
   - `Sitecore.IdentityServer 8.0 rev. 37 (OnPrem)_identityserver.delta.scwdp.zip`[^1] (extract from `Sitecore 10.2.3 rev. 013888 (DELTA WDP XM1 packages).zip`)
   - `SC Hotfix 609694-1 Layout Service 8.1.0.zip` (Cumulative hotfixes for Sitecore Headless Rendering 20)
   - `SC Hotfix 610626-1 JSS 20.0.2.zip` (Cumulative hotfixes for Sitecore Headless Rendering 20)
   - `SC Hotfix 627255-1 GraphQL 6.1.1.zip` (Cumulative hotfixes for Sitecore Headless Rendering 20)
   - `SC Hotfix SXA-8776-1 10.2.0.4247.zip` (Cumulative hotfix for SXA 10.2.0)

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
> [Cumulative hotfix for SXA 10.2.0][3] installs the [Sitecore PowerShell Extensions (SPE) 6.3][4] IAR files, so [SPE 8][5] is reinstalled after [Cumulative hotfix for SXA 10.2.0][3] in [Sitecore 10.2 Update-2][1]. If you install [SPE 6.3][4], you can remove the reinstall of SPE after [Cumulative hotfix for SXA 10.2.0][3].

## 🚮 Uninstall

1. Uninstall Sitecore with `XM0-SingleDeveloper.ps1 -Uninstall`.
2. Uninstall Solr with `Solr-SingleDeveloper.ps1 -Uninstall`.

[^1]: Sitecore Support releases new versions of cumulative hotfixes on a regular basis. When they publish a new version, the old versions are removed from their downloads. The cumulative hotfix versions listed here may not reflect the most recent version. If the currently available version does not work with these templates, please open an issue.
[^2]: There is no package for this bulletin. The patch is applied through [templates/files/sc2025-001-7922/Web.config.xdt](templates/files/sc2025-001-7922/Web.config.xdt).

[1]: https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/102/Sitecore_Experience_Platform_102_Update2
[2]: https://developers.sitecore.com/downloads/Sitecore_Azure_Toolkit/3x/Sitecore_Azure_Toolkit_300
[3]: https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1001757
[4]: https://github.com/SitecorePowerShell/Console/releases#release-6.3
[5]: https://github.com/SitecorePowerShell/Console/releases#release-8.0
