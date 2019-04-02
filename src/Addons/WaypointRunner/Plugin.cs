using System.Threading.Tasks;
using WowCyborgAddonUtilities;

namespace WaypointRunner
{
    public class Plugin : PluginBase
    {
        private WaypointManager _waypointManager;

        public Plugin(ApplicationSettings settings)
            : base(settings)
        {
        }

        public override bool HandleInput(string command, string[] args)
        {
            if (command != "waypoints")
            {
                return false;
            }

            if (args[0] == "run")
            {
                _waypointManager = new WaypointManager(Settings);
                Task.Run(() => {
                    _waypointManager.Start();
                });
            }

            return true;
        }

        public override void ShowCommands()
        {
            Logger.Log($@"
waypoints run                    Run waypoint for the current zone.
            ");
        }
    }
}
