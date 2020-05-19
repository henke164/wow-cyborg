using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
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
                    GetWindowRect(handle, out rect);
                    SetForegroundWindow(handle);
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

                    Console.WriteLine($"Scan area x:{scanArea.X}, y:{scanArea.Y}, w:{scanArea.Width}, h:{scanArea.Height}");
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
                        locations.Add(handles[i], new Rectangle(1, 1, 1, 1));
                        continue;
                    }

                    var settings = SettingsLoader.LoadSettings<AppSettings>("settings.json");

                    var location = new Rectangle(
                        scanArea.X + addonBottomLeft.X,
                        scanArea.Y + addonBottomLeft.Y - (frameSize * settings.AddonRowCount) + 1,
                        frameSize * settings.AddonColumnCount,
                        frameSize * settings.AddonRowCount);

                    if (location.Height == 0 || location.Width == 0)
                    {
                        Console.WriteLine("Could not locate addon on screen.");
                        location = new Rectangle(1, 1, 1, 1);
                    }
                    else
                    {
                        Console.WriteLine("Ingame addon successfully located on screen: " + location);
                    }
                    locations.Add(handles[i], location);
                    Thread.Sleep(200);
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                    Console.WriteLine("Exception: Could not locate addon on screen.");
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
                processes = Process.GetProcessesByName("WowClassic");
            }

            if (processes.Length == 1)
            {
                return new List<IntPtr> { processes[0].MainWindowHandle };
            }

            if (processes.Length > 1)
            {
                Console.WriteLine("Select process");
                for (var x = 0; x < processes.Length; x++)
                {
                    Console.WriteLine($"{x}. {processes[x].MainWindowTitle} ({processes[x].Id})");
                }
                Console.WriteLine("Type \"all\" to run on all processes");

                var input = Console.ReadLine();
                if (input == "all")
                {
                    return processes.Select(p => p.MainWindowHandle).ToList();
                }
                var index = int.Parse(Console.ReadLine());
                return new List<IntPtr> { processes[index].MainWindowHandle };
            }

            return new List<IntPtr>();
        }
    }
}
