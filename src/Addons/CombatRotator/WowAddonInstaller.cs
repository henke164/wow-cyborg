using System;
using System.Collections.Generic;
using System.IO;
using WowCyborgAddonUtilities;

namespace CombatRotator
{
    public class WowAddonInstaller
    {
        public Dictionary<string, string> Rotations = new Dictionary<string, string>();

        private string _addonFolderPath;

        private ApiClient _apiClient;

        public WowAddonInstaller(string serverUrl, string addonFolderPath)
        {
            _addonFolderPath = addonFolderPath;
            _apiClient = new ApiClient(serverUrl);
        }

        public void FetchRotations()
        {
            Console.WriteLine("Downloading rotations...");
            Rotations = _apiClient.GetFilesMap("rotations");
            Console.WriteLine($"Successfully downloaded {Rotations.Count} rotations");
        }

        public string GetRotationInstructions()
        {
            var rotationFile = $"{_addonFolderPath}/Combat/Rotation.lua";
            using (var sr = new StreamReader(rotationFile))
            {
                var content = sr.ReadToEnd();
                return content.Split(new string[] { "]]--" }, StringSplitOptions.None)[0].Replace("--[[", "");
            }
        }

        public void SetRotation(string rotationName)
        {
            if (string.IsNullOrEmpty(_addonFolderPath))
            {
                Console.WriteLine($"Addon folder location is not located. Try again when WoW is running.", ConsoleColor.Red);
                return;
            }

            var fileName = Rotations[rotationName];
            
            var rotationFile = _apiClient.GetFile(fileName);

            WriteFile($"{_addonFolderPath}/Combat/Rotation.lua", rotationFile.Content);
        }

        private static void WriteFile(string fullPath, string content)
        {
            var f = new FileInfo(fullPath);
            f.Directory.Create();
            File.WriteAllText(f.FullName, content);
        }
    }
}
