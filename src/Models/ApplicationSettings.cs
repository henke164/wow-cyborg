using System.Collections.Generic;
using WowCyborg;

namespace WowCyborg.Models
{
    public class ApplicationSettings
    {
        public IList<Bot> Bots { get; set; }
        public string WowAddonPath { get; set; }
        public string ServerUrl { get; set; }
    }
}
