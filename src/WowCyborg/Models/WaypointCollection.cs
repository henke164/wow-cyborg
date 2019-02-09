using System.Collections.Generic;
using WowCyborg.Utilities;

namespace WowCyborg.Models
{
    public class WaypointCollection
    {
        public string Name { get; set; }
        public IList<Vector3> Waypoints { get; set; }
    }
}
