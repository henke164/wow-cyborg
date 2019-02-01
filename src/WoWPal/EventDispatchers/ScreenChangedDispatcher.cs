using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;
using WoWPal.Models.Abstractions;
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
            if (_inGameAddonLocation == Rectangle.Empty)
            {
                CalculateAddonPosition();
            }
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

        private void CalculateAddonPosition()
        {
            Bitmap clone;
            var bounds = Screen.GetBounds(Point.Empty);
            var bottomLeft = new Rectangle(0, Screen.PrimaryScreen.Bounds.Height - 100, 500, 100);

            using (var bitmap = new Bitmap(bounds.Width, bounds.Height))
            {
                using (var g = Graphics.FromImage(bitmap))
                {
                    g.CopyFromScreen(Point.Empty, Point.Empty, bounds.Size);
                }
                clone = bitmap.Clone(bottomLeft, PixelFormat.Format24bppRgb);
            }

            var frameSize = CalculateFrameWidth(clone);
            var settings = SettingsLoader.LoadSettings<AppSettings>("settings.json");

            _inGameAddonLocation = new Rectangle(0, 
                Screen.PrimaryScreen.Bounds.Height - frameSize * settings.AddonRowCount, 
                frameSize * settings.AddonColumnCount, 
                frameSize * settings.AddonRowCount);
        }

        private int CalculateFrameWidth(Bitmap b)
        {
            var width = 0;
            for (var x = 0; x < b.Width; x++)
            {
                var px = b.GetPixel(x, b.Height - 5);
                if (px.R <= 250 || px.G > 0 || px.B < 150 || px.B > 200)
                {
                    width = x;
                    break;
                }
            }
            return width / 4;
        }
    }
}
