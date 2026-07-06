<%@ Page Language="C#" Inherits="Sitecore.sitecore.admin.AdminPage" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq" %>

<script runat="server">
    /*
      Runs module post steps from App_Data\poststeps, which Web Deploy installs leave behind:
      the Sitecore Azure Toolkit conversion writes each package's post step class name to
      <package>.poststep but discards the package's PostStep attributes, and only the Azure
      Bootloader add-on ever executes the folder -- on premises nothing does.

      Usage (requires an authenticated administrator):
          RunPostSteps.aspx?poststeps=<name>[,<name>...][&<name>.attributes=key={value};key2=value2]

      Each <name> refers to App_Data\poststeps\<name>.poststep. The optional <name>.attributes
      value restores the attributes the conversion dropped, in the same key=value;key=value
      format the package installer uses.

      SPE's post step (Spe.Integrations.Install.ScriptPostStep) cannot run as shipped outside
      the package installation wizard -- it only opens a wizard dialog for the script named by
      the scriptId attribute -- so it is fulfilled per that contract instead: the script item is
      executed with SPE's own script engine.
    */

    private readonly System.Text.StringBuilder _log = new System.Text.StringBuilder();
    private bool _failed;

    protected void Page_Load(object sender, EventArgs e)
    {
        CheckSecurity();

        var requested = Request.QueryString["poststeps"];
        if (string.IsNullOrEmpty(requested))
        {
            _failed = true;
            _log.AppendLine("Usage: RunPostSteps.aspx?poststeps=<name>[,<name>...][&<name>.attributes=key={value}]");
        }
        else
        {
            var folder = Sitecore.IO.FileUtil.MapPath("/App_Data/poststeps");
            foreach (var name in requested.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(n => n.Trim()))
            {
                try
                {
                    RunPostStep(folder, name, Request.QueryString[name + ".attributes"]);
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

    private void RunPostStep(string folder, string name, string attributes)
    {
        var file = Path.Combine(folder, name + ".poststep");
        if (!File.Exists(file))
        {
            Fail(name + ": file not found: " + file);
            return;
        }

        var typeName = File.ReadLines(file).Select(l => l.Trim()).FirstOrDefault(l => l.Length > 0);
        if (string.IsNullOrEmpty(typeName))
        {
            Fail(name + ": post step file is empty.");
            return;
        }

        if (typeName.StartsWith("Spe.Integrations.Install.ScriptPostStep,", StringComparison.OrdinalIgnoreCase))
        {
            RunSpeScriptPostStep(name, attributes);
            return;
        }

        var type = Type.GetType(typeName);
        if (type == null)
        {
            Fail(name + ": cannot load type: " + typeName);
            return;
        }

        var postStep = Activator.CreateInstance(type) as Sitecore.Install.Framework.IPostStep;
        if (postStep == null)
        {
            Fail(name + ": " + typeName + " does not implement IPostStep.");
            return;
        }

        var metaData = new System.Collections.Specialized.NameValueCollection();
        if (!string.IsNullOrEmpty(attributes))
        {
            metaData["Attributes"] = attributes;
        }
        postStep.Run(new HeadlessTaskOutput(_log), metaData);
        _log.AppendLine(name + ": ran " + typeName);
    }

    private void RunSpeScriptPostStep(string name, string attributes)
    {
        string scriptId = null;
        string scriptDb = "master";
        foreach (var pair in (attributes ?? string.Empty).Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries))
        {
            var separator = pair.IndexOf('=');
            if (separator < 1) continue;
            var key = pair.Substring(0, separator).Trim();
            var value = pair.Substring(separator + 1).Trim();
            if (key.Equals("scriptId", StringComparison.OrdinalIgnoreCase)) scriptId = value;
            if (key.Equals("scriptDb", StringComparison.OrdinalIgnoreCase)) scriptDb = value;
        }

        if (string.IsNullOrEmpty(scriptId))
        {
            Fail(name + ": ScriptPostStep requires '" + name + ".attributes=scriptId={...}' -- the SCWDP conversion drops the package attributes, so they must be supplied on the query string.");
            return;
        }

        var scriptItem = Sitecore.Configuration.Factory.GetDatabase(scriptDb).GetItem(Sitecore.Data.ID.Parse(scriptId));
        if (scriptItem == null)
        {
            Fail(name + ": script item " + scriptId + " not found in the " + scriptDb + " database. Has the post step script moved?");
            return;
        }

        // Late-bound so this page compiles on instances without SPE.
        var spe = System.Reflection.Assembly.Load("Spe");
        var sessionManager = spe.GetType("Spe.Core.Host.ScriptSessionManager", true);
        var session = sessionManager.GetMethod("NewSession").Invoke(null, new object[] { "Default", true });
        try
        {
            var execute = session.GetType().GetMethod("ExecuteScriptPart", new[] { typeof(Sitecore.Data.Items.Item), typeof(bool) });
            var output = execute.Invoke(session, new object[] { scriptItem, true }) as System.Collections.IEnumerable;
            if (output != null)
            {
                foreach (var line in output)
                {
                    _log.AppendLine(name + " [script]: " + line);
                }
            }
        }
        finally
        {
            ((IDisposable)session).Dispose();
        }
        _log.AppendLine(name + ": executed script '" + scriptItem.Paths.Path + "' (" + scriptDb + ").");
    }

    private void Fail(string message)
    {
        _failed = true;
        _log.AppendLine("ERROR " + message);
    }

    private class HeadlessTaskOutput : Sitecore.Install.Framework.ITaskOutput
    {
        private readonly System.Text.StringBuilder _log;
        public HeadlessTaskOutput(System.Text.StringBuilder log) { _log = log; }
        public void Execute(System.Threading.ThreadStart task) { task(); }
        public object Execute(Sitecore.Jobs.AsyncUI.Callback callback) { return callback(); }
        public object RunPipeline(Sitecore.Jobs.AsyncUI.PipelineCallback pipeline) { return pipeline(new Sitecore.Web.UI.Sheer.ClientPipelineArgs()); }
        public void Alert(string message) { _log.AppendLine("ALERT: " + message); }
        public string Confirm(string message) { _log.AppendLine("CONFIRM (auto-yes): " + message); return "yes"; }
    }
</script>
