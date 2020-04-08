using System;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;
using WowCyborg.Core.Models;
using WowCyborg.Core.Utilities;

namespace WowCyborg.Core.Handlers
{
    public static class AddonLocator
    {
        [DllImport("User32.dll")]
        static extern int SetForegroundWindow(IntPtr point);

        [DllImport("user32.dll")]
        private static extern int GetWindowRect(IntPtr hwnd, out Rectangle rect);

        private static Rectangle InGameAddonLocation;

        private static IntPtr GameHandle;

        public static IntPtr InitializeGameHandle()
        {
            var gameHandle = SetupGameHandle();
            GameHandle = gameHandle;
            return GameHandle;
        }

        private static IntPtr GetGameHandle()
        {
            if (!GameHandle.Equals(IntPtr.Zero))
            {
                return GameHandle;
            }

            var procs = Process.GetProcessesByName("Wow");
            if (procs.Length > 0)
            {
                return procs[0].MainWindowHandle;
            }

            procs = Process.GetProcessesByName("WowClassic");
            return procs[0].MainWindowHandle;
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
                var handle = GetGameHandle();
                GetWindowRect(handle, out rect);
                SetForegroundWindow(handle);
                Thread.Sleep(500);
                rect.Width -= rect.X;
                rect.Height -= rect.Y;
                Bitmap clone;

                var bounds = ScreenUtilities.GetScreenBounds();
                var winBottomLeft = new Point(rect.X, rect.Y + rect.Height);
                var scanArea = new Rectangle(winBottomLeft.X, winBottomLeft.Y - 500, 500, 500);
                using (var bitmap = new Bitmap(bounds.Width, bounds.Height))
                {
                    using (var g = Graphics.FromImage(bitmap))
                    {
                        g.CopyFromScreen(Point.Empty, Point.Empty, bounds.Size);
                    }
                    clone = bitmap.Clone(scanArea, PixelFormat.Format24bppRgb);
                }

                var addonBottomLeft = FindAddonBottomLeft(clone);
                var frameSize = CalculateFrameSize(addonBottomLeft, clone);
                if (frameSize <= 1)
                {
                    Console.WriteLine("Could not locate addon on screen.");
                    InGameAddonLocation = new Rectangle(1, 1, 1, 1);
                    return;
                }

                var settings = SettingsLoader.LoadSettings<AppSettings>("settings.json");

                InGameAddonLocation = new Rectangle(
                    scanArea.X + addonBottomLeft.X,
                    scanArea.Y + addonBottomLeft.Y - (frameSize * settings.AddonRowCount) + 1,
                    frameSize * settings.AddonColumnCount,
                    frameSize * settings.AddonRowCount);

                if (InGameAddonLocation.Height == 0 || InGameAddonLocation.Width == 0)
                {
                    Console.WriteLine("Could not locate addon on screen.");
                    InGameAddonLocation = new Rectangle(1, 1, 1, 1);
                }
                else
                {
                    Console.WriteLine("Ingame addon successfully located on screen: " + InGameAddonLocation);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Could not locate addon on screen.");
                InGameAddonLocation = new Rectangle(1, 1, 1, 1);
            }
        }

        private static bool IsMarkerColor(Color c)
            => c.R > 230 && c.G == 0 && c.B > 120;

        private static Point FindAddonBottomLeft(Bitmap b)
        {
            var bottomLeft = new Point(0, b.Height - 1);
            for (var x = 0; x < 100; x++)
            {
                var pixel = b.GetPixel(bottomLeft.X + x, bottomLeft.Y - x);
                if (IsMarkerColor(pixel))
                {
                    return new Point(bottomLeft.X + x, bottomLeft.Y - x);
                }
            }
            return bottomLeft;
        }

        private static int CalculateFrameSize(Point bottomLeft, Bitmap b)
        {
            var width = 0;
            for (var x = bottomLeft.X; x < b.Width; x++)
            {
                var pixel = b.GetPixel(x, bottomLeft.Y);
                if (IsMarkerColor(pixel))
                {
                    width++;
                }
                else
                {
                    break;
                }
            }
            return width / 4;
        }


        static IntPtr SetupGameHandle()
        {
            var processes = Process.GetProcessesByName("Wow");
            if (processes.Length == 0)
            {
                processes = Process.GetProcessesByName("WowClassic");
            }

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
