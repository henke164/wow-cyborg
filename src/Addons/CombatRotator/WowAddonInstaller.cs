using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using WowCyborg.PluginUtilities;

namespace CombatRotationInstaller
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

        public string GetRotationInstructions(string rotationFilePath)
        {
            using (var sr = new StreamReader(rotationFilePath))
            {
                var content = sr.ReadToEnd();
                return content.Split(new string[] { "]]--" }, StringSplitOptions.None)[0].Replace("--[[", "");
            }
        }

        public string SetRotation(string rotationName)
        {
            if (string.IsNullOrEmpty(_addonFolderPath))
            {
                Console.WriteLine($"Addon folder location is not located. Try again when WoW is running.", ConsoleColor.Red);
                return string.Empty;
            }

            var fileName = Rotations[rotationName];
            
            var rotationFile = _apiClient.GetFile(fileName);
            var filePathArray = rotationFile.FileName.Split('/').ToList();
            var filePath = string.Join("/", filePathArray.Take(filePathArray.Count() - 1));
            var addonPath = $"{_addonFolderPath}/{filePath}/Rotation.lua";
            WriteFile(addonPath, rotationFile.Content);
            return addonPath;
        }

        private static void WriteFile(string fullPath, string content)
        {
            var f = new FileInfo(fullPath);
            f.Directory.Create();
            File.WriteAllText(f.FullName, content);
        }
    }
}
