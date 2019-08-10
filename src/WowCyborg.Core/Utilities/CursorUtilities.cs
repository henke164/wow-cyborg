using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace WowCyborg.Core.Utilities
{
    public static class CursorUtilities
    {
        [StructLayout(LayoutKind.Sequential)]
        struct CURSORINFO
        {
            public Int32 cbSize;
            public Int32 flags;
            public IntPtr hCursor;
            public POINTAPI ptScreenPos;
        }

        [StructLayout(LayoutKind.Sequential)]
        struct POINTAPI
        {
            public int x;
            public int y;
        }

        [DllImport("user32.dll")]
        static extern bool GetCursorInfo(out CURSORINFO pci);

        [DllImport("user32.dll")]
        static extern bool DrawIcon(IntPtr hDC, int X, int Y, IntPtr hIcon);

        public static bool IsCursorIcon(Bitmap cursorIcon)
        {
            var currentCursor = GetCurrentCursorIcon();

            for (var x = 0; x < currentCursor.Width; x += 2)
            {
                for (var y = 0; y < currentCursor.Height; y += 2)
                {
                    var color1 = currentCursor.GetPixel(x, y);
                    var color2 = cursorIcon.GetPixel(x, y);
                    if (color1.R != color2.R || color1.G != color2.G || color1.B != color2.B)
                    {
                        return false;
                    }
                }
            }
            return true;
        }

        public static Bitmap GetCurrentCursorIcon()
        {
            var result = new Bitmap(50, 50, PixelFormat.Format24bppRgb);

            using (Graphics g = Graphics.FromImage(result))
            {
                CURSORINFO pci;
                pci.cbSize = Marshal.SizeOf(typeof(CURSORINFO));

                if (GetCursorInfo(out pci))
                {
                    DrawIcon(g.GetHdc(), 0, 0, pci.hCursor);
                    g.ReleaseHdc();
                }
                return result.Clone(new Rectangle(0, 0, 50, 50), PixelFormat.Format24bppRgb);
            }
        }
    }
}
