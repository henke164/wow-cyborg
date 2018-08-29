using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;
using WoWPal.Events.Abstractions;

namespace WoWPal.EventDispatchers
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
            TriggerEvent(screenshot);
        }
        
        public override void ReceiveEvent(Event ev)
        {
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

                clone = bitmap.Clone(bounds, PixelFormat.Format24bppRgb);
            }
            return clone;
        }
    }
}
