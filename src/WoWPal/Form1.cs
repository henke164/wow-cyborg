using System;
using System.Windows.Forms;

namespace WoWPal
{
    public partial class Form1 : Form
    {
        private CharacterController _controller;

        public Form1()
        {
            InitializeComponent();
            _controller = new CharacterController(pictureBox1, listBox1);
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }
    }
}
