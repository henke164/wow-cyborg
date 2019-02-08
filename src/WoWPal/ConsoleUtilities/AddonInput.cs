using System;
using System.Linq;
using WoWPal.Handlers;

namespace WoWPal.ConsoleUtilities
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
            else
            {
                Program.Log("Unknown command", ConsoleColor.Red);
            }
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
