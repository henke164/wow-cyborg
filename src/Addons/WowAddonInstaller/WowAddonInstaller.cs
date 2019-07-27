using System.IO;
using WowCyborg.PluginUtilities;

namespace WowAddonInstaller
{
    public class WowAddonInstaller
    {
        private ApiClient _apiClient;
        private string _addonFolderPath;

        public WowAddonInstaller(string serverUrl, string addonPath)
        {
            _apiClient = new ApiClient(serverUrl);
            _addonFolderPath = addonPath;
        }

        public bool AddonExists()
        {
            var addonFiles = _apiClient.GetAddonFiles();

            foreach (var file in addonFiles)
            {
                if (!File.Exists($"{_addonFolderPath}/{file.FileName}"))
                {
                    return false;
                }
            }

            return true;
        }

        public bool DownloadAddon()
        {
            var addonFiles = _apiClient.GetAddonFiles();
            
            foreach (var file in addonFiles)
            {
                WriteFile($"{_addonFolderPath}/{file.FileName}", file.Content);
            }

            return true;
        }

        private void WriteFile(string fullPath, string content)
        {
            var f = new FileInfo(fullPath);
            f.Directory.Create();
            File.WriteAllText(f.FullName, content);
        }
    }
}
