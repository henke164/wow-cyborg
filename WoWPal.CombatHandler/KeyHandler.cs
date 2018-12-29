using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace WoWPal.CombatHandler
{
    public class KeyHandler
    {
        [DllImport("USER32.DLL")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);

        private static Process GameProcess;

        public KeyHandler()
        {
            if (GameProcess == null)
            {
                try
                {
                    GameProcess = Process.GetProcessesByName("WoW")[0];
                }
                catch
                {

                }
            }
        }

        public void PressKey(string key)
        {
            if (GameProcess == null)
            {
                return;
            }

            SetForegroundWindow(GameProcess.MainWindowHandle);
            SendKeys.SendWait(key);
        }
    }
}
