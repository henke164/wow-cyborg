using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using WowCyborg.Handlers;
using WowCyborg.Models;
using WowCyborg.Runners;
using WowCyborg.Utilities;
using WowCyborgAddonUtilities;

namespace WowCyborgUI
{
    class Program
    {
        public static IList<PluginBase> Plugins = new List<PluginBase>();

        public static BotRunnerBase BotRunner;

        static void Main()
        {
            AddonLocator.InitializeGameHandle();
            BotRunner = new AutoCaster();
            Plugins = PluginLoader.GetPlugins(GetApplicationSettings());
            RenderStartMessage();
            HandleInput();
        }

        static ApplicationSettings GetApplicationSettings()
        {
            var settings = SettingsLoader.LoadSettings<AppSettings>("settings.json");
            return new ApplicationSettings
            {
                ServerUrl = settings.ServerAddress,
                WowAddonPath = $"{AddonFolderHandler.GetAddonFolderPath()}\\MazonAddon",
                BotApi = new BotApi(BotRunner)
            };
        }

        static void HandleInput()
        {
            Logger.Log(">> ", ConsoleColor.White, true);
            var input = Console.ReadLine().Split(' ');

            foreach (var plugin in Plugins)
            {
                var command = input[0];
                var args = input.ToList().Skip(1).Take(input.Length - 1).ToArray();
                plugin.HandleInput(command, args);
            }

            HandleInput();
        }

        private static void RenderStartMessage()
        {
            Logger.Log($@"
 __      __             _________        ___.                        
/  \    /  \______  _  _\_   ___ \___.__.\_ |__   ___________  ____  
\   \/\/   /  _ \ \/ \/ /    \  \<   |  | | __ \ /  _ \_  __ \/ ___\ 
 \        (  <_> )     /\     \___\___  | | \_\ (  <_> )  | \/ /_/  >
  \__/\  / \____/ \/\_/  \______  / ____| |___  /\____/|__|  \___  / 
       \/                       \/\/          \/            /_____/  
-----------------------------------------------------------------------
            ", ConsoleColor.Yellow);

            Logger.Log($@"
Help:

Commands:                       Description:
----------------------------------------------------------------------------------------------------------------
            ", ConsoleColor.White);

            foreach (var plugin in Plugins)
            {
                plugin.ShowCommands();
            }
        }
    }
}
