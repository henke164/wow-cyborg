using System;
using System.Diagnostics;
using System.IO;
using System.Linq;

namespace WowCyborg.Handlers
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
                process = Process.GetProcessesByName("WoWB").FirstOrDefault();
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
                _addonFolderPath = addonPath;
            }
        }
    }
}
