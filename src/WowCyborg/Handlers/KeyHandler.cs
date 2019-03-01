using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

namespace WowCyborg.Handlers
{
    public class KeyHandler
    {
        [DllImport("User32.dll")]
        private static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindows);

        [DllImport("user32.dll")]
        private static extern bool PostMessage(IntPtr hWnd, UInt32 Msg, Int32 wParam, Int32 lParam);

        static uint WM_KEYDOWN = 0x100;

        static uint WM_KEYUP = 0x101;

        private static IntPtr _gameHandle = IntPtr.Zero;

        private static IList<Keys> _keydowns = new List<Keys>();

        public KeyHandler(IntPtr gameHandle)
        {
            _gameHandle = gameHandle;
        }

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
                PostMessage(_gameHandle, WM_KEYUP, (int)Keys.LControlKey, 0);
                PostMessage(_gameHandle, WM_KEYUP, (int)Keys.LShiftKey, 0);
                PostMessage(_gameHandle, WM_KEYUP, (int)Keys.Alt, 0);
                PostMessage(_gameHandle, WM_KEYUP, (int)key, 0);
                PostMessage(_gameHandle, WM_KEYDOWN, (int)key, 0);
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
                PostMessage(_gameHandle, WM_KEYUP, (int)key, 0);
            }
            catch
            {
                Console.WriteLine("Could not release key");
            }
        }

        public void ModifiedKeypress(Keys modifier, Keys key)
        {
            try
            {
                PostMessage(_gameHandle, WM_KEYUP, (int)key, 0);
                PostMessage(_gameHandle, WM_KEYUP, (int)modifier, 0);

                PostMessage(_gameHandle, WM_KEYDOWN, (int)modifier, 0);
                Thread.Sleep(50);
                PostMessage(_gameHandle, WM_KEYDOWN, (int)key, 0);
                Thread.Sleep(150);

                PostMessage(_gameHandle, WM_KEYUP, (int)key, 0);
                PostMessage(_gameHandle, WM_KEYUP, (int)modifier, 0);
            }
            catch
            {
                Console.WriteLine("Could not press Modified key combination");
            }
        }
    }
}
