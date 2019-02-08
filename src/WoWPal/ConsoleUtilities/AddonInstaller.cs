using System;
using System.Collections.Generic;
using System.IO;
using WoWPal.Handlers;

namespace WoWPal.ConsoleUtilities
{
    public static class AddonInstaller
    {
        public static string AddonName = "MazonAddon";
        public static Dictionary<string, string> Rotations = new Dictionary<string, string>();

        public static void DownloadRotations()
        {
            var client = new ApiClient();
            Rotations = client.GetRotations();
        }

        public static bool AddonExists()
        {
            var client = new ApiClient();

            var addonFiles = client.GetAddonFiles();

            var addonFolderPath = AddonFolderHandler.GetAddonFolderPath();

            foreach (var file in addonFiles)
            {
                if (!File.Exists($"{addonFolderPath}/{AddonName}/{file.FileName}"))
                {
                    return false;
                }
            }

            return true;
        }

        public static bool DownloadAddon()
        {
            var client = new ApiClient();

            var addonFiles = client.GetAddonFiles();

            var addonFolderPath = AddonFolderHandler.GetAddonFolderPath();

            if (string.IsNullOrEmpty(addonFolderPath))
            {
                Program.Log($"Addon folder location is not located. Try again when WoW is running.", ConsoleColor.Red);
                return false;
            }

            foreach (var file in addonFiles)
            {
                WriteFile($"{addonFolderPath}/{AddonName}/{file.FileName}", file.Content);
            }

            return true;
        }

        public static string GetRotationInstructions()
        {
            var addonFolderPath = AddonFolderHandler.GetAddonFolderPath();

            if (string.IsNullOrEmpty(addonFolderPath))
            {
                Program.Log($"Addon folder location is not located. Try again when WoW is running.", ConsoleColor.Red);
                return "";
            }

            var rotationFile = $"{addonFolderPath}/{AddonName}/Combat/Rotation.lua";
            using (var sr = new StreamReader(rotationFile))
            {
                var content = sr.ReadToEnd();
                return content.Split(new string[] { "]]--" }, StringSplitOptions.None)[0].Replace("--[[", "");
            }
        }

        public static void SetRotation(string rotationName)
        {
            if (!Rotations.ContainsKey(rotationName))
            {
                Program.Log($"Could not find '{rotationName}'.", ConsoleColor.Red);
                return;
            }

            var addonFolderPath = AddonFolderHandler.GetAddonFolderPath();

            if (string.IsNullOrEmpty(addonFolderPath))
            {
                Program.Log($"Addon folder location is not located. Try again when WoW is running.", ConsoleColor.Red);
                return;
            }

            var fileName = Rotations[rotationName];

            var client = new ApiClient();

            var rotationFile = client.GetFile(fileName);

            WriteFile($"{addonFolderPath}/{AddonName}/Combat/Rotation.lua", rotationFile.Content);
        }

        private static void WriteFile(string fullPath, string content)
        {
            var f = new FileInfo(fullPath);
            f.Directory.Create();
            File.WriteAllText(f.FullName, content);
        }
    }
}
