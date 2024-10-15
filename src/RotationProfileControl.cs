using System;
using System.Windows.Forms;

namespace WowCyborg
{
    public partial class RotationProfileControl : UserControl
    {
        public RotationProfileControl(string name, string icon, Action onClick)
        {
            InitializeComponent();
            linkLabel1.Text = name;
            pictureBox1.ImageLocation = icon;
            linkLabel1.Click += (object sender, EventArgs e) => onClick();
        }
    }
}
