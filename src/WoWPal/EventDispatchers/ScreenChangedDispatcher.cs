using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;
using WoWPal.Events.Abstractions;
using WoWPal.Models;
using WoWPal.Utilities;

namespace WoWPal.EventDispatchers
{
    public class ScreenChangedDispatcher : EventDispatcherBase
    {
        Rectangle _inGameAddonLocation;

        public ScreenChangedDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "ScreenChanged";

            var settings = SettingsLoader.LoadSettings<AppSettings>("settings.json");
            var position = settings.AddonPosition;
            _inGameAddonLocation = new Rectangle(position.X, position.Y, position.Width, position.Height);
        }

        protected override void Update()
        {
            var screenshot = CaptureScreenShot();
            TriggerEvent(screenshot);
        }
        
        public Bitmap CaptureScreenShot()
        {
            Bitmap clone;
            var bounds = Screen.GetBounds(Point.Empty);

            using (var bitmap = new Bitmap(bounds.Width, bounds.Height))
            {
                using (var g = Graphics.FromImage(bitmap))
                {
                    g.CopyFromScreen(Point.Empty, Point.Empty, bounds.Size);
                }
                clone = bitmap.Clone(_inGameAddonLocation, PixelFormat.Format24bppRgb);
            }

            return clone;
        }
    }
}
