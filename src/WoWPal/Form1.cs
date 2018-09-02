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
        private MovementCommander _movementCommander = new MovementCommander();

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            var screenshotDispatcher = EventManager.StartEventDispatcher(typeof(ScreenChangedDispatcher));
            var locationDispatcher = EventManager.StartEventDispatcher(typeof(PlayerTransformChangedDispatcher));
            var combatDispatcher = EventManager.StartEventDispatcher(typeof(CombatChangedDispatcher));
            var targetDispatcher = EventManager.StartEventDispatcher(typeof(NewTargetDispatcher));

            EventManager.On("PlayerTransformChanged", (Event ev) => {
                var data = (Transform)ev.Data;

                label1.Invoke((MethodInvoker)(() =>
                {
                    label1.Text = $"x: {data.Position.X}\nz: {data.Position.Z}\nr: {data.Rotation}";
                }));
            });


            EventManager.On("CombatChanged", (Event ev) =>
            {
                var data = (bool)ev.Data;

                label2.Invoke((MethodInvoker)(() =>
                {
                    label2.Text = data ? "In combat" : "Not in combat";
                }));

                if (!data)
                {
                    StartMovement();
                }
            });

            EventManager.On("TargetInRange", (Event ev) =>
            {
                _movementCommander.Stop();
            });
        }

        private void button1_Click(object sender, EventArgs e)
        {
            StartMovement();
        }

        private void StartMovement()
        {
            var f1 = (float)numericUpDown1.Value;
            var f2 = (float)numericUpDown2.Value;
            _movementCommander.MoveToLocation(new Vector3(f1, 0, f2));
        }
    }
}
