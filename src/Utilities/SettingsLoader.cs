using Newtonsoft.Json;
using System.IO;

namespace WowCyborg.Utilities
{
    public static class SettingsLoader
    {
        public static T LoadSettings<T>(string filePath)
        {
            using (var sr = new StreamReader(filePath))
            {
                return JsonConvert.DeserializeObject<T>(sr.ReadToEnd());
            }
        }
    }
}
