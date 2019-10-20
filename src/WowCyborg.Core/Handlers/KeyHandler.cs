using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

namespace WowCyborg.Core.Handlers
{
    public class KeyHandler
    {
        [DllImport("user32.dll")]
        public static extern IntPtr SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);

        private const int WM_KEYDOWN = 0x100;

        private const int WM_KEYUP = 0x101;

        private IList<Keys> _keydowns = new List<Keys>();

        private IntPtr _hWnd;

        public KeyHandler(IntPtr hWnd)
        {
            _hWnd = hWnd;
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
                if (!_keydowns.Contains(key))
                {
                    _keydowns.Add(key);
                }

                SendMessage(_hWnd, WM_KEYUP, Convert.ToInt32(key), 0);
                SendMessage(_hWnd, WM_KEYDOWN, Convert.ToInt32(key), 0);
            }
            catch(Exception ex)
            {
                SendMessage(_hWnd, WM_KEYUP, Convert.ToInt32(key), 0);
                Console.WriteLine("Could not hold key");
                Console.WriteLine(ex.Message);
            }
        }

        public void ReleaseKey(Keys key)
        {
            try
            {
                if (_keydowns.Contains(key))
                {
                    _keydowns.Remove(key);
                }

                SendMessage(_hWnd, WM_KEYUP, Convert.ToInt32(key), 0);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Could not release key");
                Console.WriteLine(ex.Message);
            }
        }

        public void ModifiedKeypress(Keys modifier, Keys key)
        {
            try
            {
                SendMessage(_hWnd, WM_KEYUP, Convert.ToInt32(key), 0);
                SendMessage(_hWnd, WM_KEYUP, Convert.ToInt32(modifier), 0);

                SendMessage(_hWnd, WM_KEYDOWN, Convert.ToInt32(modifier), 0);
                Thread.Sleep(150);
                SendMessage(_hWnd, WM_KEYDOWN, Convert.ToInt32(key), 0);
                Thread.Sleep(150);

                SendMessage(_hWnd, WM_KEYUP, Convert.ToInt32(key), 0);
                SendMessage(_hWnd, WM_KEYUP, Convert.ToInt32(modifier), 0);
            }
            catch
            {
                Console.WriteLine("Could not press Modified key combination");
            }
        }
    }
}
