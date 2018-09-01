using System.Runtime.InteropServices;

namespace WoWPal.Handlers
{
    public static class InputHandler
    {
        [DllImport("user32.dll")]
        public static extern bool SetCursorPos(int X, int Y);

        [DllImport("user32.dll")]
        public static extern void mouse_event(int dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);

        private static readonly int MOUSEEVENTF_RIGHTDOWN = 0x08;

        private static readonly int MOUSEEVENTF_RIGHTUP = 0x10;

        public static void RightMouseDown(int xPos, int yPos)
        {
            mouse_event(MOUSEEVENTF_RIGHTDOWN, xPos, yPos, 0, 0);
        }

        public static void RightMouseUp(int xPos, int yPos)
        {
            mouse_event(MOUSEEVENTF_RIGHTUP, xPos, yPos, 0, 0);
        }
    }
}
