using System;
using System.Collections.Generic;
using System.Linq;
using WowCyborg.Core;
using WowCyborg.Core.Models;
using WowCyborg.Core.Utilities;
using WowCyborg.Core.Handlers;
using WowCyborg.PluginUtilities;
using WowCyborg.PluginUtilities.Models;
using WowCyborg.BotProfiles;

namespace WowCyborg
{
    class Program
    {
        public static IList<PluginBase> Plugins = new List<PluginBase>();

        public static Bot BotRunner;

        static void Main()
        {
            AddonLocator.InitializeGameHandle();

            var settings = SettingsLoader.LoadSettings<AppSettings>("settings.json");
            InitializeBotRunner(settings);
            Plugins = PluginLoader.GetPlugins(GetApplicationSettings(settings));
            RenderStartMessage();
            HandleInput();
        }

        static void InitializeBotRunner(AppSettings settings)
        {
            switch (settings.BotType)
            {
                case "soloRunner":
                    BotRunner = new SoloRunner();
                    break;
                case "follower":
                    BotRunner = new BotFollower();
                    break;
                default:
                    BotRunner = new AutoCaster();
                    break;
            }
        }

        static ApplicationSettings GetApplicationSettings(AppSettings settings)
        {
            return new ApplicationSettings
            {
                ServerUrl = settings.ServerAddress,
                WowAddonPath = $"{AddonFolderHandler.GetAddonFolderPath()}\\MazonAddon",
                Bot = BotRunner
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
