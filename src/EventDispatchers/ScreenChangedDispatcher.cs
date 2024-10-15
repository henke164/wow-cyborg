using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using WowCyborg.Handlers;
using WowCyborg.Models.Abstractions;
using WowCyborg.Utilities;

namespace WowCyborg.EventDispatchers
{
    public class ScreenChangedDispatcher : EventDispatcherBase
    {
        private Dictionary<IntPtr, Bitmap> _screenshots;
        private Rectangle _screenbounds;
        
        public ScreenChangedDispatcher()
            : base()
        {
            EventName = "ScreenChanged";
            _screenbounds = ScreenUtilities.GetScreenBounds();
        }

        protected override void Update()
        {
            _screenshots = CaptureScreenShots();
        }

        protected override void GameHandleUpdate(IntPtr hWnd)
        {
            using (var screenshot = (Bitmap)_screenshots[hWnd].Clone())
            {
                TriggerEvent(hWnd, screenshot);
            }
        }

        public Dictionary<IntPtr, Bitmap> CaptureScreenShots()
        {
            var screenshots = new Dictionary<IntPtr, Bitmap>();
            var addonLocations = AddonLocator.GetAddonLocations();

            using (var bitmap = new Bitmap(_screenbounds.Width, _screenbounds.Height))
            {
                using (var g = Graphics.FromImage(bitmap))
                {
                    g.CopyFromScreen(Point.Empty, Point.Empty, _screenbounds.Size);
                }

                foreach (var hWnd in addonLocations.Keys)
                {
                    Bitmap clone;

                    if (addonLocations[hWnd] == Rectangle.Empty)
                    {
                        clone = bitmap.Clone(new Rectangle(1, 1, 1, 1), PixelFormat.Format24bppRgb);
                    }
                    else
                    {
                        clone = bitmap.Clone(addonLocations[hWnd], PixelFormat.Format24bppRgb);
                    }

                    screenshots.Add(hWnd, clone);
                }
            }

            return screenshots;
        }
    }
}
