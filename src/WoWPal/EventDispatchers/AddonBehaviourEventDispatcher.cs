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
    }
}
