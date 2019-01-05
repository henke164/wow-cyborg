using CefSharp;
using CefSharp.WinForms;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.IO;
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

            try
            {
                using (var sr = new StreamReader("d:\\waypoints.txt"))
                {
                    var wpJson = sr.ReadToEnd();
                    _waypoints = JsonConvert.DeserializeObject<List<Vector3>>(wpJson);
                }
            }
            catch
            {
            }

            if (_waypoints == null)
            {
                _waypoints = new List<Vector3>();
            }
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

            using (var sw = new StreamWriter("d:\\waypoints.txt"))
            {
                sw.WriteLine(JsonConvert.SerializeObject(_waypoints));
            }
        }

        public void SetCurrentWaypointToClosest(Vector3 position)
        {
            var closestDistance = 0f;

            for (var x = 0; x < _waypoints.Count; x++)
            {
                var distance = Vector3.Distance(position, _waypoints[x]);
                if (distance < closestDistance)
                {
                    closestDistance = distance;
                    _currentWaypoint = x;
                }
            }
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
