using System.Collections.Generic;
using WowCyborg.Core;

namespace WowCyborg.PluginUtilities.Models
{
    public class ApplicationSettings
    {
        public IList<Bot> Bots { get; set; }
        public string WowAddonPath { get; set; }
        public string ServerUrl { get; set; }
    }
}
