using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using WowCyborg.Models;
using WowCyborg.UI;

namespace CombatRotationInstaller
{
    public class WowRotationInstaller
    {
        public List<RotationProfile> Rotations = new List<RotationProfile>();

        private string _wowAddonFolderPath;

        public WowRotationInstaller(string wowAddonFolderPath)
        {
            _wowAddonFolderPath = wowAddonFolderPath;
        }

        public void CreateNewRotation(string filename, string name, string icon = "inv_misc_questionmark")
        {
            var filePath = $"{Program.AddonSourcePath}/Combat/{filename}.lua";
            var content = ($@"
--[[
NAME: {name}
ICON: {icon}
]]--
local buttons = {{}}

WowCyborg_PAUSE_KEYS = {{
}}

function RenderMultiTargetRotation()
end

function RenderSingleTargetRotation()
end

print(""{name} rotation loaded"");
            ");


            File.WriteAllText(filePath, content);
        }
        
        public RotationProfile GetCurrentRotation()
        {
            try
            {
                var addonPath = $"{_wowAddonFolderPath}/MazonAddon/Combat/Rotation.lua";
                var rotationFile = File.ReadAllText(addonPath);
                var header = rotationFile.Split(new string[] { "]]--" }, StringSplitOptions.None)[0].Replace("--[[", "");
                var nameMatch = Regex.Match(header, @"NAME:\s*(.+)");
                if (nameMatch.Success)
                {
                    var name = nameMatch.Groups[1].Value.Trim();
                    var rotation = Rotations.FirstOrDefault(r => r.Name == name);
                    return rotation;
                }
            }
            catch (Exception ex)
            {
            }
            return null;
        }

        public void FetchRotations()
        {
            var files = Directory.GetFiles($"{Program.AddonSourcePath}/Combat");

            var unnamedIndex = 1;
            foreach (var file in files)
            {
                if (file.EndsWith("Shared.lua"))
                {
                    continue;
                }

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
                    rotation.ImageUrl = $"https://wow.zamimg.com/images/wow/icons/large/{iconMatch.Groups[1].Value.Trim()}.jpg";
                }

                Rotations.Add(rotation);
            }
        }

        public bool SetRotation(RotationProfile profile)
        {
            if (string.IsNullOrEmpty(Program.AddonSourcePath))
            {
                return false;
            }

            CopyDirectory(Program.AddonSourcePath, $"{_wowAddonFolderPath}/MazonAddon");

            var rotationFile = File.ReadAllText(profile.Path);
            var addonPath = $"{_wowAddonFolderPath}/MazonAddon/Combat/Rotation.lua";
            WriteFile(addonPath, rotationFile);
            return true;
        }

        private static void WriteFile(string fullPath, string content)
        {
            var f = new FileInfo(fullPath);
            f.Directory.Create();
            File.WriteAllText(f.FullName, content);
        }

        public static void CopyDirectory(string sourceDir, string destinationDir)
        {
            if (!Directory.Exists(destinationDir))
            {
                Directory.CreateDirectory(destinationDir);
            }

            if (sourceDir.EndsWith("Combat"))
            {
                return;
            }

            foreach (string file in Directory.GetFiles(sourceDir))
            {
                string fileName = Path.GetFileName(file);
                string destFile = Path.Combine(destinationDir, fileName);
                File.Copy(file, destFile, true);
            }

            foreach (string dir in Directory.GetDirectories(sourceDir))
            {
                string dirName = Path.GetFileName(dir);
                string destDir = Path.Combine(destinationDir, dirName);
                CopyDirectory(dir, destDir);
            }
        }

    }
}
