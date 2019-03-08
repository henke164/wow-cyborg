using System;
using System.Collections.Generic;
using System.Net;
using WowCyborg.Models;
using WowCyborg.Utilities;

namespace WowCyborgUI.Services
{
    public class ApiClient
    {
        private static string _baseUrl;
        public string BaseUrl
        {
            get
            {
                if (string.IsNullOrEmpty(_baseUrl))
                {
                    var settings = SettingsLoader.LoadSettings<AppSettings>("settings.json");
                    _baseUrl = settings.ServerAddress;
                    if (_baseUrl.EndsWith("/"))
                    {
                        _baseUrl = _baseUrl.Substring(0, _baseUrl.Length - 1);
                    }
                }
                return _baseUrl;
            }
        }

        public Dictionary<string, string> GetRotations()
        {
            var rotationDictionary = new Dictionary<string, string>();
            var str = DownloadString("/rotations");
            var rows = str.Split(new string[] { "\r\n" }, StringSplitOptions.None);
            foreach (var row in rows)
            {
                var columns = row.Split('\t');
                rotationDictionary.Add(columns[0], columns[1]);
            }
            return rotationDictionary;
        }

        public TextFile GetFile(string fileName)
            => new TextFile
            {
                FileName = fileName,
                Content = DownloadString($"/file/?file={fileName}")
            };

        public IEnumerable<TextFile> GetAddonFiles()
        {
            var str = DownloadString("/map");
            var fileNames = str.Split(new string[] { "\r\n" }, StringSplitOptions.None);
            foreach (var fileName in fileNames)
            {
                yield return GetFile(fileName);
            }
        }

        private string DownloadString(string path)
        {
            using (var client = new WebClient())
            {
                return client.DownloadString($"{BaseUrl}{path}");
            }
        }
    }
}
