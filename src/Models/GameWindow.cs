using System.Diagnostics;
using System.Drawing;

namespace WindowResize.Models
{
    public class GameWindow
    {
        public Process GameProcess { get; set; }
        public Rectangle WindowRectangle { get; set; }
    }
}
