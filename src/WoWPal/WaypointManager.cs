using CefSharp;
using CefSharp.WinForms;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Linq;
using WoWPal.Utilities;

namespace WoWPal
{
    public class WaypointManager
    {
        private int _currentWaypoint = 0;
        IList<Vector3> _waypoints = new List<Vector3>();

        ChromiumWebBrowser _htmlController;

        public WaypointManager(ChromiumWebBrowser htmlController)
        {
            _htmlController = htmlController;

            htmlController.RegisterAsyncJsObject("waypointManager", this);
        }

        public void AddWaypoint(string x, string z)
        {
            var floatX = float.Parse(x.Replace('.', ','));
            var floatZ = float.Parse(z.Replace('.', ','));
            _waypoints.Add(new Vector3(floatX, 0, floatZ));

            CallJSFunction("setWaypointList", JsonConvert.SerializeObject(_waypoints.Select(w =>
            {
                return new { x = w.X, z = w.Z };
            })));
        }
        
        public Vector3 GetNextWaypoint()
         {
            if (_currentWaypoint >= _waypoints.Count)
            {
                _currentWaypoint = 0;
            }

            return _waypoints[_currentWaypoint++];
        }
        
        private void CallJSFunction(string functionName, params object[] param)
            => _htmlController.ExecuteScriptAsync(functionName, param);
    }
}
