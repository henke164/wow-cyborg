using System;
using WoWPal.Handlers;

namespace WoWPal
{
    public static class InputHandler
    {
        public static void AddonReload()
        {
            AddonLocator.ReCalculateAddonPosition();
            var addonLocation = AddonLocator.GetAddonLocation();
            if (addonLocation.Width == 1 || addonLocation.Height == 1)
            {
                Program.Log("Addon could not be located, make sure it's loaded and visible.", ConsoleColor.Red);
            }
            else
            {
                Program.Log("Addon successfully located:", ConsoleColor.Green);
                Program.Log(addonLocation.ToString(), ConsoleColor.Green);
            }
        }

    }
}
