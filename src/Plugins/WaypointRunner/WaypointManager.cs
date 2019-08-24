using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using WaypointRunner.Models;
using WowCyborgAddonUtilities;

namespace WaypointRunner
{
    public class WaypointManager
    {
        private ApiClient _client;

        private BotApi _botApi;

        public WaypointManager(ApplicationSettings settings)
        {
            _botApi = settings.BotApi;
            _client = new ApiClient(settings.ServerUrl);
        }

        public void Start()
        {
            var currentLocation = _botApi.GetCurrentTransform();
            try
            {
                var waypointsRaw = _client.GetFile($"Waypoints/wp-{currentLocation.ZoneId}.json");
                var waypoints = JsonConvert.DeserializeObject<List<Waypoint>>(waypointsRaw.Content);
                Run(0, waypoints);
            }
            catch(Exception ex)
            {
                Logger.Log("No waypoints found in current location.");
            }
        }

        private void Run(int index, List<Waypoint> waypoints)
        {
            var waypoint = waypoints[index];

            _botApi.MoveTo(waypoint.X, waypoint.Z, () => {
                var nextIndex = index + 1 < waypoints.Count ? index + 1 : 0;
                Run(nextIndex, waypoints);
            });
        }
    }
}