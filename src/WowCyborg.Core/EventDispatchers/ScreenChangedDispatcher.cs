using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;
using WowCyborg.Core.Handlers;
using WowCyborg.Core.Models.Abstractions;
using WowCyborg.Core.Utilities;

namespace WowCyborg.Core.EventDispatchers
{
    public class ScreenChangedDispatcher : EventDispatcherBase
    {
        public ScreenChangedDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "ScreenChanged";
        }

        protected override void Update()
        {
            var screenshot = CaptureScreenShot();
            if (screenshot.Size == new Size(1, 1))
            {
                return;
            }

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

                var addonLocation = AddonLocator.GetAddonLocation();
                if (addonLocation == Rectangle.Empty)
                {
                    addonLocation = new Rectangle(1, 1, 1, 1);
                }

                clone = bitmap.Clone(addonLocation, PixelFormat.Format24bppRgb);
            }
            return clone;
        }
    }
}
