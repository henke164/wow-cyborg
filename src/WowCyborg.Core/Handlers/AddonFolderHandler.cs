using System;
using System.Diagnostics;
using System.IO;
using System.Linq;

namespace WowCyborg.Core.Handlers
{
    public class AddonFolderHandler
    {
        private static string _addonFolderPath;

        public static string GetAddonFolderPath()
        {
            if (string.IsNullOrEmpty(_addonFolderPath))
            {
                LocateAddonFolderPath();
            }

            return _addonFolderPath;
        }

        public static void LocateAddonFolderPath()
        {
            var process = Process.GetProcessesByName("WoW").FirstOrDefault();

            if (process == null)
            {
                process = Process.GetProcessesByName("WoWT").FirstOrDefault();
            }

            if (process == null)
            {
                process = Process.GetProcessesByName("WoWClassic").FirstOrDefault();
            }

            if (process != null)
            {
                var file = new FileInfo(process.MainModule.FileName);
                var folder = file.Directory;
                var addonPath = Path.Combine(folder.FullName, "Interface", "Addons");
                if (Directory.Exists(addonPath))
                {
                    _addonFolderPath = addonPath;
                }
            }
        }

    }
}
