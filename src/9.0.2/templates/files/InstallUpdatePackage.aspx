<%@ Page Language="C#" Inherits="Sitecore.sitecore.admin.AdminPage" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    /*
      Installs a Sitecore update package (.update) with the same engine the Update Installation
      Wizard drives (Sitecore.Update.dll). Update packages whose changeditems/deleteditems stores
      hold item delta commands cannot be converted to Web Deploy packages (the Sitecore Azure
      Toolkit silently drops those commands), so this page installs them through the engine
      directly instead of the wizard UI.

      Usage (requires an authenticated administrator):
          InstallUpdatePackage.aspx?package=<filename>

      <filename> names a .update file in App_Data\packages (a file name, not a path). The installer's
      messages are echoed to the response; any Error-level message fails the request (HTTP 500).

      The package replaces assemblies in bin, which would normally recycle the app domain
      mid-request; ShutdownGuard -- the wizard's own safeguard -- postpones the shutdown until
      the installation has finished. The app domain recycles once the response completes.
    */

    private readonly System.Text.StringBuilder _log = new System.Text.StringBuilder();
    private bool _failed;

    protected void Page_Load(object sender, EventArgs e)
    {
        CheckSecurity();
        Server.ScriptTimeout = 3600;

        var name = Request.QueryString["package"];
        if (string.IsNullOrEmpty(name) || name != Path.GetFileName(name) || !name.EndsWith(".update", StringComparison.OrdinalIgnoreCase))
        {
            Fail("Usage: InstallUpdatePackage.aspx?package=<filename> -- the name of a .update file in App_Data\\packages.");
        }
        else
        {
            var path = Path.Combine(Sitecore.IO.FileUtil.MapPath("/App_Data/packages"), name);
            if (!File.Exists(path))
            {
                Fail("file not found: " + path);
            }
            else
            {
                try
                {
                    InstallUpdatePackage(path);
                }
                catch (Exception ex)
                {
                    Fail(name + ": " + ex);
                }
            }
        }

        Response.TrySkipIisCustomErrors = true;
        Response.StatusCode = _failed ? 500 : 200;
        Response.ContentType = "text/html";
        Response.Write("<pre>" + Server.HtmlEncode(_log.ToString()) + "</pre>");
    }

    private void InstallUpdatePackage(string path)
    {
        var log = log4net.LogManager.GetLogger("root");
        using (new Sitecore.Update.Installer.Installer.Utils.ShutdownGuard())
        {
            var installationInfo = new Sitecore.Update.PackageInstallationInfo
            {
                Action = Sitecore.Update.Installer.Utils.UpgradeAction.Upgrade,
                Mode = Sitecore.Update.Utils.InstallMode.Install,
                ProcessingMode = Sitecore.Update.Utils.ProcessingMode.All,
                Path = path
            };

            string historyPath;
            var entries = Sitecore.Update.UpdateHelper.Install(installationInfo, log, out historyPath);

            // The wizard executes the package's post-installation instructions (post steps and
            // configuration file merges) as a separate step after the diff install; do the same.
            var metadata = Sitecore.Update.UpdateHelper.LoadMetadata(path);
            var installer = new Sitecore.Update.Installer.DiffInstaller(installationInfo.Action);
            installer.ExecutePostInstallationInstructions(path, historyPath, installationInfo.Mode, metadata, log, ref entries);
            Sitecore.Update.UpdateHelper.SaveInstallationMessages(entries, historyPath);

            foreach (var entry in entries)
            {
                _log.AppendLine(entry.Level + " [" + entry.Database + "] " + entry.Action + ": " + entry.ShortDescription);
                if (entry.Level == Sitecore.Update.Installer.ContingencyLevel.Error)
                {
                    _failed = true;
                }
            }
            _log.AppendLine("Installed '" + Path.GetFileName(path) + "' with " + entries.Count + " message(s). History: " + historyPath);
        }
    }

    private void Fail(string message)
    {
        _failed = true;
        _log.AppendLine("ERROR " + message);
    }
</script>
