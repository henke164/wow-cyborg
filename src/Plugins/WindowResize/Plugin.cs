using System;
using WowCyborg.PluginUtilities;
using WowCyborg.PluginUtilities.Models;

namespace WindowResize
{
    public class Plugin : PluginBase
    {
        public Plugin(ApplicationSettings settings)
            : base(settings)
        {
        }

        public override bool HandleInput(string command, string[] args)
        {
            if (command != "window")
            {
                return false;
            }

            if (args[0] == "resize")
            {
                var handler = new GameWindowHandler();
                handler.ReinitializeGameWindows();
                return true;
            }
            else
            {
                Console.WriteLine("Unknown command", ConsoleColor.Red);
            }

            return true;
        }

        public override void ShowCommands()
        {
            Logger.Log($@"
window resize                    Autosize windows (for multiple windows).
            ");
        }
    }
}
