using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Threading;
using WowCyborg.UI;
using WowCyborg.Utilities;

namespace WowCyborg.Handlers
{
    public static class AddonLocator
    {
        private static Dictionary<IntPtr, Rectangle> InGameAddonLocations = new Dictionary<IntPtr, Rectangle>();

        private static IList<IntPtr> GameHandles;

        public static IList<IntPtr> InitializeGameHandles()
        {
            var gameHandles = SetupGameHandles();
            GameHandles = gameHandles;
            return GameHandles;
        }

        private static IList<IntPtr> GetGameHandles()
        {
            if (!GameHandles.Equals(IntPtr.Zero))
            {
                return GameHandles;
            }

            var procs = Process.GetProcessesByName("Wow");
            if (procs.Length > 0)
            {
                return procs.Select(p => p.MainWindowHandle).ToList();
            }

            procs = Process.GetProcessesByName("WowB");
            if (procs.Length > 0)
            {
                return procs.Select(p => p.MainWindowHandle).ToList();
            }

            procs = Process.GetProcessesByName("World of Warcraft");
            if (procs.Length > 0)
            {
                return procs.Select(p => p.MainWindowHandle).ToList();
            }

            procs = Process.GetProcessesByName("WowClassic");
            return procs.Select(p => p.MainWindowHandle).ToList();
        }

        public static Dictionary<IntPtr, Rectangle> GetAddonLocations()
        {
            if (InGameAddonLocations.Count() == 0)
            {
                ReCalculateAddonPositions();
            }

            return InGameAddonLocations;
        }

        public static void ReCalculateAddonPositions()
        {
            Rectangle rect;
            var handles = GetGameHandles();
            var locations = new Dictionary<IntPtr, Rectangle>();

            for (var i = 0; i < handles.Count; i++)
            {
                var handle = handles[i];

                try
                {
                    Program.GetWindowRect(handle, out rect);
                    Program.SetForegroundWindow(handle);
                    Thread.Sleep(500);
                    rect.Width -= rect.X;
                    rect.Height -= rect.Y;
                    Bitmap clone;

                    var bounds = ScreenUtilities.GetScreenBounds();
                    var winBottomLeft = new Point(rect.X, rect.Y + rect.Height);
                    var scanArea = new Rectangle(winBottomLeft.X, winBottomLeft.Y - 500, 500, 500);

                    if (scanArea.Y < 0)
                    {
                        scanArea.Height += scanArea.Y;
                        scanArea.Y = 0;
                    }
                    if (scanArea.X < 0)
                    {
                        scanArea.Width += scanArea.X;
                        scanArea.X = 0;
                    }

                    Program.Log($"Scan area x:{scanArea.X}, y:{scanArea.Y}, w:{scanArea.Width}, h:{scanArea.Height}");
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
                        Program.Log("Could not locate addon on screen. Make the addon visible on the screen, then press Reinitialize.");
                        locations.Add(handles[i], new Rectangle(1, 1, 1, 1));
                        continue;
                    }

                    var location = new Rectangle(
                        scanArea.X + addonBottomLeft.X,
                        scanArea.Y + addonBottomLeft.Y - (frameSize * Program.AddonRowCount) + 1,
                        frameSize * Program.AddonColumnCount,
                        frameSize * Program.AddonRowCount);

                    if (location.Height == 0 || location.Width == 0)
                    {
                        Program.Log("Could not locate addon on screen. Make the addon visible on the screen, then press Reinitialize.");
                        location = new Rectangle(1, 1, 1, 1);
                    }
                    else
                    {
                        Program.Log("Ingame addon successfully located on screen: " + location);
                    }
                    locations.Add(handles[i], location);
                    Thread.Sleep(200);
                }
                catch (Exception ex)
                {
                    Program.Log(ex.Message);
                    Program.Log("Could not locate addon on screen. Make the addon visible on the screen, then press Reinitialize.");
                    locations.Add(handles[i], new Rectangle(1, 1, 1, 1));
                }
            }

            InGameAddonLocations = locations;
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


        static IList<IntPtr> SetupGameHandles()
        {
            var processes = Process.GetProcessesByName("Wow");

            if (processes.Length == 0)
            {
                processes = Process.GetProcessesByName("WowT");
            }

            if (processes.Length == 0)
            {
                processes = Process.GetProcessesByName("WowB");
            }

            if (processes.Length == 0)
            {
                processes = Process.GetProcessesByName("WowClassic");
            }

            if (processes.Length == 0)
            {
                processes = Process.GetProcessesByName("World of Warcraft");
            }

            if (processes.Length == 1)
            {
                return new List<IntPtr> { processes[0].MainWindowHandle };
            }

            if (processes.Length > 1)
            {
                return processes.Select(p => p.MainWindowHandle).ToList();
            }

            return new List<IntPtr>();
        }
    }
}
