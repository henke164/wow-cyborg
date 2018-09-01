using System;
using System.Windows.Forms;
using WoWPal.Commanders;
using WoWPal.EventDispatchers;
using WoWPal.Events;
using WoWPal.Events.Abstractions;
using WoWPal.Utilities;

namespace WoWPal
{
    public partial class Form1 : Form
    {
        private RotationCommander _rotationCommander = new RotationCommander();

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            var screenshotDispatcher = EventManager.StartEventDispatcher(typeof(ScreenChangedDispatcher));
            var locationDispatcher = EventManager.StartEventDispatcher(typeof(PlayerTransformChangedDispatcher));
            var combatDispatcher = EventManager.StartEventDispatcher(typeof(CombatChangedDispatcher));

            EventManager.On("ScreenChanged", (Event ev) => {
                locationDispatcher.ReceiveEvent(ev);
                combatDispatcher.ReceiveEvent(ev);
            });

            EventManager.On("PlayerTransformChanged", (Event ev) => {
                var data = (Transform)ev.Data;

                label1.Invoke((MethodInvoker)(() =>
                {
                    label1.Text = $"x: {data.X}\nz: {data.Z}\nr: {data.R}";
                }));
            });


            EventManager.On("CombatChanged", (Event ev) =>
            {
                var data = (bool)ev.Data;

                label2.Invoke((MethodInvoker)(() =>
                {
                    label2.Text = data ? "In combat" : "Not in combat";
                }));
            });
        }

        private void button1_Click(object sender, EventArgs e)
        {
            _rotationCommander.FacePoint(new Vector3(0.3816f, 0, 0.3643f));
        }
    }
}
