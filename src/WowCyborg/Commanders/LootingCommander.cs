using System;
using System.Drawing;
using System.Windows.Forms;
using WowCyborg.Handlers;

namespace WowCyborg.Commanders
{
    public class LootingCommander
    {
        private Point MovePoint(Point p, int x, int y)
            => new Point(p.X + x, p.Y + y);
        
        public void Loot(Action onDone)
        {
            var dist = 50;
            var center = new Point(
                Screen.PrimaryScreen.Bounds.Width / 2, 
                Screen.PrimaryScreen.Bounds.Height / 2);

            var points = new Point[] {
                MovePoint(center, -dist, -dist),
                MovePoint(center, 0, -dist),
                MovePoint(center, dist, -dist),
                MovePoint(center, -dist, 0),
                MovePoint(center, 0, 0),
                MovePoint(center, dist, 0),
                MovePoint(center, -dist, dist),
                MovePoint(center, 0, dist),
                MovePoint(center, dist, dist),
            };

            foreach (var p in points)
            {
                MouseHandler.RightClick(p.X, p.Y);
            }

            onDone();
        }
    }
}
