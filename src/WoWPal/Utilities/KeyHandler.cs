﻿using System;
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

        [DllImport("user32.dll", CharSet = CharSet.Auto, ExactSpelling = true)]
        public static extern IntPtr GetForegroundWindow();

        private static Process GameProcess;

        public const int KEYEVENTF_EXTENDEDKEY = 0x0001; //Key down flag
        public const int KEYEVENTF_KEYUP = 0x0002; //Key up flag

        private static IList<Keys> _keydowns = new List<Keys>();

        public static void PressKey(Keys key, int holdMs = 0)
        {
            if (!IsForeground())
            {
                return;
            }
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

                if (!IsForeground())
                {
                    return;
                }
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
            try
            {
                if (_keydowns.Contains(key))
                {
                    if (!IsForeground())
                    {
                        return;
                    }

                    keybd_event((byte)key, 0, KEYEVENTF_KEYUP, 0);
                    _keydowns.Remove(key);
                }
            }
            catch
            {
                Console.WriteLine("Could not hold key");
            }

        }

        private static bool IsForeground()
        {
            if (GameProcess == null)
            {
                GameProcess = Process.GetProcessesByName("WoW")[0];
            }

            return GetForegroundWindow() == GameProcess.MainWindowHandle;
        }
    }
}
