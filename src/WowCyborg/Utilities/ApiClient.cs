using System;
using System.Collections.Generic;
using System.IO;
using WowCyborg.Models;
using WowCyborg.Utilities;

namespace WowCyborg
{
    public class ApiClient
    {
        private AppSettings _appSettings;

        public ApiClient()
        {
            _appSettings = SettingsLoader.LoadSettings<AppSettings>("settings.json");
        }

        public ServerTextFile GetFile(string fileName)
            => new ServerTextFile
            {
                FileName = fileName,
                Content = DownloadString($"/file/?file={fileName}")
            };

        public IEnumerable<ServerTextFile> GetAddonFiles()
        {
            var str = DownloadString("/map");
            var fileNames = str.Split(new string[] { "\r\n" }, StringSplitOptions.None);
            foreach (var fileName in fileNames)
            {
                yield return GetFile(fileName);
            }
        }

        public Dictionary<string, string> GetFilesMap(string path)
        {
            var rotationDictionary = new Dictionary<string, string>();
            var str = DownloadString($"/{path}");
            var rows = str.Split(new string[] { "\r\n" }, StringSplitOptions.None);
            foreach (var row in rows)
            {
                var columns = row.Split('\t');
                rotationDictionary.Add(columns[0], columns[1]);
            }
            return rotationDictionary;
        }   

        protected string DownloadString(string path)
        {
            var addonFilePath = "";
            if (path == "/map")
            {
                addonFilePath = $"{_appSettings.AddonPath}/addon-map.txt";
            }
            else if (path == "/rotations")
            {
                addonFilePath = $"{_appSettings.AddonPath}/rotation-map.txt";
            }
            else
            {
                addonFilePath = path.Replace("/file/?file=MazonAddon", _appSettings.AddonPath);
            }

            using (var sr = new StreamReader(addonFilePath))
            {
                return sr.ReadToEnd();
            }
        }
    }
}
