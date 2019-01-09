using CefSharp;
using CefSharp.WinForms;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using WoWPal.Models;
using WoWPal.Utilities;

namespace WoWPal
{
    public class WaypointManager
    {
        private int _currentWaypoint = 0;
        private string _selectedWaypointCollection = "Default";
        private IList<WaypointCollection> _waypointCollections = new List<WaypointCollection>();

        ChromiumWebBrowser _htmlController;

        public WaypointManager(ChromiumWebBrowser htmlController)
        {
            _htmlController = htmlController;

            htmlController.RegisterAsyncJsObject("waypointManager", this);

            Load();
        }

        public void SetSelectedCollection(string name)
        {
            var collection = _waypointCollections.FirstOrDefault(w => w.Name == name);
            if (collection != null)
            {
                _selectedWaypointCollection = collection.Name;
                SynchronizeWaypointCollections();
            }
        }

        public void DeleteWaypointCollection(string name)
        {
            var collection = _waypointCollections.FirstOrDefault(w => w.Name == name);
            if (collection != null)
            {
                _waypointCollections.Remove(collection);
                Save();
                SynchronizeWaypointCollections();
            }
        }
        
        public void SynchronizeWaypointCollections()
        {
            CallJSFunction("loadWaypointCollections", JsonConvert.SerializeObject(_waypointCollections));
        }

        public void CreateWaypointCollection(string name)
        {
            if (_waypointCollections.Any(w => w.Name == name))
            {
                return;
            }

            _waypointCollections.Add(new WaypointCollection
            {
                Name = name,
                Waypoints = new List<Vector3>(),
            });

            _selectedWaypointCollection = name;
            SynchronizeWaypointCollections();
        }

        public void AddWaypoint(string x, string z)
        {
            var waypoints = GetCurrentWaypoints();

            var floatX = float.Parse(x.Replace('.', ','));
            var floatZ = float.Parse(z.Replace('.', ','));
            waypoints.Add(new Vector3(floatX, 0, floatZ));
            Save();
            SynchronizeWaypointCollections();
        }

        public Vector3 GetNextWaypoint()
        {
            var waypoints = GetCurrentWaypoints();

            if (_currentWaypoint >= waypoints.Count)
            {
                _currentWaypoint = 0;
            }

            return waypoints[_currentWaypoint++];
        }

        private void Load()
        {
            var settings = SettingsLoader.LoadSettings<AppSettings>("settings.json");

            try
            {
                using (var sr = new StreamReader(settings.WaypointsPath))
                {
                    var wpJson = sr.ReadToEnd();
                    _waypointCollections = JsonConvert.DeserializeObject<List<WaypointCollection>>(wpJson);
                }
            }
            catch
            {
            }

            if (_waypointCollections == null)
            {
                _waypointCollections = new List<WaypointCollection>();
            }
        }

        private void Save()
        {
            var settings = SettingsLoader.LoadSettings<AppSettings>("settings.json");

            using (var sw = new StreamWriter(settings.WaypointsPath))
            {
                sw.WriteLine(JsonConvert.SerializeObject(_waypointCollections));
            }
        }

        private IList<Vector3> GetCurrentWaypoints()
            => _waypointCollections.FirstOrDefault(w => w.Name == _selectedWaypointCollection).Waypoints;
        
        private void CallJSFunction(string functionName, params object[] param)
            => _htmlController.ExecuteScriptAsync(functionName, param);
    }
}
