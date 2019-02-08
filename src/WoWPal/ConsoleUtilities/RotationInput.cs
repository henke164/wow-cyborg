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
                Program.Log($"{commandParameters[1]} successfully selected.", ConsoleColor.Green);

                Program.Log($"Run /reload command in WoW", ConsoleColor.White);
                Program.Log($"The 'Single target'/'Multi target' bar is draggable.", ConsoleColor.White);
                Program.Log($"Press Caps Lock to toggle between single or multi target.", ConsoleColor.White);
                Program.Log($"------------------------", ConsoleColor.Yellow);
                Program.Log($"Setup your keybindings to following:", ConsoleColor.Yellow);
                Program.Log(AddonInstaller.GetRotationInstructions(), ConsoleColor.Yellow);
            }
            catch (Exception ex)
            {
                Program.Log($"Error occured: {ex.Message}", ConsoleColor.Red);
            }
        }
    }
}
