using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace WoWPal.Utilities
{
    public static class GameWindowUtilities
    {
        [DllImport("user32.dll", CharSet = CharSet.Auto, ExactSpelling = true)]
        private static extern IntPtr GetForegroundWindow();

        private static Process GameProcess;
        
        public static bool IsForeground()
        {
            if (GameProcess == null)
            {
                GameProcess = Process.GetProcessesByName("WoW")[0];
            }

            return GetForegroundWindow() == GameProcess.MainWindowHandle;
        }
    }
}
