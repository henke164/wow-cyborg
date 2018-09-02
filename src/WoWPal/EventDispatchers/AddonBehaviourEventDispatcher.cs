using System;
using System.Drawing;
using WoWPal.Events;
using WoWPal.Events.Abstractions;
using WoWPal.Models;
using WoWPal.Utilities;

namespace WoWPal.EventDispatchers
{
    public abstract class AddonBehaviourEventDispatcher : EventDispatcherBase
    {
        protected Bitmap AddonScreenshot;

        public AddonBehaviourEventDispatcher(Action<Event> onEvent) 
            : base(onEvent)
        {
            var settings = SettingsLoader.LoadSettings<AddonSettings>("addonsettings.json");
            var inGameAddonLocation = new Rectangle(settings.X, settings.Y, settings.Width, settings.Height);
            
            EventManager.On("ScreenChanged", (Event ev) => {
                var screenshot = (Bitmap)ev.Data;
                AddonScreenshot = screenshot.Clone(inGameAddonLocation, screenshot.PixelFormat);
            });
        }

        protected bool AddonIsGreenAt(int x, int y)
        {
            var pixel = AddonScreenshot.GetPixel(x, y);
            return pixel.R == 0 && pixel.G > 250 && pixel.B == 0;
        }

        protected bool AddonIsRedAt(int x, int y)
        {
            var pixel = AddonScreenshot.GetPixel(x, y);
            return pixel.R > 250 && pixel.G == 0 && pixel.B == 0;
        }
    }
}
