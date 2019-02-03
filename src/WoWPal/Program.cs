using System;
using System.Drawing;
using WoWPal.Handlers;
using WoWPal.Runners;

namespace WoWPal
{
    static class Program
    {
        static void Main()
        {
            var botRunner = new AutoCaster();
            RenderStartMessage();
            HandleInput();
        }

        static void RenderStartMessage()
        {
            Log($@"
 __      __             _________        ___.                        
/  \    /  \______  _  _\_   ___ \___.__.\_ |__   ___________  ____  
\   \/\/   /  _ \ \/ \/ /    \  \<   |  | | __ \ /  _ \_  __ \/ ___\ 
 \        (  <_> )     /\     \___\___  | | \_\ (  <_> )  | \/ /_/  >
  \__/\  / \____/ \/\_/  \______  / ____| |___  /\____/|__|  \___  / 
       \/                       \/\/          \/            /_____/  
-----------------------------------------------------------------------
            ", ConsoleColor.Yellow);

            InputHandler.ShowHelp();
        }

        static void HandleInput()
        {
            Log(">> ", ConsoleColor.White, true);
            var command = Console.ReadLine();

            switch (command.ToLower())
            {
                case "reload addon":
                    InputHandler.ReloadAddon();
                    break;

                case "help":
                    InputHandler.ShowHelp();
                    break;

                default:
                    Log("Unknown command", ConsoleColor.Red);
                    break;
            }

            HandleInput();
        }

        public static void Log(string str, ConsoleColor color, bool inLine = false)
        {
            Console.ForegroundColor = color;
            if (inLine)
            {
                Console.Write(str);
                return;
            }
            Console.WriteLine(str);
        }
    }
}
