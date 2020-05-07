﻿using System;
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

        private IntPtr _hWnd;
        private List<Bitmap> _cursorImages;
        private bool _inCombat = false;
        private bool _isSkinner = false;
        private bool _lootOnce = true;

        public LootingCommander(IntPtr hWnd, ref bool inCombat, bool isSkinner = false)
        {
            _cursorImages = new List<Bitmap> {
                (Bitmap)Image.FromFile("Images/loot-cursor.png"),
                (Bitmap)Image.FromFile("Images/battle-cursor.png")
            };
            _hWnd = hWnd;
            _inCombat = inCombat;
            _isSkinner = isSkinner;
        }

        public void Loot(Action onDone)
        {
            var foundLoot = false;

            Rectangle windowRectangle;

            SetForegroundWindow(_hWnd);

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
                        Thread.Sleep(100);
                        if (IsLootLocation(scanArea.X + x, scanArea.Y + y))
                        {
                            lootLocation = new Point(scanArea.X + x, scanArea.Y + y);
                            foundLoot = true;
                        }
                    }
                }
            }

            if (lootLocation != Point.Empty)
            {
                Thread.Sleep(500);
                MouseHandler.RightClick(lootLocation.X, lootLocation.Y);

                if (_isSkinner)
                {
                    Thread.Sleep(4000);
                    MouseHandler.RightClick(lootLocation.X, lootLocation.Y);
                    Thread.Sleep(2500);
                }
            }

            Thread.Sleep(1500);
            if (foundLoot && !_lootOnce)
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
            foreach (var cursor in _cursorImages)
            {
                if (CursorUtilities.IsCursorIcon(cursor))
                {
                    return true;
                }
            }
            return false;
        }

        public Rectangle GetScanArea(Rectangle windowRectangle)
        {
            var center = new Point(
                windowRectangle.X + 500,
                windowRectangle.Y + 300);

            var size = new Size(200, 100);

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
