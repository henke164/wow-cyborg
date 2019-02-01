﻿using System;
using System.Drawing;
using WoWPal.Handlers;
using WoWPal.Models;
using WoWPal.Models.Abstractions;
using WoWPal.Utilities;

namespace WoWPal.EventDispatchers
{
    public abstract class AddonBehaviourEventDispatcher : EventDispatcherBase
    {
        protected Bitmap AddonScreenshot;
        private AppSettings _appSettings;

        public AddonBehaviourEventDispatcher(Action<Event> onEvent) 
            : base(onEvent)
        {
            _appSettings = SettingsLoader.LoadSettings<AppSettings>("settings.json");
            AddonScreenshot = new Bitmap(1, 1);
            AddonScreenshot.SetPixel(0, 0, Color.White);

            EventManager.On("ScreenChanged", (Event ev) => {
                var screenshot = (Bitmap)ev.Data;

                try
                {
                    AddonScreenshot = screenshot;
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

            var frameWidth = AddonScreenshot.Width / _appSettings.AddonColumnCount;
            var frameHeight = AddonScreenshot.Height / _appSettings.AddonRowCount;
            var xPos = (frameWidth * x);
            var yPos = (frameHeight * y);

            var pixel = AddonScreenshot.GetPixel(
                xPos - (frameWidth / 2),
                AddonScreenshot.Height - yPos + (frameHeight / 2));

            return pixel.R == 0 && pixel.G > 250 && pixel.B == 0;
        }

        protected bool AddonIsRedAt(int x, int y)
        {
            if (AddonScreenshot.Width == 1 || AddonScreenshot.Height == 1)
            {
                return false;
            }

            var frameWidth = AddonScreenshot.Width / _appSettings.AddonColumnCount;
            var frameHeight = AddonScreenshot.Height / _appSettings.AddonRowCount;
            var xPos = (frameWidth * x);
            var yPos = (frameHeight * y);

            var pixel = AddonScreenshot.GetPixel(
                xPos - (frameWidth / 2),
                AddonScreenshot.Height - yPos + (frameHeight / 2));

            return pixel.R > 250 && pixel.G == 0 && pixel.B == 0;
        }
        
        protected string GetCharacterAt(int x, int y)
        {
            var frameWidth = AddonScreenshot.Width / _appSettings.AddonColumnCount;
            var frameHeight = AddonScreenshot.Height / _appSettings.AddonRowCount;
            var xPos = (frameWidth * x);
            var yPos = (frameHeight * y);

            var color = AddonScreenshot.GetPixel(
                xPos - (frameWidth / 2),
                AddonScreenshot.Height - yPos + (frameHeight / 2));

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
