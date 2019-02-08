using System;
using WoWPal.ConsoleUtilities;
using WoWPal.Runners;

namespace WoWPal
{
    static class Program
    {
        static void Main()
        {
            ValidateAddonFiles();
            AddonInstaller.DownloadRotations();

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

            ShowHelp();
        }

        static void HandleInput()
        {
            Log(">> ", ConsoleColor.White, true);
            var command = Console.ReadLine().Split(' ');

            switch (command[0])
            {
                case "addon":
                    AddonInput.HandleInputParameters(command);
                    break;

                case "rotation":
                    RotationInput.HandleInputParameters(command);
                    break;

                case "help":
                    ShowHelp();
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
                
        private static void ValidateAddonFiles()
        {
            if (!AddonInstaller.AddonExists())
            {
                Log("Downloading addon files...", ConsoleColor.Green);
                while (!AddonInstaller.DownloadAddon())
                {
                    Log("Press enter to retry...", ConsoleColor.White);
                    Console.ReadLine();
                }
                Log($"Download complete! Restart the game, and make sure you activate the addon: '{AddonInstaller.AddonName}'", ConsoleColor.Green);
            }
        }

        public static void ShowHelp()
        {
            Log($@"
Help:

Commands:                       Description:
----------------------------------------------------------------------------------------------------------------
addon reload                    If this program cant see the addon on startup you will need to run this command.
                                It commands the program to find out where the addon is located on the screen.

rotation list                   Display all available rotations.

rotation set <rotation name>    Set the current rotation.

            ", ConsoleColor.White);
        }
    }
}
