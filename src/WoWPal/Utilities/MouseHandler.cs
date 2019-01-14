using System;
using System.Runtime.InteropServices;
using System.Threading;

namespace WoWPal.Utilities
{
    public static class MouseHandler
    {
        private enum MouseEventFlags
        {
            LeftDown = 0x00000002,
            LeftUp = 0x00000004,
            MiddleDown = 0x00000020,
            MiddleUp = 0x00000040,
            Move = 0x00000001,
            Absolute = 0x00008000,
            RightDown = 0x00000008,
            RightUp = 0x00000010
        }

        [DllImport("user32.dll", EntryPoint = "SetCursorPos")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool SetCursorPos(int x, int y);
        
        [DllImport("user32.dll")]
        private static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);

        public static void LeftClick(int x, int y)
        {
            SetCursorPos(x, y);

            Thread.Sleep(200);

            mouse_event((int)MouseEventFlags.LeftDown, x, y, 0, 0);

            Thread.Sleep(100);

            mouse_event((int)MouseEventFlags.LeftUp, x, y, 0, 0);

            Thread.Sleep(200);
        }


        public static void RightClick(int x, int y)
        {
            SetCursorPos(x, y);

            Thread.Sleep(200);

            mouse_event((int)MouseEventFlags.RightDown, x, y, 0, 0);

            Thread.Sleep(100);

            mouse_event((int)MouseEventFlags.RightUp, x, y, 0, 0);

            Thread.Sleep(200);
        }
    }
}
