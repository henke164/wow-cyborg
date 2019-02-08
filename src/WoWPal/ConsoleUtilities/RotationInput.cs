using System;
using System.Collections.Generic;
using System.Linq;

namespace WoWPal.ConsoleUtilities
{
    public static class RotationInput
    {
        public static void HandleInputParameters(string[] parameters)
        {
            var commandParameters = parameters.ToList().Skip(1).ToList();

            if (commandParameters.Count() == 0)
            {
                Program.ShowHelp();
                return;
            }

            switch (commandParameters[0])
            {
                case "list":
                    ListRotations();
                    break;
                case "set":
                    HandleSetCommand(commandParameters);
                    break;
                default:
                    Program.Log("Unknown command", ConsoleColor.Red);
                    break;
            }
        }

        private static void ListRotations()
        {
            Program.Log("Available rotations:", ConsoleColor.Yellow);
            foreach (var rot in AddonInstaller.Rotations)
            {
                Program.Log(rot.Key, ConsoleColor.Yellow);
            }
        }

        private static void HandleSetCommand(List<string> commandParameters)
        {
            if (commandParameters.Count < 2)
            {
                Program.Log("Usage example: 'rotation set furywarrior'", ConsoleColor.Red);
            }

            try
            {
                AddonInstaller.SetRotation(commandParameters[1]);
                Program.Log($"${commandParameters[1]} successfully selected. Run /reload in Wow.", ConsoleColor.Green);
            }
            catch (Exception ex)
            {
                Program.Log($"Error occured: {ex.Message}", ConsoleColor.Red);
            }
        }
    }
}
