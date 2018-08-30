using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WoWPal.Events;
using WoWPal.Events.Abstractions;
using WoWPal.Utilities;

namespace WoWPal.Commanders
{
    public class RotationCommander
    {
        [DllImport("user32.dll")]
        static extern bool SetCursorPos(int X, int Y);

        [DllImport("user32.dll")]
        public static extern void mouse_event(int dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);

        public const int MOUSEEVENTF_RIGHTDOWN = 0x08;

        public const int MOUSEEVENTF_RIGHTUP = 0x10;

        public int OneLapPixels = 57;

        private Transform _currentTransform;

        public RotationCommander()
        {
            EventManager.On("PlayerTransformChanged", (Event ev) => {
                _currentTransform = (Transform)ev.Data;
            });
        }

        private double GetRadian(Vector2 point)
        {
            var xDiff = _currentTransform.X - point.X;
            var yDiff = _currentTransform.Z - point.Z;

            var angleRadians = Math.Atan2(xDiff, yDiff);

            if (angleRadians > 0)
            {
                return angleRadians;
            }

            return 6.278 + angleRadians;
        }

        public void FacePoint(Vector2 point)
        {
            if (_currentTransform == null)
            {
                return;
            }

            var angleRadians = GetRadian(point);
            
            return;
            Console.WriteLine(angleRadians);

            var screenBounds = Screen.PrimaryScreen.Bounds;

            var startXPosition = screenBounds.Width / 2;
            var yPosition = screenBounds.Height / 2;

            var deg1 = ToDegree(Math.Abs(_currentTransform.R));
            var deg2 = ToDegree(Math.Abs(angleRadians));
            var perc = (deg1 - deg2) / 360;

            var dist = 57 * perc;

            Task.Run(() => {

                SetCursorPos(startXPosition, yPosition);

                Thread.Sleep(500);

                mouse_event(MOUSEEVENTF_RIGHTDOWN, startXPosition, yPosition, 0, 0);

                Thread.Sleep(500);
                if (dist > 0)
                {
                    for (var x = 0; x < dist; x++)
                    {
                        SetCursorPos(startXPosition + x, yPosition);
                        Thread.Sleep(5);
                    }
                }
                else
                {
                    for (var x = 0; x > dist; x--)
                    {
                        SetCursorPos(startXPosition + x, yPosition);
                        Thread.Sleep(5);
                    }
                }

                Thread.Sleep(10);
                mouse_event(MOUSEEVENTF_RIGHTUP, startXPosition, yPosition, 0, 0);

            });
        }

        private double ToDegree(double radian)
            => radian * (180 / Math.PI);

        private double ToRadian(double degree)
            => degree * (Math.PI / 180);
    }
}
