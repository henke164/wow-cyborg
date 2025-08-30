using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace WowCyborg.UI
{
    internal static class Program
    {
        [DllImport("User32.dll")]
        public static extern int SetForegroundWindow(IntPtr point);

        [DllImport("user32.dll")]
        public static extern int GetWindowRect(IntPtr hwnd, out Rectangle rect);

        static Form1 Form;
        public static string AddonSourcePath = "./MazonAddon";
        public static int AddonColumnCount = 4;
        public static int AddonRowCount = 6;

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Form = new Form1();
            Application.Run(Form);
        }

        public static void Log(string str)
        {
            if (Form != null)
            {
                Form.WriteLog(str);
            }
        }
    }
}
