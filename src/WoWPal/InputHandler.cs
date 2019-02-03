using System;
using WoWPal.Handlers;

namespace WoWPal
{
    public static class InputHandler
    {
        public static void ReloadAddon()
        {
            AddonLocator.ReCalculateAddonPosition();
            var addonLocation = AddonLocator.GetAddonLocation();
            if (addonLocation.Width == 1 || addonLocation.Height == 1)
            {
                Program.Log("Addon could not be located.", ConsoleColor.Red);
                Program.Log("Make sure it's loaded and visible.", ConsoleColor.Red);
            }
            else
            {
                Program.Log("Addon successfully located:", ConsoleColor.Green);
                Program.Log(addonLocation.ToString(), ConsoleColor.Green);
            }
        }

        public static void ShowHelp()
        {
            Program.Log($@"
Help:

reload addon    -   If this program cant see the addon on startup you will need to run this command.
                    It commands the program to find out where the addon is located on the screen.
            ", ConsoleColor.White);
        }
    }
}
