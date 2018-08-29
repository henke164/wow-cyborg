using System;
using System.Drawing;
using System.Windows.Forms;
using WoWPal.EventDispatchers;
using WoWPal.EventDispatchers.Abstractions;

namespace WoWPal
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            var eventManager = new EventManager();
            eventManager.StartEventDispatcher(typeof(ScreenChangedDispatcher));

            eventManager.On("ScreenChanged", (Event ev) => {
                this.BackgroundImage = (Bitmap)ev.Data;
            });
        }
    }
}
