namespace WoWPal.Models
{
    public class AppSettings
    {
        public AddonPosition AddonPosition { get; set; }

        public string WaypointsPath { get; set; }
    }

    public class AddonPosition
    {
        public int X { get; set; }
        public int Y { get; set; }
        public int Width { get; set; }
        public int Height { get; set; }
    }
}
