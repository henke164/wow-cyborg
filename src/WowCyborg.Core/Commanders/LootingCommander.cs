using System;
using System.Collections.Generic;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;
using WowCyborg.Core.Handlers;
using WowCyborg.Core.Utilities;

namespace WowCyborg.Core.Commanders
{
    public class LootingCommander
    {
        [DllImport("User32.dll")]
        static extern int SetForegroundWindow(IntPtr point);

        [DllImport("user32.dll")]
        private static extern int GetWindowRect(IntPtr hwnd, out Rectangle rect);

        public IntPtr HWnd { get; private set; }
        private List<Bitmap> _cursorImages;
        private bool _inCombat = false;

        public LootingCommander(IntPtr hWnd, ref bool inCombat)
        {
            _cursorImages = new List<Bitmap> {
                (Bitmap)Image.FromFile("Images/loot-cursor.png"),
                (Bitmap)Image.FromFile("Images/battle-cursor.png"),
                (Bitmap)Image.FromFile("Images/skin-cursor.png")
            };
            HWnd = hWnd;
            _inCombat = inCombat;
        }

        public void Loot(Action onDone)
        {
            Rectangle scanArea;
            if (HWnd != IntPtr.Zero)
            {
                SetForegroundWindow(HWnd);

                GetWindowRect(HWnd, out Rectangle windowRectangle);

                scanArea = GetScanArea(windowRectangle);
            }
            else
            {
                Console.WriteLine("No handler found. Scanning whole screen.");
                scanArea = Screen.PrimaryScreen.Bounds;
            }

            var lootLocation = Point.Empty;
            var lootCursorKind = LootCursorKind.None;

            for (var y = 0; y < scanArea.Height && lootLocation == Point.Empty; y += 20)
            {
                for (var x = 0; x < scanArea.Width && lootLocation == Point.Empty; x += 20)
                {
                    if (_inCombat)
                    {
                        return;
                    }

                    if (GetLootCursorAtLocation(scanArea.X + x, scanArea.Y + y) != LootCursorKind.None)
                    {
                        Thread.Sleep(100);
                        lootCursorKind = GetLootCursorAtLocation(scanArea.X + x, scanArea.Y + y);
                        if (lootCursorKind != LootCursorKind.None)
                        {
                            lootLocation = new Point(scanArea.X + x, scanArea.Y + y);
                        }
                    }
                }
            }

            if (lootLocation != Point.Empty)
            {
                Thread.Sleep(500);
                MouseHandler.RightClick(lootLocation.X, lootLocation.Y);
            }

            if (lootCursorKind == LootCursorKind.Skin)
            {
                Thread.Sleep(1000);
            }

            Thread.Sleep(1500);
            onDone();
        }

        private LootCursorKind GetLootCursorAtLocation(int x, int y)
        {
            MouseHandler.SetMousePosition(x, y);
            Thread.Sleep(50);
            foreach (var cursorImage in _cursorImages)
            {
                if (CursorUtilities.IsCursorIcon(cursorImage))
                {
                    switch (_cursorImages.IndexOf(cursorImage))
                    {
                        case 0: return LootCursorKind.Loot;
                        case 1: return LootCursorKind.Battle;
                        case 2: return LootCursorKind.Skin;
                        default: return LootCursorKind.Loot;
                    }
                }
            }

            return LootCursorKind.None;
        }

        public Rectangle GetScanArea(Rectangle windowRectangle)
        {
            var width = windowRectangle.Width - windowRectangle.X;
            var height = windowRectangle.Height - windowRectangle.Y;

            var center = new Point(
                windowRectangle.X + width / 2,
                windowRectangle.Y + height / 2);

            var size = new Size(200, 100);

            return new Rectangle(
                center.X - (size.Width / 2),
                center.Y - (size.Height / 8),
                size.Width,
                size.Height);
        }

        public enum LootCursorKind
        {
            Loot,
            Battle,
            Skin,
            None
        }
    }
}
