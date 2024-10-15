using CombatRotationInstaller;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using WowCyborg.BotProfiles;
using WowCyborg.Handlers;
using WowCyborg.Models;
using WowCyborg.Utilities;

namespace WowCyborg.UI
{
    public partial class Form1 : Form
    {
        public static WowAddonInstaller AddonInstaller;
        public static IList<Bot> BotRunners;

        public Form1()
        {
            InitializeComponent();
            ListRotations();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            InitializeBotRunner();
        }

        private void ListRotations()
        {
            var settings = SettingsLoader.LoadSettings<AppSettings>("settings.json");
            var wowAddonPath = $"{AddonFolderHandler.GetAddonFolderPath()}";
            AddonInstaller = new WowAddonInstaller(settings.AddonPath, wowAddonPath);
            AddonInstaller.FetchRotations();
            
            panel2.Controls.Clear();

            var y = 0;
            foreach (var rotation in AddonInstaller.Rotations)
            {
                var rotationProfile = new RotationProfileControl(rotation.Name, rotation.ImageUrl, () => SelectProfile(rotation));
                rotationProfile.Location = new Point(0, y);
                y += rotationProfile.Height + 5;
                panel2.Controls.Add(rotationProfile);
            }
        }

        private void RotationProfile_Click(object sender, EventArgs e)
        {
            throw new NotImplementedException();
        }

        private void InitializeBotRunner()
        {
            var gameHandles = AddonLocator.InitializeGameHandles();
            BotRunners = new List<Bot>();
            if ()
            foreach (var hWnd in gameHandles)
            {
                BotRunners.Add(new AutoCaster(hWnd));
            }
        }

        private void SelectProfile(RotationProfile profile)
        {
            AddonInstaller.SetRotation(profile);
            label2.Text = profile.Name;
            pictureBox1.ImageLocation = profile.ImageUrl;
        }
    }
}
