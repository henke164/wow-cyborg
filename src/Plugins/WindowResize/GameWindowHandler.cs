using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using WindowResize.Models;

namespace WindowResize
{
    public class GameWindowHandler
    {
        public IList<GameWindow> GameWindows { get; private set; }

        [DllImport("user32.dll", SetLastError = true)]
        internal static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

        public void ReinitializeGameWindows()
        {
            GameWindows = new List<GameWindow>();
            var processes = Process.GetProcessesByName("wow");
            if (processes.Length == 0)
            {
                processes = Process.GetProcessesByName("WowClassic");
            }

            var windowWidth = Screen.PrimaryScreen.Bounds.Width / processes.Length;
            SetWindowSizeAndPosition(processes, windowWidth);
        }

        private void SetWindowSizeAndPosition(Process[] processes, int width)
        {
            var height = (int)(width * 0.75);
            var left = 0;
            for (var i = 0; i < processes.Length; i++)
            {
                var rectangle = new Rectangle(left * width, 0, width, height);

                MoveWindow(
                    processes[i].MainWindowHandle,
                    rectangle.X,
                    rectangle.Y,
                    rectangle.Width,
                    rectangle.Height,
                    true);

                GameWindows.Add(new GameWindow
                {
                    GameProcess = processes[i],
                    WindowRectangle = rectangle
                });

                if (left == 1)
                {
                    left = 0;
                }
                else
                {
                    left++;
                }
            }
        }
    }
}
