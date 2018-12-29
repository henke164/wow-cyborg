using System;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WoWPal.Utilities;

namespace WoWPal.Commanders
{
    public class RotationCommander
    {
        private Transform _currentTransform;

        private Task _facingTask;

        private Vector3 _targetPoint;

        public void FaceLocation(Vector3 targetPoint, Action onDone)
        {
            _targetPoint = targetPoint;
            if (_facingTask != null)
            {
                _facingTask = null;
            }

            _facingTask = Task.Run(async () =>
            {
                await HandleRotationAsync();
                onDone();
            });
        }

        public void UpdateCurrentTransform(Transform transform)
        {
            _currentTransform = transform;
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

        private async Task HandleRotationAsync()
        {
            while (true)
            {
                if (_targetPoint == null)
                {
                    break;
                }

                var rotationInstructions = GetRotationInstructions(_currentTransform, _targetPoint);
                if (rotationInstructions.Distance > 0.02)
                {
                    var keyDownTime = (int)(rotationInstructions.Distance * 200);
                    if (rotationInstructions.Direction == Direction.Right)
                    {
                        KeyHandler.PressKey(Keys.D, keyDownTime);
                    }
                    else
                    {
                        KeyHandler.PressKey(Keys.A, keyDownTime);
                    }
                }
                else
                {
                    break;
                }

                var rotation = _currentTransform.Rotation;
                var sleeps = 0;
                while (rotation == _currentTransform.Rotation)
                {
                    Thread.Sleep(10);
                    sleeps++;
                    if (sleeps > 50)
                    {
                        break;
                    }
                }
            }
            _facingTask = null;
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

        internal class RotationInstruction
        {
            public Direction Direction { get; set; }
            public double Distance { get; set; }

            public RotationInstruction(Direction dir, double dist)
            {
                Direction = dir;
                Distance = dist;

                if (Distance > 7)
                {

                }
            }
        }

        internal enum Direction
        {
            Right,
            Left
        }
    }
}
