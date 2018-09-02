using System;
using System.Windows.Forms;
using WoWPal.Utilities;

namespace WoWPal
{
    public partial class Form1 : Form
    {
        private BotRunner _botRunner = new BotRunner();

        public Form1()
        {
            InitializeComponent();
            _botRunner.OnLog = new Action<string>((string s) => {
                listBox1.Invoke((MethodInvoker)delegate {
                    listBox1.Items.Insert(0, s);
                });
            });
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            var f1 = (float)numericUpDown1.Value;
            var f2 = (float)numericUpDown2.Value;
            _botRunner.MoveTo(new Vector3(f1, 0, f2));
        }
    }
}
