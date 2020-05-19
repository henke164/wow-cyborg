using System;
using System.Collections.Generic;
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
        protected static Dictionary<IntPtr, Bitmap> AddonScreenshots = new Dictionary<IntPtr, Bitmap>();
        protected static Dictionary<IntPtr, Size> AddonScreenshotSizes = new Dictionary<IntPtr, Size>();
        private AppSettings _appSettings;

        public AddonBehaviourEventDispatcher() 
            : base()
        {
            _appSettings = SettingsLoader.LoadSettings<AppSettings>("settings.json");

            OnGameHandleAdded = InitializeGameHandle;
        }

        void InitializeGameHandle(IntPtr hWnd)
        {
            if (!AddonScreenshots.ContainsKey(hWnd))
            {
                AddonScreenshots.Add(hWnd, new Bitmap(1, 1));
            }

            AddonScreenshots[hWnd].SetPixel(0, 0, Color.White);

            EventManager.On(hWnd, "ScreenChanged", (Event ev) =>
            {
                var screenshot = (Bitmap)((Bitmap)ev.Data).Clone();

                try
                {
                    AddonScreenshots[hWnd] = screenshot;
                    AddonScreenshotSizes[hWnd] = screenshot.Size;
                }
                catch (Exception ex)
                {
                }
            });
        }

        protected bool AddonIsGreenAt(IntPtr hWnd, int x, int y)
        {
            if (!AddonScreenshotSizes.ContainsKey(hWnd))
            {
                return false;
            }

            if (AddonScreenshotSizes[hWnd].Width <= 1 || AddonScreenshotSizes[hWnd].Height <= 1)
            {
                return false;
            }

            var color = GetColorAt(hWnd, x, y);

            return color.R == 0 && color.G > 230 && color.B == 0;
        }

        protected bool AddonIsRedAt(IntPtr hWnd, int x, int y)
        {
            if (!AddonScreenshotSizes.ContainsKey(hWnd))
            {
                return false;
            }

            if (AddonScreenshotSizes[hWnd].Width <= 1 || AddonScreenshotSizes[hWnd].Height <= 1)
            {
                return false;
            }

            var color = GetColorAt(hWnd, x, y);

            return color.R > 230 && color.G == 0 && color.B == 0;
        }

        protected bool AddonIsBlueAt(IntPtr hWnd, int x, int y)
        {
            if (!AddonScreenshotSizes.ContainsKey(hWnd))
            {
                return false;
            }

            if (AddonScreenshotSizes[hWnd].Width <= 1 || AddonScreenshotSizes[hWnd].Height <= 1)
            {
                return false;
            }

            var color = GetColorAt(hWnd, x, y);

            return color.R == 0 && color.G == 0 && color.B > 230;
        }

        protected string GetCharacterAt(IntPtr hWnd, int x, int y)
            => GetCharacterFromColor(GetColorAt(hWnd, x, y));

        protected Keys GetModifierKeyAt(IntPtr hWnd, int x, int y)
            => GetModifierKeyFromColor(GetColorAt(hWnd, x, y));

        protected Color GetColorAt(IntPtr hWnd, int x, int y)
        {
            if (!AddonScreenshotSizes.ContainsKey(hWnd))
            {
                return Color.Magenta;
            }

            if (AddonScreenshotSizes[hWnd].Width <= 1 || AddonScreenshotSizes[hWnd].Height <= 1)
            {
                return Color.Magenta;
            }

            var frameWidth = AddonScreenshotSizes[hWnd].Width / _appSettings.AddonColumnCount;
            var frameHeight = AddonScreenshotSizes[hWnd].Height / _appSettings.AddonRowCount;
            var xPos = (frameWidth * x) - 1;
            var yPos = (frameHeight * y) - 1;

            return TryGetPixelAt(hWnd, xPos, AddonScreenshotSizes[hWnd].Height - yPos);
        }

        private Color TryGetPixelAt(IntPtr hWnd, int x, int y)
        {
            if (!AddonScreenshotSizes.ContainsKey(hWnd))
            {
                return Color.Magenta;
            }

            if (AddonScreenshotSizes[hWnd].Width <= 1 || AddonScreenshotSizes[hWnd].Height <= 1)
            {
                return Color.Magenta;
            }

            try
            {
                return AddonScreenshots[hWnd].GetPixel(x, y);
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
                return Keys.F1;
            }
            
            return Keys.None;
        }
    }
}
