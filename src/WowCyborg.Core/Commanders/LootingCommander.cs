using System;
using System.Drawing;
using System.Threading;
using System.Windows.Forms;
using WowCyborg.Core.Handlers;
using WowCyborg.Core.Utilities;

namespace WowCyborg.Core.Commanders
{
    public class LootingCommander
    {
        private Bitmap _lootCursor;

        public LootingCommander()
        {
            _lootCursor = (Bitmap)Image.FromFile("Images/loot-cursor.png");
        }

        public void Loot(Action onDone)
        {
            var scanArea = GetScanArea();

            var lootLocation = Point.Empty;

            for (var y = 0; y < scanArea.Height && lootLocation == Point.Empty; y += 20)
            {
                for (var x = 0; x < scanArea.Width && lootLocation == Point.Empty; x += 20)
                {
                    if (IsLootLocation(scanArea.X + x, scanArea.Y + y))
                    {
                        lootLocation = new Point(scanArea.X + x, scanArea.Y + y);
                    }
                }
            }

            if (lootLocation != Point.Empty)
            {
                MouseHandler.RightClick(lootLocation.X, lootLocation.Y);
            }

            Thread.Sleep(1500);
            onDone();
        }

        private bool IsLootLocation(int x, int y)
        {
            MouseHandler.SetMousePosition(x, y);
            Thread.Sleep(50);
            return CursorUtilities.IsCursorIcon(_lootCursor);
        }

        public Rectangle GetScanArea()
        {
            var center = new Point(
                Screen.PrimaryScreen.Bounds.Width / 2,
                Screen.PrimaryScreen.Bounds.Height / 2);

            var size = new Size(200, 200);

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
