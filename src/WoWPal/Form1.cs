using System.IO;
using System.Windows.Forms;
using CefSharp;
using CefSharp.WinForms;

namespace WoWPal
{
    public partial class Form1 : Form
    {
        private CharacterController _controller;

        public Form1()
        {
            InitializeComponent();
            
            CefSharpSettings.LegacyJavascriptBindingEnabled = true;
            Cef.Initialize(new CefSettings());

            var browser = new ChromiumWebBrowser("")
            {
                Dock = DockStyle.Fill
            };
            
            panel1.Controls.Add(browser);

            _controller = new CharacterController(browser);
        }

        private void Form1_Load(object sender, System.EventArgs e)
        {
            this.Location = new System.Drawing.Point(500, 1);
        }
    }
}
