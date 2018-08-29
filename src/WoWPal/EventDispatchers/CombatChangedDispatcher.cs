using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;
using WoWPal.Events.Abstractions;

namespace WoWPal.EventDispatchers
{
    public class CombatChangedDispatcher : EventDispatcherBase
    {
        private Rectangle _inGameAddonLocation = new Rectangle(0, 450, 300, 200);
        private bool _inCombat = false;

        public CombatChangedDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "CombatChanged";
        }

        protected override void Update()
        {
        }

        public override void ReceiveEvent(Event ev)
        {
            try
            {
                if (ev.Name != "ScreenChanged")
                {
                    return;
                }

                var screenshot = (Bitmap)ev.Data;

                var addonBitmap = screenshot.Clone(_inGameAddonLocation, screenshot.PixelFormat);
                var pixel = addonBitmap.GetPixel(0, 0);

                if (pixel.R == 0 && pixel.G > 250 && pixel.B == 0)
                {
                    if (_inCombat)
                    {
                        _inCombat = false;
                        TriggerEvent(false);
                    }
                }
                else if (!_inCombat)
                {
                    _inCombat = true;
                    TriggerEvent(true);
                }
            }
            catch (Exception ex)
            {

            }
        }
        
        private Bitmap CaptureScreenShot()
        {
            var bounds = Screen.GetBounds(Point.Empty);

            using (var bitmap = new Bitmap(bounds.Width, bounds.Height))
            {
                using (var g = Graphics.FromImage(bitmap))
                {
                    g.CopyFromScreen(Point.Empty, Point.Empty, bounds.Size);
                }

                return bitmap.Clone(bounds, PixelFormat.Format24bppRgb);
            }
        }
    }
}
