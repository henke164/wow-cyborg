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

            if (processes.Length == 0)
            {
                return;
            }

            var windowWidth = (int)((Screen.PrimaryScreen.Bounds.Width / (processes.Length)) * 1.4);
            SetWindowSizeAndPosition(processes, windowWidth);
        }

        private void SetWindowSizeAndPosition(Process[] processes, int width)
        {
            var height = (int)(width * 0.75);
            var left = 0;
            var index = 0;
            for (var x = 0; x < processes.Length / 2; x++)
            {
                for (var i = 0; i < processes.Length / 2; i++)
                {
                    var process = processes[index++];
                    var rectangle = new Rectangle(left * width, x * height, width, height);

                    MoveWindow(
                        process.MainWindowHandle,
                        rectangle.X,
                        rectangle.Y,
                        rectangle.Width,
                        rectangle.Height,
                        true);

                    GameWindows.Add(new GameWindow
                    {
                        GameProcess = process,
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
}
