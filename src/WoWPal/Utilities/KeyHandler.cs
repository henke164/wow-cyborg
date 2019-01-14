using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

namespace WoWPal.Utilities
{
    public static class KeyHandler
    {
        [DllImport("user32.dll")]
        public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, uint dwExtraInfo);

        [DllImport("USER32.DLL")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);

        private static Process GameProcess;

        public const int KEYEVENTF_EXTENDEDKEY = 0x0001; //Key down flag
        public const int KEYEVENTF_KEYUP = 0x0002; //Key up flag

        private static IList<Keys> _keydowns = new List<Keys>();

        public static void PressKey(Keys key, int holdMs = 0)
        {
            SetForeground();
            HoldKey(key);
            Thread.Sleep(holdMs);
            ReleaseKey(key);
        }

        public static void HoldKey(Keys key)
        {
            try
            {
                if (!_keydowns.Contains(key))
                {
                    _keydowns.Add(key);
                }

                SetForeground();
                keybd_event((byte)key, 0, KEYEVENTF_KEYUP, 0);
                keybd_event((byte)key, 0, KEYEVENTF_EXTENDEDKEY, 0);
            }
            catch
            {
                Console.WriteLine("Could not hold key");
            }
        }

        public static void ReleaseKey(Keys key)
        {
            if (_keydowns.Contains(key))
            {
                SetForeground();
                keybd_event((byte)key, 0, KEYEVENTF_KEYUP, 0);
                try
                {
                    _keydowns.Remove(key);
                }
                catch
                {
                }
            }
        }

        private static void SetForeground()
        {
            if (GameProcess == null)
            {
                GameProcess = Process.GetProcessesByName("WoW")[0];
            }

            SetForegroundWindow(GameProcess.MainWindowHandle);
        }
    }
}
