using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;
using WoWPal.Utilities;

namespace WoWPal.Handlers
{
    public static class InputHandler
    {
        [DllImport("user32.dll")]
        public static extern bool SetCursorPos(int X, int Y);

        [DllImport("user32.dll")]
        public static extern void mouse_event(int dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);

        private static readonly int MOUSEEVENTF_LEFTDOWN = 0x02;

        private static readonly int MOUSEEVENTF_LEFTUP = 0x04;

        private static readonly int MOUSEEVENTF_RIGHTDOWN = 0x08;

        private static readonly int MOUSEEVENTF_RIGHTUP = 0x10;

        private static readonly int MOUSEEVENTF_MIDDLEDOWN = 0x20;

        private static readonly int MOUSEEVENTF_MIDDLEUP = 0x40;

        public static bool IsRightButtonDown = false;

        public static void LeftMouseDown(int xPos, int yPos)
        {
            mouse_event(MOUSEEVENTF_LEFTDOWN, xPos, yPos, 0, 0);
        }

        public static void LeftMouseUp(int xPos, int yPos)
        {
            mouse_event(MOUSEEVENTF_LEFTUP, xPos, yPos, 0, 0);
        }

        public static void RightMouseDown(int xPos, int yPos)
        {
            mouse_event(MOUSEEVENTF_RIGHTDOWN, xPos, yPos, 0, 0);
            IsRightButtonDown = true;
        }

        public static void RightMouseUp(int xPos, int yPos)
        {
            mouse_event(MOUSEEVENTF_RIGHTUP, xPos, yPos, 0, 0);
            IsRightButtonDown = false;
        }

        public static void MiddleMouseDown(int xPos, int yPos)
        {
            mouse_event(MOUSEEVENTF_MIDDLEDOWN, xPos, yPos, 0, 0);
        }

        public static void MiddleMouseUp(int xPos, int yPos)
        {
            mouse_event(MOUSEEVENTF_MIDDLEUP, xPos, yPos, 0, 0);
        }

        public static Vector3 CenterMouse()
        {
            Thread.Sleep(100);
            var screenBounds = Screen.PrimaryScreen.Bounds;
            var mousePos = new Vector3(screenBounds.Width / 2, screenBounds.Height / 2, 0);
            SetCursorPos((int)mousePos.X, (int)mousePos.Y);
            Thread.Sleep(100);
            return mousePos;
        }
    }
}
