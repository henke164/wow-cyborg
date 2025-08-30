using System;
using System.Windows.Forms;

namespace WowCyborg
{
    public partial class CreateProfileForm : Form
    {
        public Action<string, string> OnProfileFormSubmitted;

        public CreateProfileForm()
        {
            InitializeComponent();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            OnProfileFormSubmitted?.Invoke(textBox1.Text, textBox2.Text);
        }
    }
}
