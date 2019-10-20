using System;
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
        public static bool IsSkinner { get; set; } = true;

        [DllImport("user32.dll")]
        private static extern int GetWindowRect(IntPtr hwnd, out Rectangle rect);

        private IntPtr _hWnd;
        private Bitmap _lootCursor;
        private bool _inCombat = false;

        public LootingCommander(IntPtr hWnd, ref bool inCombat)
        {
            _lootCursor = (Bitmap)Image.FromFile("Images/loot-cursor.png");
            _hWnd = hWnd;
            _inCombat = inCombat;
        }

        public void Loot(Action onDone)
        {
            var foundLoot = false;

            Rectangle windowRectangle;

            GetWindowRect(_hWnd, out windowRectangle);

            var scanArea = GetScanArea(windowRectangle);

            var lootLocation = Point.Empty;

            for (var y = 0; y < scanArea.Height && lootLocation == Point.Empty; y += 20)
            {
                for (var x = 0; x < scanArea.Width && lootLocation == Point.Empty; x += 20)
                {
                    if (_inCombat)
                    {
                        return;
                    }

                    if (IsLootLocation(scanArea.X + x, scanArea.Y + y))
                    {
                        var offset = 20;
                        lootLocation = new Point(scanArea.X + x + offset, scanArea.Y + y + offset);
                        foundLoot = true;
                    }
                }
            }

            if (lootLocation != Point.Empty)
            {
                MouseHandler.RightClick(lootLocation.X, lootLocation.Y);

                if (IsSkinner)
                {
                    Thread.Sleep(4000);
                    MouseHandler.RightClick(lootLocation.X, lootLocation.Y);
                    Thread.Sleep(2500);
                }
            }

            Thread.Sleep(1500);
            if (foundLoot)
            {
                Loot(onDone);
            }
            else
            {
                onDone();
            }
        }

        private bool IsLootLocation(int x, int y)
        {
            MouseHandler.SetMousePosition(x, y);
            Thread.Sleep(50);
            return CursorUtilities.IsCursorIcon(_lootCursor);
        }

        public Rectangle GetScanArea(Rectangle windowRectangle)
        {
            var center = new Point(
                windowRectangle.Width / 2,
                windowRectangle.Height / 2);

            var size = new Size(300, 200);

            return new Rectangle(
                center.X - (size.Width / 2),
                center.Y - (size.Height / 8),
                size.Width,
                size.Height);
        }

        private Point MovePoint(Point p, int x, int y)
            => new Point(p.X + x, p.Y + y);
    }
}
