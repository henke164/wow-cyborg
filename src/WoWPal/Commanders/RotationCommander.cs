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

        public int OneLapPixels = 280;

        private Transform _currentTransform;
        
        public RotationCommander()
        {
            EventManager.On("PlayerTransformChanged", (Event ev) => {
                _currentTransform = (Transform)ev.Data;
            });
        }

        private double GetRadian(Vector3 point)
        {
            var xDiff = _currentTransform.X - point.X;
            var yDiff = _currentTransform.Z - point.Z;

            var angleRadians = Math.Atan2(xDiff, yDiff);

            if (angleRadians > 0)
            {
                return angleRadians;
            }

            return (Math.PI * 2) + angleRadians;
        }

        public void FacePoint(Vector3 point)
        {
            if (_currentTransform == null)
            {
                return;
            }

            var screenBounds = Screen.PrimaryScreen.Bounds;
            var mousePos = new Vector3(screenBounds.Width / 2, screenBounds.Height / 2, 0);

            Task.Run(() => {
                SetCursorPos((int)mousePos.X, (int)mousePos.Y);

                Thread.Sleep(500);

                mouse_event(MOUSEEVENTF_RIGHTDOWN, (int)mousePos.X, (int)mousePos.Y, 0, 0);

                Thread.Sleep(100);

                HandleRotation(mousePos, point);

                Thread.Sleep(100);

                mouse_event(MOUSEEVENTF_RIGHTUP, (int)mousePos.X, (int)mousePos.Y, 0, 0);
            });
        }

        private int GetMouseMovementDistance(double rotationDistance)
            => (int)(OneLapPixels * (rotationDistance / (Math.PI * 2)));

        private RotationInstruction GetRotationInstructions(Vector3 point)
        {
            var angleRadians = GetRadian(point);
            if (angleRadians > _currentTransform.R)
            {
                return new RotationInstruction(Direction.Left, angleRadians - _currentTransform.R);
            }

            return new RotationInstruction(Direction.Right, _currentTransform.R - angleRadians);
        }

        private void HandleRotation(Vector3 mousePos, Vector3 point)
        {
            var rotationInstructions = GetRotationInstructions(point);
            var mousePosX = rotationInstructions.Direction == Direction.Right ? (int)mousePos.X + 5 : (int)mousePos.X - 5;
            var mouseMovementInPixels = GetMouseMovementDistance(rotationInstructions.Distance);
            for (var x = 0; x < mouseMovementInPixels; x++)
            {
                SetCursorPos(mousePosX, (int)mousePos.Y);
                Thread.Sleep(10);
            }
        }

        private double ToDegree(double radian)
            => radian * (180 / Math.PI);

        private double ToRadian(double degree)
            => degree * (Math.PI / 180);
    }

    internal class RotationInstruction
    {
        public Direction Direction { get; set; }
        public double Distance { get; set; }

        public RotationInstruction(Direction dir, double dist)
        {
            Direction = dir;
            Distance = dist;
        }
    }

    internal enum Direction
    {
        Right,
        Left
    }
}
