using System;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;

namespace WowCyborg.Core.Handlers
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
                GameProcess = Process.GetProcessesByName("WoW").FirstOrDefault();
                if (GameProcess == null)
                {
                    GameProcess = Process.GetProcessesByName("WoWClassic").FirstOrDefault();
                }

                if (GameProcess == null)
                {
                    return false;
                }
            }

            if (GameProcess.HasExited)
            {
                GameProcess = null;
                return false;
            }

            return GetForegroundWindow() == GameProcess.MainWindowHandle;
        }
    }
}
