using System;
using System.Drawing;
using WoWPal.Handlers;
using WoWPal.Models.Abstractions;

namespace WoWPal.EventDispatchers
{
    public abstract class AddonBehaviourEventDispatcher : EventDispatcherBase
    {
        private static int AddonColorRows = 9;
        private static int AddonColorColumns = 4;

        protected Bitmap AddonScreenshot;

        public AddonBehaviourEventDispatcher(Action<Event> onEvent) 
            : base(onEvent)
        {
            AddonScreenshot = new Bitmap(1, 1);
            AddonScreenshot.SetPixel(0, 0, Color.White);

            EventManager.On("ScreenChanged", (Event ev) => {
                var screenshot = (Bitmap)ev.Data;

                try
                {
                    AddonScreenshot = screenshot;//.Clone(new Rectangle(0, 0, screenshot.Width, screenshot.Height), screenshot.PixelFormat);
                }
                catch
                {
                    Console.WriteLine("ERROR");
                }
            });
        }

        protected bool AddonIsGreenAt(int x, int y)
        {
            if (AddonScreenshot.Width == 1 || AddonScreenshot.Height == 1)
            {
                return false;
            }

            var frameWidth = AddonScreenshot.Width / AddonColorColumns;
            var frameHeight = AddonScreenshot.Height / AddonColorRows;
            var xPos = (frameWidth * x);
            var yPos = (frameHeight * y);

            var pixel = AddonScreenshot.GetPixel(
                xPos > 0 ? xPos : 1,
                yPos > 0 ? yPos : 1);

            return pixel.R == 0 && pixel.G > 250 && pixel.B == 0;
        }

        protected bool AddonIsRedAt(int x, int y)
        {
            if (AddonScreenshot.Width == 1 || AddonScreenshot.Height == 1)
            {
                return false;
            }

            var frameWidth = AddonScreenshot.Width / AddonColorColumns;
            var frameHeight = AddonScreenshot.Height / AddonColorRows;
            var xPos = (frameWidth * x);
            var yPos = (frameHeight * y);

            var pixel = AddonScreenshot.GetPixel(
                xPos > 0 ? xPos : 1,
                yPos > 0 ? yPos : 1);

            return pixel.R > 250 && pixel.G == 0 && pixel.B == 0;
        }
        
        protected string GetCharacterAt(int x, int y)
        {
            var frameWidth = AddonScreenshot.Width / AddonColorColumns;
            var frameHeight = AddonScreenshot.Height / AddonColorRows;
            var xPos = (frameWidth * x);
            var yPos = (frameHeight * y);

            var color = AddonScreenshot.GetPixel(
                xPos > 0 ? xPos : 1,
                yPos > 0 ? yPos : 1);

            return GetCharacterFromColor(color);
        }

        private string GetCharacterFromColor(Color c)
        {
            if (c.R == 0 && c.G == 0 && c.B == 0)
            {
                return "0";
            }

            if (c.R == 0 && c.G == 0 && c.B > 100 && c.B < 200)
            {
                return "1";
            }

            if (c.R == 0 && c.G == 0 && c.B > 200)
            {
                return "2";
            }

            if (c.R == 0 && c.G > 100 && c.G < 200 && c.B == 0)
            {
                return "3";
            }

            if (c.R == 0 && c.G > 200 && c.B == 0)
            {
                return "4";
            }

            if (c.R > 100 && c.R < 200 && c.G == 0 && c.B == 0)
            {
                return "5";
            }

            if (c.R > 200 && c.G == 0 && c.B == 0)
            {
                return "6";
            }

            if (c.R == 0 && c.G > 100 && c.G < 200 && c.B > 200)
            {
                return "7";
            }

            if (c.R == 0 && c.G > 200 && c.B > 200)
            {
                return "8";
            }

            if (c.R > 100 && c.R < 200 && c.G == 0 && c.B > 200)
            {
                return "9";
            }

            return "";
        }
    }
}
