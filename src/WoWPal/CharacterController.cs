using System;
using System.Drawing;
using System.Windows.Forms;
using WoWPal.Events;
using WoWPal.Events.Abstractions;
using WoWPal.Utilities;

namespace WoWPal
{
    public class CharacterController
    {
        private Control _fieldControl;
        private Rect _cameraRectangle;
        private BotRunner _botRunner = new BotRunner();

        private Transform _currentTransform = new Transform(0, 0, 0, 0);
        private float _fieldWidth = 0.05f;
        private float _fieldHeight = 0.05f;

        public CharacterController(Control control, ListBox logListbox)
        {
            _botRunner.OnLog = new Action<string>((string s) => {
                logListbox.Invoke((MethodInvoker)delegate {
                    logListbox.Items.Insert(0, s);
                });
            });

            EventManager.On("PlayerTransformChanged", (Event ev) =>
            {
                _currentTransform = (Transform)ev.Data;
                UpdateField();
            });

            _fieldControl = control;
            _fieldControl.BackColor = Color.Black;
            _fieldControl.Click += ControlClicked;
        }

        private void UpdateField()
        {
            float fromX = _currentTransform.Position.X - (_fieldWidth / 2);
            float toX = _currentTransform.Position.X + (_fieldWidth / 2);

            float fromZ = _currentTransform.Position.Z - (_fieldHeight / 2);
            float toZ = _currentTransform.Position.Z + (_fieldHeight / 2);

            _cameraRectangle = new Rect(fromX, fromZ, toX, toZ);
        }

        private void ControlClicked(object sender, EventArgs e)
        {
            var mouseEvent = (MouseEventArgs)e;
            var xPerc = (mouseEvent.X / (decimal)_fieldControl.Width) * 100;
            var yPerc = (mouseEvent.Y / (decimal)_fieldControl.Height) * 100;

            var minX = _cameraRectangle.Width - _cameraRectangle.X;
            var minY = _cameraRectangle.Height - _cameraRectangle.Y;

            var xTarget = ((decimal)(minX / 100) * xPerc) + (decimal)_cameraRectangle.X;
            var yTarget = ((decimal)(minY / 100) * yPerc) + (decimal)_cameraRectangle.Y;
            _botRunner.MoveTo(new Vector3((float)xTarget, 0, (float)yTarget));
        }
    }
}
