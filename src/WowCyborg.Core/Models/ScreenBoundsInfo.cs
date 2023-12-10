using System.Drawing;

namespace WowCyborg.Core.Models
{
    public class ScreenBoundsInfo
    {
        public int ScreenIndex { get; set; }
        public Rectangle Bounds { get; set; }
        public Rectangle RelativeBounds { get; set; }
    }
}
