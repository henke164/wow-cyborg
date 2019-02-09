using System;
using System.Collections.Generic;
using System.Net;
using WoWPal.Models;

namespace WoWPal.ConsoleUtilities
{
    public class ApiClient
    {
        public string BaseUrl { get; set; } = "http://localhost:3000";

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
