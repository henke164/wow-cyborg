using System;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using WowCyborg.Models;
using WowCyborg.Utilities;

namespace WowCyborg.Handlers
{
    public static class AddonLocator
    {
        [DllImport("user32.dll")]
        private static extern int GetWindowRect(IntPtr hwnd, out Rectangle rect);

        [DllImport("user32.dll")]
        private static extern bool SetForegroundWindow(IntPtr hWnd);

        private static Rectangle InGameAddonLocation;

        private static IntPtr GameHandle;

        public static void InitializeGameHandle()
        {
            var gameHandle = SetupGameHandle();
            GameHandle = gameHandle;
            SetForegroundWindow(gameHandle);
        }

        private static IntPtr GetGameHandle()
        {
            if (!GameHandle.Equals(IntPtr.Zero))
            {
                return GameHandle;
            }

            var game = Process.GetProcessesByName("Wow")[0];
            return game.MainWindowHandle;
        }

        public static Rectangle GetAddonLocation()
        {
            if (InGameAddonLocation == Rectangle.Empty)
            {
                ReCalculateAddonPosition();
            }

            return InGameAddonLocation;
        }

        public static void ReCalculateAddonPosition()
        {
            try
            {
                Rectangle rect;
                GetWindowRect(GetGameHandle(), out rect);
                rect.Width -= rect.X;
                rect.Height -= rect.Y;

                Bitmap clone;
                var bounds = Screen.GetBounds(Point.Empty);
                var bottomLeft = new Rectangle(rect.X, rect.Y + rect.Height - 100, 400, 100);

                using (var bitmap = new Bitmap(bounds.Width, bounds.Height))
                {
                    using (var g = Graphics.FromImage(bitmap))
                    {
                        g.CopyFromScreen(Point.Empty, Point.Empty, bounds.Size);
                    }
                    clone = bitmap.Clone(bottomLeft, PixelFormat.Format24bppRgb);
                }

                var pxOffset = bottomLeft.X > 0 ? 9 : 1;

                var frameSize = CalculateFrameWidth(clone, pxOffset);

                var settings = SettingsLoader.LoadSettings<AppSettings>("settings.json");

                InGameAddonLocation = new Rectangle(
                    bottomLeft.X + pxOffset,
                    bottomLeft.Y + bottomLeft.Height - pxOffset - frameSize * settings.AddonRowCount,
                    frameSize * settings.AddonColumnCount,
                    frameSize * settings.AddonRowCount);

                if (InGameAddonLocation.Height == 0 || InGameAddonLocation.Width == 0)
                {
                    InGameAddonLocation = new Rectangle(1, 1, 1, 1);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Could not locate addon on screen.");
                InGameAddonLocation = new Rectangle(1, 1, 1, 1);
            }
        }

        private static int CalculateFrameWidth(Bitmap b, int pxOffset)
        {
            var width = 0;
            Color firstPixel = Color.White;

            for (var x = 0; x < b.Width; x++)
            {
                var nextPixel = b.GetPixel(x + pxOffset, b.Height - pxOffset);
                if (firstPixel == Color.White)
                {
                    firstPixel = nextPixel;
                    continue;
                }

                if (firstPixel != nextPixel)
                {
                    width = x;
                    break;
                }
            }
            return width / 4;
        }


        static IntPtr SetupGameHandle()
        {
            var processes = Process.GetProcessesByName("Wow");
            if (processes.Length == 1)
            {
                return processes[0].MainWindowHandle;
            }

            if (processes.Length > 1)
            {
                Console.WriteLine("Select process");
                for (var x = 0; x < processes.Length; x++)
                {
                    Console.WriteLine($"{x}. {processes[x].MainWindowTitle} ({processes[x].Id})");
                }
                var index = int.Parse(Console.ReadLine());
                return processes[index].MainWindowHandle;
            }

            return IntPtr.Zero;
        }
    }
}
