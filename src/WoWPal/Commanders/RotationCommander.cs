using System;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WoWPal.Events;
using WoWPal.Events.Abstractions;
using WoWPal.Handlers;
using WoWPal.Utilities;

namespace WoWPal.Commanders
{
    public class RotationCommander
    {
        public Vector3 TargetPoint { get; set; }

        public int OneLapPixels = 280;

        private Task _facingTask;

        public RotationCommander()
        {
            EventManager.On("PlayerTransformChanged", (Event ev) => {
                var currentTransform = (Transform)ev.Data;

                if (TargetPoint == null || (_facingTask != null && !_facingTask.IsCompleted))
                {
                    return;
                }

                StartRotationTask(currentTransform);
            });
        }

        private void StartRotationTask(Transform transform)
        {
            var screenBounds = Screen.PrimaryScreen.Bounds;
            var mousePos = new Vector3(screenBounds.Width / 2, screenBounds.Height / 2, 0);

            _facingTask = Task.Run(() => {
                InputHandler.SetCursorPos((int)mousePos.X, (int)mousePos.Y);

                Thread.Sleep(100);

                InputHandler.RightMouseDown((int)mousePos.X, (int)mousePos.Y);

                Thread.Sleep(100);

                HandleRotation(transform, mousePos);

                Thread.Sleep(100);

                InputHandler.RightMouseUp((int)mousePos.X, (int)mousePos.Y);
            });
        }
        
        private double GetRadian(Transform transform, Vector3 point)
        {
            var xDiff = transform.Position.X - point.X;
            var yDiff = transform.Position.Z - point.Z;

            var angleRadians = Math.Atan2(xDiff, yDiff);

            if (angleRadians > 0)
            {
                return angleRadians;
            }

            return (Math.PI * 2) + angleRadians;
        }

        private void HandleRotation(Transform transform, Vector3 mousePos)
        {
            if (TargetPoint == null)
            {
                return;
            }

            var rotationInstructions = GetRotationInstructions(transform, TargetPoint);
            var mousePosX = rotationInstructions.Direction == Direction.Right ? (int)mousePos.X + 5 : (int)mousePos.X - 5;
            var mouseMovementInPixels = GetMouseMovementDistance(rotationInstructions.Distance);
            for (var x = 0; x < mouseMovementInPixels; x++)
            {
                InputHandler.SetCursorPos(mousePosX, (int)mousePos.Y);
                Thread.Sleep(10);
            }
        }

        private RotationInstruction GetRotationInstructions(Transform transform, Vector3 point)
        {
            var angleRadians = GetRadian(transform, point);
            if (angleRadians > transform.Rotation)
            {
                return new RotationInstruction(Direction.Left, angleRadians - transform.Rotation);
            }

            return new RotationInstruction(Direction.Right, transform.Rotation - angleRadians);
        }

        private int GetMouseMovementDistance(double rotationDistance)
            => (int)(OneLapPixels * (rotationDistance / (Math.PI * 2)));
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
