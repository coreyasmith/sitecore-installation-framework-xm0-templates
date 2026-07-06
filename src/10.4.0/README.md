# 🏗️ XM Single (XM0) templates for Sitecore 10.4

XM Single (XM0) templates for [Sitecore 10.4][1]. These templates install a full headless stack with the latest cumulative hotfixes[^1].

## ⭐ Packages Installed

| Package | URL |
| ------- | --- |
| Sitecore 10.4 | <https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/104/Sitecore_Experience_Platform_104> |
| Sitecore Identity Server 9.0.7 | <https://developers.sitecore.com/downloads/Sitecore_Identity/9x/Sitecore_Identity_Server_9007> |
| Sitecore Experience Accelerator 10.4.0 | <https://developers.sitecore.com/downloads/Sitecore_Experience_Accelerator/10x/Sitecore_Experience_Accelerator_1040> |
| Sitecore Headless Rendering 22.0.0 | <https://developers.sitecore.com/downloads/Sitecore_Headless_Rendering/22x/Sitecore_Headless_Rendering_2200> |
| Sitecore Management Services 5.2.129 | <https://developers.sitecore.com/downloads/Sitecore_CLI/7x/Sitecore_CLI_7024> |
| Sitecore PowerShell Extensions 8.0 | <https://github.com/SitecorePowerShell/Console/releases/download/8.0/Sitecore.PowerShell.Extensions-8.0-IAR.scwdp.zip> |
| Cumulative hotfix for Sitecore XP 10.4[^1] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003424> |
| Cumulative hotfix for SXA 10.4.0[^1] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003459> |
| Cumulative hotfixes for Sitecore Headless Rendering 22[^1] | <https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1003203> |

## 📦 Required Files and Packages

1. Unzip [Sitecore Azure Toolkit 3.0.0][2] into the [`./lib/sat`](./lib/sat/) folder.
2. Place the following packages into the [`./packages`](./packages/) folder:
   - `license.xml`
   - `Sitecore 10.4.0 rev. 010422 (XM) (OnPrem)_cm.scwdp.zip` (extract from _Packages for XM Scaled_ for _On Premises deployment_)
   - `Sitecore Experience Accelerator XM 10.4.0 rev. 08675.scwdp.zip`
   - `Sitecore Headless Services Server XM 22.0.11.scwdp.zip`
   - `Sitecore.IdentityServer.9.0.7.scwdp.zip` (_Sitecore Identity Server WDP_ for _On-premises deployments_)
   - `Sitecore.IdentityServer.UpgradeScripts.9.0.zip` (_Identity Server Upgrade Script_ for _On-premises deployments_)
   - `Sitecore.ManagementServices 5.2.129.scwdp.zip`
   - `Sitecore.PowerShell.Extensions-8.0-IAR.scwdp.zip`
   - `Sitecore 10.4.2 rev. 014339 PRE (XM) (OnPrem)_cm.cumulative.delta.scwdp.zip`[^1] (extract from `Sitecore 10.4.2 rev. 014339 (CUMULATIVE DELTA WDP XM1 packages).zip`)
   - `Sitecore.IdentityServer 8.0 rev. 37 (OnPrem)_identityserver.cumulative.delta.scwdp.zip`[^1] (extract from `Sitecore 10.4.2 rev. 014339 (CUMULATIVE DELTA WDP XM1 packages).zip`)
   - `SC Hotfix-PDXP-22057-1 JSS 22.0.0.zip` (Cumulative hotfixes for Sitecore Headless Rendering 22)
   - `SC Hotfix-PDXP-22153-1 GraphQL 8.0.0.zip` (Cumulative hotfixes for Sitecore Headless Rendering 22)
   - `SC Hotfix-PDXP-25202-1 Layout Service 10.0.6.zip` (Cumulative hotfixes for Sitecore Headless Rendering 22)
   - `SC Hotfix SXA-9041-2 10.4.0 rev. 08675.zip` (Cumulative hotfix for SXA 10.4.0)

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
7. Install Sitecore cumulative hotfixes with `XM0-SingleDeveloper.ps1 -Update`.

## 🚮 Uninstall

1. Uninstall Sitecore with `XM0-SingleDeveloper.ps1 -Uninstall`.
2. Uninstall Solr with `Solr-SingleDeveloper.ps1 -Uninstall`.

[^1]: Sitecore Support releases new versions of cumulative hotfixes on a regular basis. When they publish a new version, the old versions are removed from their downloads. The cumulative hotfix versions listed here may not reflect the most recent version. If the currently available version does not work with these templates, please open an issue.

[1]: https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/104/Sitecore_Experience_Platform_104
[2]: https://developers.sitecore.com/downloads/Sitecore_Azure_Toolkit/3x/Sitecore_Azure_Toolkit_300
