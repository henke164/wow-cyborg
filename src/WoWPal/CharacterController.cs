using CefSharp;
using CefSharp.WinForms;
using System;
using System.Drawing;
using System.Windows.Forms;
using WoWPal.Events;
using WoWPal.Events.Abstractions;
using WoWPal.Handlers;
using WoWPal.Utilities;

namespace WoWPal
{
    public class CharacterController
    {
        private Rect _cameraRectangle;
        private BotRunner _botRunner = new BotRunner();
        private MapHandler _mapHandler;
        private Transform _currentTransform = new Transform(0, 0, 0, 0);
        private float _fieldWidth = 0.05f;
        private float _fieldHeight = 0.05f;

        public CharacterController(ChromiumWebBrowser htmlController, ListBox logListbox)
        {
            _botRunner.OnLog = new Action<string>((string s) => {
                logListbox.Invoke((MethodInvoker)delegate {
                    logListbox.Items.Insert(0, s);
                });
            });

            EventManager.On("PlayerTransformChanged", (Event ev) =>
            {
                _currentTransform = (Transform)ev.Data;
                htmlController.ExecuteScriptAsync("setCharacterLocation", new string[]
                {
                    _currentTransform.Position.X.ToString(),
                    _currentTransform.Position.Y.ToString()
                });
            });

            htmlController.RegisterAsyncJsObject("characterController", this);
        }

        public void OnMovementCommand(string x, string y)
        {
            var floatX = float.Parse(x.Replace('.', ','));
            var floatY = float.Parse(y.Replace('.', ','));
            _botRunner.MoveTo(new Vector3(floatX, 0, floatY));
        }
    }
}
