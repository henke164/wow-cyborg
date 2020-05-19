using System;
using WowCyborg.PluginUtilities;
using WowCyborg.PluginUtilities.Models;

namespace ServerController
{
    public class Plugin : PluginBase
    {
        private ServerManager _serverManager;

        public Plugin(ApplicationSettings settings)
            : base(settings)
        {
            _serverManager = new ServerManager(Settings.Bots);
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
                    _serverManager.StartServer(args[1]);
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
server start 3000               Starts a server on localhost port 3000 with endpoints to control the bot.

server stop                     Stops the running server.
            ");
        }
    }
}
