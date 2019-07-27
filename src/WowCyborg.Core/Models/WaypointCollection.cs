using System.Collections.Generic;
using WowCyborg.Core.Utilities;

namespace WowCyborg.Core.Models
{
    public class WaypointCollection
    {
        public string Name { get; set; }
        public IList<Vector3> Waypoints { get; set; }
    }
}
