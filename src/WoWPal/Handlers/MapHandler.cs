using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Net;
using System.Windows.Forms;
using WoWPal.Models;
using WoWPal.Utilities;

namespace WoWPal.Handlers
{
    public class MapHandler
    {
        private int _currentId;
        private List<UiMapId> _uiMapIds;
        private PictureBox _mapController;

        public MapHandler(PictureBox mapController)
        {
            _mapController = mapController;
            _uiMapIds = SettingsLoader.LoadSettings<List<UiMapId>>("uiMapIds.json");
        }

        public string GetMapUrl(Transform transform)
        {
            var map = FindMapById(transform.ZoneId);
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
