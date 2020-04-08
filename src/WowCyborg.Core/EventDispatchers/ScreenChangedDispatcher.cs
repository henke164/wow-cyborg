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
        private Rectangle _screenbounds;

        public ScreenChangedDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "ScreenChanged";
            _screenbounds = ScreenUtilities.GetScreenBounds();
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
            using (var bitmap = new Bitmap(_screenbounds.Width, _screenbounds.Height))
            {
                using (var g = Graphics.FromImage(bitmap))
                {
                    g.CopyFromScreen(Point.Empty, Point.Empty, _screenbounds.Size);
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
