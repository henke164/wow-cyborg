using System.Collections.Generic;
using WoWPal.Utilities;

namespace WoWPal.Models
{
    public class WaypointCollection
    {
        public string Name { get; set; }
        public IList<Vector3> Waypoints { get; set; }
    }
}
