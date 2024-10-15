using System;
using System.Collections.Generic;
using System.Linq;
using WowCyborg;
using WowCyborg.Models;
using WowCyborg.Utilities;
using WowCyborg.Handlers;
using WowCyborg;
using WowCyborg.Models;
using WowCyborg.BotProfiles;
using WindowResize;
using CombatRotationInstaller;

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
            InitializeBotRunnerByType<AutoCaster>(hWnds);
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
            var input = Console.ReadLine().ToLower().Split(' ');

            var command = input[0];
            if (command == "resize")
            {
                var handler = new GameWindowHandler();
                handler.ReinitializeGameWindows();
            }

            if (command == "rotation")
            {
                var settings = SettingsLoader.LoadSettings<AppSettings>("settings.json");
                var addonInstaller = new WowAddonInstaller(settings.AddonPath);
                addonInstaller.FetchRotations();
                var args = input.ToList().Skip(1).Take(input.Length - 1).ToArray();
                var addonPath = addonInstaller.SetRotation(args[1]);
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
