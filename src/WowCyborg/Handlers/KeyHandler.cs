using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

namespace WowCyborg.Handlers
{
    public class KeyHandler
    {
        [DllImport("user32.dll")]
        public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, uint dwExtraInfo);

        public const int KEYEVENTF_EXTENDEDKEY = 0x0001; //Key down flag
        public const int KEYEVENTF_KEYUP = 0x0002; //Key up flag

        private IList<Keys> _keydowns = new List<Keys>();

        public void PressKey(Keys key, int holdMs = 0)
        {
            HoldKey(key);
            Thread.Sleep(holdMs);
            ReleaseKey(key);
        }

        public void HoldKey(Keys key)
        {
            try
            {
                if (!GameWindowUtilities.IsForeground())
                {
                    return;
                }

                if (!_keydowns.Contains(key))
                {
                    _keydowns.Add(key);
                }

                keybd_event((byte)key, 0, KEYEVENTF_KEYUP, 0);
                keybd_event((byte)key, 0, KEYEVENTF_EXTENDEDKEY, 0);
            }
            catch
            {
                Console.WriteLine("Could not hold key");
            }
        }

        public void ReleaseKey(Keys key)
        {
            try
            {
                if (_keydowns.Contains(key))
                {
                    keybd_event((byte)key, 0, KEYEVENTF_KEYUP, 0);
                    _keydowns.Remove(key);
                }
            }
            catch
            {
                Console.WriteLine("Could not release key");
            }
        }

        public void ModifiedKeypress(Keys modifier, Keys key)
        {
            if (!GameWindowUtilities.IsForeground())
            {
                return;
            }

            try
            {
                keybd_event((byte)key, 0, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, 0);
                keybd_event((byte)modifier, 0, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, 0);

                keybd_event((byte)modifier, 0, KEYEVENTF_EXTENDEDKEY, 0);
                Thread.Sleep(50);
                keybd_event((byte)key, 0, KEYEVENTF_EXTENDEDKEY, 0);
                Thread.Sleep(150);

                keybd_event((byte)key, 0, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, 0);
                keybd_event((byte)modifier, 0, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, 0);
            }
            catch
            {
                Console.WriteLine("Could not press Modified key combination");
            }
        }
    }
}
