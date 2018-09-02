using System.Collections.Generic;
using System.Drawing;

namespace WoWPal.Models
{
    public class ActionbarSettings
    {
        public IList<ActionbarButton> Buttons { get; set; }
    }

    public class ActionbarButton
    {
        public string Name { get; set; }
        public int X { get; set; }
        public int Y { get; set; }
    }
}
