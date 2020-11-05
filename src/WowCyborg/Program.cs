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

        public static IList<Bot> BotRunners;

        static void Main()
        {
            var gameHandles = AddonLocator.InitializeGameHandles();

            var settings = SettingsLoader.LoadSettings<AppSettings>("settings.json");
            InitializeBotRunner(gameHandles, settings);
            Plugins = PluginLoader.GetPlugins(GetApplicationSettings(settings));
            RenderStartMessage();
            HandleInput();
        }

        static void InitializeBotRunnerByType<T>(IList<IntPtr> hWnds)
            where T : Bot
        {
            BotRunners = new List<Bot>();
            foreach (var hWnd in hWnds)
            {
                BotRunners.Add((T)Activator.CreateInstance(typeof(T), hWnd));
            }
        }

        static void InitializeBotRunner(IList<IntPtr> hWnds, AppSettings settings)
        {
            switch (settings.BotType.ToLower())
            {
                case "solorunner":
                    Console.Write("Solo runner");
                    InitializeBotRunnerByType<SoloRunner>(hWnds);
                    break;
                case "follower":
                    Console.Write("Follower");
                    InitializeBotRunnerByType<BotFollower>(hWnds);
                    break;
                case "pvp":
                    Console.Write("Pvp");
                    InitializeBotRunnerByType<PVP>(hWnds);
                    break;
                case "expedition":
                    Console.Write("Expedition");
                    InitializeBotRunnerByType<Expedition>(hWnds);
                    break;
                case "looter":
                    Console.Write("Looter");
                    InitializeBotRunnerByType<Looter>(hWnds);
                    break;
                default:
                    Console.Write("Autocaster");
                    InitializeBotRunnerByType<AutoCaster>(hWnds);
                    break;
            }
        }

        static ApplicationSettings GetApplicationSettings(AppSettings settings)
        {
            return new ApplicationSettings
            {
                ServerUrl = settings.ServerAddress,
                WowAddonPath = $"{AddonFolderHandler.GetAddonFolderPath()}",
                Bots = BotRunners
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
