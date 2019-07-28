using System;
using System.Drawing;
using System.Windows.Forms;
using WowCyborg.Core.Handlers;
using WowCyborg.Core.Models;
using WowCyborg.Core.Models.Abstractions;
using WowCyborg.Core.Utilities;

namespace WowCyborg.Core.EventDispatchers
{
    public abstract class AddonBehaviourEventDispatcher : EventDispatcherBase
    {
        protected Bitmap AddonScreenshot;
        protected Size AddonScreenshotSize;
        private AppSettings _appSettings;

        public AddonBehaviourEventDispatcher(Action<Event> onEvent) 
            : base(onEvent)
        {
            _appSettings = SettingsLoader.LoadSettings<AppSettings>("settings.json");
            AddonScreenshot = new Bitmap(1, 1);
            AddonScreenshot.SetPixel(0, 0, Color.White);

            EventManager.On("ScreenChanged", (Event ev) => {
                var screenshot = (Bitmap)((Bitmap)ev.Data).Clone();

                try
                {
                    AddonScreenshot = screenshot;
                    AddonScreenshotSize = screenshot.Size;
                }
                catch(Exception ex)
                {
                }
            });
        }

        protected bool AddonIsGreenAt(int x, int y)
        {
            if (AddonScreenshotSize.Width <= 1 || AddonScreenshotSize.Height <= 1)
            {
                return false;
            }

            var color = GetColorAt(x, y);

            return color.R == 0 && color.G > 250 && color.B == 0;
        }

        protected bool AddonIsRedAt(int x, int y)
        {
            if (AddonScreenshotSize.Width <= 1 || AddonScreenshotSize.Height <= 1)
            {
                return false;
            }

            var color = GetColorAt(x, y);

            return color.R > 250 && color.G == 0 && color.B == 0;
        }

        protected string GetCharacterAt(int x, int y)
            => GetCharacterFromColor(GetColorAt(x, y));

        protected Keys GetModifierKeyAt(int x, int y)
            => GetModifierKeyFromColor(GetColorAt(x, y));

        protected Color GetColorAt(int x, int y)
        {
            if (AddonScreenshotSize.Width <= 1 || AddonScreenshotSize.Height <= 1)
            {
                return Color.Magenta;
            }

            var frameWidth = AddonScreenshotSize.Width / _appSettings.AddonColumnCount;
            var frameHeight = AddonScreenshotSize.Height / _appSettings.AddonRowCount;
            var xPos = (frameWidth * x);
            var yPos = (frameHeight * y);

            return TryGetPixelAt(xPos - (frameWidth / 2),
                AddonScreenshotSize.Height - yPos + (frameHeight / 2));
        }

        private Color TryGetPixelAt(int x, int y)
        {
            if (AddonScreenshotSize.Width <= 1 || AddonScreenshotSize.Height <= 1)
            {
                return Color.Magenta;
            }

            try
            {
                return AddonScreenshot.GetPixel(x, y);
            }
            catch(Exception ex)
            {
                return Color.Magenta;
            }
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

        private Keys GetModifierKeyFromColor(Color c)
        {
            if (c.R == 0 && c.G == 0 && c.B > 200)
            {
                return Keys.LControlKey;
            }

            if (c.R == 0 && c.G > 200 && c.B == 0)
            {
                return Keys.LShiftKey;
            }

            if (c.R > 200 && c.G == 0 && c.B == 0)
            {
                return Keys.Alt;
            }
            
            return Keys.None;
        }
    }
}
