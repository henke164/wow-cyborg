using System;
using WowCyborgAddonUtilities;

namespace ServerController
{
    public class Plugin : PluginBase
    {
        private ServerManager _serverManager;

        public Plugin(ApplicationSettings settings)
        {
            _serverManager = new ServerManager(settings.BotApi);
        }

        public override bool HandleInput(string command, string[] args)
        {
            if (command != "server")
            {
                return false;
            }


            switch (args[0])
            {
                case "start":
                    _serverManager.StartServer();
                    break;
                case "stop":
                    _serverManager.StopServer();
                    break;
                default:
                    Console.WriteLine("Unknown command", ConsoleColor.Red);
                    break;
            }

            return true;
        }

        public override void ShowCommands()
        {
            Logger.Log($@"
server start                    Starts a server on localhost with endpoints to control the bot.

server stop                     Stops the running server.
            ");
        }
    }
}
