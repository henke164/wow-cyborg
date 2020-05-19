using System;
using System.Collections;
using System.Collections.Generic;
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
            TriggerEvent(hWnd, _screenshots[hWnd]);
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
