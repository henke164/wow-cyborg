using System;
using System.Linq;
using WowCyborg.Handlers;

namespace WowCyborg.ConsoleUtilities
{
    public static class AddonInput
    {
        public static void HandleInputParameters(string[] parameters)
        {
            var commandParameters = parameters.ToList().Skip(1).ToList();

            if (commandParameters.Count() == 0)
            {
                Program.ShowHelp();
                return;
            }

            if (commandParameters[0] == "reload")
            {
                RelocateAddon();
            }
            else if (commandParameters[0] == "reinstall")
            {
                ReinstallAddon();
            }
            else
            {
                Program.Log("Unknown command", ConsoleColor.Red);
            }
        }

        public static void ReinstallAddon()
        {
            Program.Log("Downloading addon files...", ConsoleColor.Green);
            while (!AddonInstaller.DownloadAddon())
            {
                Program.Log("Press enter to retry...", ConsoleColor.White);
                Console.ReadLine();
            }
            AddonInstaller.DownloadRotations();
            Program.Log($"Download complete! Restart the game, and make sure you activate the addon: '{AddonInstaller.AddonName}'", ConsoleColor.Green);
        }

        private static void RelocateAddon()
        {
            AddonLocator.ReCalculateAddonPosition();
            var addonLocation = AddonLocator.GetAddonLocation();
            if (addonLocation.Width == 1 || addonLocation.Height == 1)
            {
                Program.Log("Addon could not be located. Make sure it's loaded and visible.", ConsoleColor.Red);
            }
            else
            {
                Program.Log($"Addon successfully located: {addonLocation.ToString()}", ConsoleColor.Green);
            }

            AddonFolderHandler.LocateAddonFolderPath();
            var addonFolderPath = AddonFolderHandler.GetAddonFolderPath();
            if (!string.IsNullOrEmpty(addonFolderPath))
            {
                Program.Log($"Successfully found Wow Addon folder at {addonFolderPath}", ConsoleColor.Green);
            }
            else
            {
                Program.Log("Addon folder could not be found!", ConsoleColor.Red);
                Program.Log("Make sure the game is running when the app tries to locate the Addon PATH. Run 'addon reload' when the game is running to retry.", ConsoleColor.Red);
            }
        }
    }
}
