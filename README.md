# 🏗️ XM0 Templates for Sitecore Installation Framework

This repository provides XM Single (XM0) [Sitecore Installation Framework (SIF)][1] templates for all versions of Sitecore from [9.0 Initial Release][2] through [Sitecore 10.5][3].

XM0 is the most lightweight Sitecore configuration. Sitecore has provided XP Single (XP0) and XM Scaled (XM1) SIF templates for all versions of Sitecore since [9.0 Initial Release][2], but has never offered XM0 SIF templates. The templates in this repository fill that gap.

## 🌠 Features

Each XM0 template installs a fully updated headless stack with [Sitecore Experience Accelerator (SXA)][4], [Headless Services][5] (or [JavaScript Services][6]), [Sitecore PowerShell Extensions (SPE)][7], and [Sitecore Management Services][8] (for versions that support it). Module versions for each template have been selected based on the published module compatibility tables:

- [Sitecore modules compatibility table for Sitecore XP 7.5—9.3][9]
- [Sitecore modules compatibility table for Sitecore XP 10.0 and later versions][10]
- [Sitecore PowerShell Extensions Compatibility Table][11]

The templates install the latest version of each publicly available cumulative hotfix and module hotfix that are compatible with each Sitecore version.

The templates pack several quality-of-life improvements not found in the XP0 and XM1 templates offered by Sitecore:

- **Tidy logs**: The install script writes logs to a logs folder rather than littering up the install root.
- **Package validation**: `Validate-Packages.ps1` validates that you've got all the right packages downloaded for the install.
- **No unnecessary Solr cores**: The templates only create the Solr cores necessary for XM, unlike Sitecore's XM1 templates that create all the Solr cores required for XP.
- **No performance counter errors**: The App Pool user is granted permissions to read performance counters so the Sitecore logs aren't flooded with performance counter errors.
- **SIF certificates valid with Node.js**: The templates add the SIF root certificate to `NODE_EXTRA_CA_CERTS`, so no `UNABLE_TO_VERIFY_LEAF_SIGNATURE` errors when your head app connects to Sitecore; no need to set `NODE_TLS_REJECT_UNAUTHORIZED=0`.
- **Packages enabled in Sitecore 10.5**: Sitecore disables packages by default in 10.5. The templates for 10.5 undo that.
- **Automated hotfix package installs**: The templates install Sitecore (module) hotfixes by converting them into SCWDPs with the [Sitecore Azure Toolkit][12].
- **Automated update package installs**: The templates install hotfixes that were provided as `.update` packages.

## 🕸️ Dependencies

> [!IMPORTANT]
> All templates in this repository are built and tested to work with [SIF 2.4.1][13]. Earlier versions of SIF are not supported and may not work as expected.

## 🚀 Usage

Grab the XM0 templates you need from [Releases][14] or the [`src/`](src/) folder. Follow the instructions in each template's `README.md`.

These templates are meant to be a starter kit for your own Sitecore install repository. Remove what you don't need; install different patches as necessary; and draw inspiration from the patterns in these templates.

Your local Sitecore install should match your production Sitecore instance as closely as possible. Use these templates as a starting point to automate a local install of everything you have in production--support patches, other modules (e.g., [Sitecore Stream][15], [Sitecore Publishing Service][16]). It can and should all be automated.

> [!WARNING]
> When building a Sitecore install repository, it is imperative that you keep your own copies of Sitecore's packages. Sitecore regularly publishes new versions of cumulative hotfixes and updates. When they do this, they delete the old versions. Do not assume that any package required for your install will always be readily available online.

## 🆙 Maintenance and Updates

Sitecore regularly releases updates to modules and cumulative hotfixes. I plan to perform a scan of the templates every quarter and update the templates to the latest version accordingly.

Cumulative hotfixes to Sitecore and its modules are tricky because Sitecore releases new versions of the hotfixes on a regular basis. When they release new hotfix versions, they always delete the previous version, and they often introduce breaking changes. As a result, I can only support the latest version of cumulative hotfixes that are publicly available with these templates.

## ⚠️ Disclaimer

This project is a community effort and is not affiliated with, endorsed by, or supported by Sitecore. "Sitecore" is a registered trademark of Sitecore Corporation A/S.

Portions of the templates in this repository are derived from the official SIF configuration files published by Sitecore, which remain © Sitecore Corporation A/S. You must have a valid Sitecore license and download the official installation packages from the [Sitecore Developer Portal][17] to use these templates. I cannot and will not provide a license or any packages for use with these templates.

Everything is provided "as is", without warranty of any kind. Use at your own risk.

[1]: https://developers.sitecore.com/downloads/Sitecore_Installation_Framework
[2]: https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/90/Sitecore_Experience_Platform_90_Initial_Release
[3]: https://developers.sitecore.com/downloads/Sitecore_Experience_Platform/105/Sitecore_Experience_Platform_105
[4]: https://developers.sitecore.com/downloads/Sitecore_Experience_Accelerator
[5]: https://developers.sitecore.com/downloads/Sitecore_Headless_Rendering
[6]: https://developers.sitecore.com/downloads/Sitecore_JavaScript_Services
[7]: https://doc.sitecorepowershell.com/
[8]: https://developers.sitecore.com/downloads/Sitecore_CLI
[9]: https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB0541788
[10]: https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1000576
[11]: https://doc.sitecorepowershell.com/appendix
[12]: https://developers.sitecore.com/downloads/Sitecore_Azure_Toolkit/3x/Sitecore_Azure_Toolkit_300
[13]: https://developers.sitecore.com/downloads/Sitecore_Installation_Framework/2x/Sitecore_Installation_Framework_241
[14]: https://github.com/coreyasmith/sitecore-installation-framework-xm0-templates/releases
[15]: https://developers.sitecore.com/downloads/Sitecore_Stream_for_Platform_DXP
[16]: https://developers.sitecore.com/downloads/Sitecore_Publishing_Service_Module
[17]: https://developers.sitecore.com/downloads
