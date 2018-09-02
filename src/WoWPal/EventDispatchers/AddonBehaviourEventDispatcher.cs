using System;
using System.Drawing;
using WoWPal.Events;
using WoWPal.Events.Abstractions;

namespace WoWPal.EventDispatchers
{
    public abstract class AddonBehaviourEventDispatcher : EventDispatcherBase
    {
        protected Bitmap AddonScreenshot;

        public AddonBehaviourEventDispatcher(Action<Event> onEvent) 
            : base(onEvent)
        {
            EventManager.On("ScreenChanged", (Event ev) => {
                var screenshot = (Bitmap)ev.Data;

                try
                {
                    AddonScreenshot = screenshot.Clone(new Rectangle(0, 0, screenshot.Width, screenshot.Height), screenshot.PixelFormat);
                }
                catch
                {
                    Console.WriteLine("ERROR");
                }
            });
        }

        protected bool AddonIsGreenAt(int x, int y)
        {
            if (AddonScreenshot == null)
            {
                return false;
            }

            var pixel = AddonScreenshot.GetPixel(x, y);
            return pixel.R == 0 && pixel.G > 250 && pixel.B == 0;
        }

        protected bool AddonIsRedAt(int x, int y)
        {
            if (AddonScreenshot == null)
            {
                return false;
            }

            var pixel = AddonScreenshot.GetPixel(x, y);
            return pixel.R > 250 && pixel.G == 0 && pixel.B == 0;
        }
    }
}
