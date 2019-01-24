using CefSharp;
using CefSharp.WinForms;
using System;
using System.Windows.Forms;
using WoWPal.Handlers;
using WoWPal.Models.Abstractions;
using WoWPal.Handlers;
using WoWPal.Utilities;

namespace WoWPal
{
    public class CharacterController
    {
        private ChromiumWebBrowser _htmlController;
        private BotRunner _botRunner = new BotRunner();
        private MapHandler _mapHandler = new MapHandler();
        private Transform _currentTransform = new Transform(0, 0, 0, 0);
        private WaypointManager _waypointManager;

        public CharacterController(ChromiumWebBrowser htmlController)
        {
            _htmlController = htmlController;
            _waypointManager = new WaypointManager(htmlController);

            var page = string.Format(@"{0}\UserInterface\index.html", Application.StartupPath);
            _htmlController.Load(page);

            _botRunner.OnLog = new Action<string>(Log);

            EventManager.On("PlayerTransformChanged", (Event ev) =>
            {
                var transform = (Transform)ev.Data;
                if (_currentTransform.ZoneId != transform.ZoneId)
                {
                    CallJSFunction("setMapUrl", _mapHandler.GetMapUrl(transform.ZoneId));
                }

                _currentTransform = transform;

                CallJSFunction("setCharacterLocation", 
                    _currentTransform.Position.X.ToString(),
                    _currentTransform.Position.Z.ToString(),
                    _currentTransform.Rotation.ToString());
            });

            htmlController.RegisterAsyncJsObject("characterController", this);
        }

        private void Log(string s)
        {
            try
            {
                CallJSFunction("log", s);
            }
            catch
            {
                Console.WriteLine(s);
            }
        }

        public void ShowDevTools()
        {
            _htmlController.ShowDevTools();
        }

        public void GoToNextWaypoint()
            => _botRunner.MoveTo(_waypointManager.GetNextWaypoint(), () => {
                Log("Go to next waypoint");
                GoToNextWaypoint();
            });
        
        public void OnMovementCommand(string x, string y)
        {
            var floatX = float.Parse(x.Replace('.', ','));
            var floatY = float.Parse(y.Replace('.', ','));
            _botRunner.MoveTo(new Vector3(floatX, 0, floatY));
        }

        public void OnFaceCommand(string x, string y)
        {
            var floatX = float.Parse(x.Replace('.', ','));
            var floatY = float.Parse(y.Replace('.', ','));
            _botRunner.FaceTowards(new Vector3(floatX, 0, floatY));
        }

        private void CallJSFunction(string functionName, params object[] param)
            => _htmlController.ExecuteScriptAsync(functionName, param);
    }
}
