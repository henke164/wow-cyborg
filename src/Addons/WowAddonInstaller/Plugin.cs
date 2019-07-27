using System;
using WowCyborg.Core.Handlers;
using WowCyborg.PluginUtilities;
using WowCyborg.PluginUtilities.Models;

namespace WowAddonInstaller
{
    public class Plugin : PluginBase
    {
        private WowAddonInstaller _addonInstaller;

        public Plugin(ApplicationSettings settings)
            : base(settings)
        {
            _addonInstaller = new WowAddonInstaller(Settings.ServerUrl, Settings.WowAddonPath);
        }

        private void ValidateAddonFiles()
        {
            if (!_addonInstaller.AddonExists())
            {
                ReinstallAddon();
            }
        }

        public override bool HandleInput(string command, string[] args)
        {
            if (command != "addon")
            {
                return false;
            }
            
            switch (args[0])
            {
                case "reload":
                    RelocateAddon();
                    break;
                case "reinstall":
                    ReinstallAddon();
                    break;
                default:
                    Logger.Log("Unknown command", ConsoleColor.Red);
                    break;
            }

            return true;
        }

        private void ReinstallAddon()
        {
            Logger.Log("Downloading addon files...", ConsoleColor.Green);
            while (!_addonInstaller.DownloadAddon())
            {
                Logger.Log("Press enter to retry...", ConsoleColor.White);
                Console.ReadLine();
            }
            Logger.Log($"Download complete! Restart the game, and make sure you activate the addon.", ConsoleColor.Green);
        }

        private void RelocateAddon()
        {
            AddonLocator.ReCalculateAddonPosition();
            var addonLocation = AddonLocator.GetAddonLocation();
            if (addonLocation.Width == 1 || addonLocation.Height == 1)
            {
                Logger.Log("Addon could not be located. Make sure it's loaded and visible.", ConsoleColor.Red);
            }
            else
            {
                Logger.Log($"Addon successfully located: {addonLocation.ToString()}", ConsoleColor.Green);
            }

            AddonFolderHandler.LocateAddonFolderPath();
            var addonFolderPath = AddonFolderHandler.GetAddonFolderPath();
            if (!string.IsNullOrEmpty(addonFolderPath))
            {
                Logger.Log($"Successfully found Wow Addon folder at {addonFolderPath}", ConsoleColor.Green);
            }
            else
            {
                Logger.Log("Addon folder could not be found!", ConsoleColor.Red);
                Logger.Log("Make sure the game is running when the app tries to locate the Addon PATH. Run 'addon reload' when the game is running to retry.", ConsoleColor.Red);
            }
        }

        public override void ShowCommands()
        {
            Logger.Log($@"
addon reload                    If this program cant see the addon on startup you will need to run this command.
                                It commands the program to find out where the addon is located on the screen.

addon reinstall                 Download latest addon files, and reinstall it.
            ");
        }
    }
}
