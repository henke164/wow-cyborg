﻿using System.Drawing;
using System.Windows.Forms;

namespace WowCyborg.Utilities
{
    public static class ScreenUtilities
    {
        public static Rectangle GetScreenBounds()
        {
            var bounds = new Rectangle(0, 0, 0, 0);
            for (var x = 0; x < Screen.AllScreens.Length; x++)
            {
                var screenBounds = Screen.GetBounds(new Point(bounds.Width, 0));
                bounds.Width += screenBounds.Width;
                if (screenBounds.Height > bounds.Height)
                {
                    bounds.Height = screenBounds.Height;
                }
            }
            return bounds;
        }
    }
}
