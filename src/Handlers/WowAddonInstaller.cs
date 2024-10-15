using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using WowCyborg.Models;

namespace CombatRotationInstaller
{
    public class WowAddonInstaller
    {
        public List<RotationProfile> Rotations = new List<RotationProfile>();

        private string _addonTemplateFolderPath;
        private string _wowAddonFolderPath;

        public WowAddonInstaller(string addonTemplateFolderPath, string wowAddonFolderPath)
        {
            _addonTemplateFolderPath = addonTemplateFolderPath;
            _wowAddonFolderPath = wowAddonFolderPath;
        }

        public void FetchRotations()
        {
            var files = Directory.GetFiles($"{_addonTemplateFolderPath}/Combat");
            var unnamedIndex = 1;
            foreach (var file in files)
            {
                var rotationFile = File.ReadAllText(file);
                var rotation = new RotationProfile
                { 
                    Path = file,
                };

                var header = rotationFile.Split(new string[] { "]]--" }, StringSplitOptions.None)[0].Replace("--[[", "");
                var nameMatch = Regex.Match(header, @"NAME:\s*(.+)");
                if (nameMatch.Success)
                {
                    rotation.Name = nameMatch.Groups[1].Value.Trim();
                }
                else
                {
                    rotation.Name = $"No name {unnamedIndex++}";
                }

                var iconMatch = Regex.Match(header, @"ICON:\s*(.+)");
                if (iconMatch.Success)
                {
                    rotation.ImageUrl = iconMatch.Groups[1].Value.Trim();
                }

                Rotations.Add(rotation);
            }
        }

        public string GetRotationInstructions(string rotationFilePath)
        {
            using (var sr = new StreamReader(rotationFilePath))
            {
                var content = sr.ReadToEnd();
                return content.Split(new string[] { "]]--" }, StringSplitOptions.None)[0].Replace("--[[", "");
            }
        }

        public bool SetRotation(RotationProfile profile)
        {
            if (string.IsNullOrEmpty(_addonTemplateFolderPath))
            {
                return false;
            }

            var rotationFile = File.ReadAllText(profile.Path);
            var addonPath = $"{_wowAddonFolderPath}/Combat/Rotation.lua";
            WriteFile(addonPath, rotationFile);
            return true;
        }

        private static void WriteFile(string fullPath, string content)
        {
            var f = new FileInfo(fullPath);
            f.Directory.Create();
            File.WriteAllText(f.FullName, content);
        }
    }
}
