using CombatRotationInstaller;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using WowCyborg.Handlers;
using WowCyborg.Models;
using WowCyborg.Utilities;

namespace WowCyborg.UI
{
    public partial class Form1 : Form
    {
        public static WowRotationInstaller AddonInstaller;
        public static IList<Bot> BotRunners;
        private bool _topMost = true;
        private RotationProfile _currentProfile;

        public Form1()
        {
            InitializeComponent();
            InitializeBotRunner();
        }

        public void WriteLog(string str)
        {
            if (logTextBox.InvokeRequired)
            {
                logTextBox.Invoke(new Action(() => logTextBox.Text += str + "\r\n" ));
            }
            else
            {
                logTextBox.Text += str + "\r\n";
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            InitializeBotRunner();
            AddonLocator.ReCalculateAddonPositions();
        }

        private void InitializeBotRunner()
        {
            var gameHandles = AddonLocator.InitializeGameHandles();
            BotRunners = new List<Bot>();
            if (gameHandles.Count == 0)
            {
                MessageBox.Show("No Game processes found! Start the game, then press Reinitialize");
                return;
            }

            foreach (var hWnd in gameHandles)
            {
                BotRunners.Add(new Bot(hWnd));
            }

            ListRotations();

            var currentRotation = AddonInstaller.GetCurrentRotation();
            if (currentRotation != null)
            {
                SelectProfile(currentRotation);
            }
        }

        private void ListRotations()
        {
            var wowAddonPath = $"{AddonFolderHandler.GetAddonFolderPath()}";
            if (!Directory.Exists(wowAddonPath))
            {
                return;
            }

            AddonInstaller = new WowRotationInstaller(wowAddonPath);
            AddonInstaller.FetchRotations();
            panel2.Controls.Clear();

            var y = 0;
            foreach (var rotation in AddonInstaller.Rotations)
            {
                var rotationProfile = new RotationProfileControl(rotation.Name, rotation.ImageUrl, () => SelectProfile(rotation));
                rotationProfile.Location = new Point(0, y);
                y += rotationProfile.Height + 5;
                rotationProfile.Dock = DockStyle.Fill;
                rotationProfile.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
                
                panel2.Controls.Add(rotationProfile);
            }

            var addProfileLink = new LinkLabel
            {
                Text = "Create New Profile",
                Location = new Point(0, y + 10),
                LinkColor = Color.CornflowerBlue
            };

            addProfileLink.Click += (object sender, EventArgs e) =>
            {
                var form = new CreateProfileForm
                {
                    OnProfileFormSubmitted = (string name, string icon) =>
                    {
                        string fileName = Regex.Replace(name, @"[^a-zA-Z]", "");
                        AddonInstaller.CreateNewRotation(fileName, name, icon);
                        Program.Log($"New rotation created!");
                        ListRotations();
                    }
                };
                form.Show();
            };

            panel2.Controls.Add(addProfileLink);
        }

        private void FocusGame()
        {
            var runner = BotRunners.FirstOrDefault();
            if (runner != null)
            {
                Program.SetForegroundWindow(runner.Hwnd);
            }
        }

        private void SelectProfile(RotationProfile profile)
        {
            var successful = AddonInstaller.SetRotation(profile);
            if (!successful)
            {
                Program.Log($"Could not set rotation. Is the game initialized?");
                return;
            }

            _currentProfile = profile;
            linkLabel1.Show();
            label2.Text = profile.Name;
            pictureBox1.ImageLocation = profile.ImageUrl;
            
            Program.Log($"Profile changed to {profile.Name}!");
            Program.Log($"Remember to /reload in game!");
            FocusGame();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            _topMost = !_topMost;
            this.TopMost = _topMost;
            button1.ForeColor = _topMost ? Color.SeaGreen : Color.Brown;
        }

        private void button3_Click(object sender, EventArgs e)
        {
            FocusGame();
        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            if (_currentProfile == null)
            {
                return;
            }
            
            var successful = FileUtilities.OpenTextFile(_currentProfile.Path);
            if (!successful)
            {
                Program.Log("Could not find an editor to edit profile");
            }
        }

        private void button4_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        protected override void OnPaintBackground(PaintEventArgs e)
        {
            e.Graphics.Clear(Color.Transparent);
        }
    }
}
