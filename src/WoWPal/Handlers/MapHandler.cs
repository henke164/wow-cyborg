using System.Collections.Generic;
using System.Linq;
using WoWPal.Models;
using WoWPal.Utilities;

namespace WoWPal.Handlers
{
    public class MapHandler
    {
        private List<UiMapId> _uiMapIds;

        public MapHandler()
        {
            _uiMapIds = SettingsLoader.LoadSettings<List<UiMapId>>("uiMapIds.json");
        }

        public string GetMapUrl(int zoneId)
        {
            var map = FindMapById(zoneId);
            if (map == null)
            {
                return "";
            }

            return $"https://wow.zamimg.com/images/wow/maps/enus/zoom/{map.OldId}.jpg";
        }

        public UiMapId FindMapById(int id)
            => _uiMapIds.FirstOrDefault(m => m.Id == id);
    }
}
