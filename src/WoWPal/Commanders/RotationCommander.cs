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
                if (rotationInstructions.Distance > 0.1)
                {
                    var keyDownTime = (int)(rotationInstructions.Distance * 100);

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
                    Thread.Sleep(50);
                    sleeps++;
                    if (sleeps > 20)
                    {
                        break;
                    }
                }
            }
            _facingTask = null;
        }

        private RotationInstruction GetRotationInstructions(Transform transform, Vector3 point)
        {
            var targetRadian = GetRadian(transform, point);

            if (targetRadian > transform.Rotation)
            {
                var rot1 = Math.Abs(targetRadian - transform.Rotation);
                var rot2 = Math.Abs(targetRadian - transform.Rotation - (Math.PI * 2));

                if (rot1 > rot2)
                {
                    return new RotationInstruction(Direction.Right, rot2);
                }

                return new RotationInstruction(Direction.Left, rot1);
            }
            else
            {
                var rot1 = Math.Abs(transform.Rotation - targetRadian);
                var rot2 = Math.Abs(transform.Rotation - targetRadian - (Math.PI * 2));

                if (rot1 < rot2)
                {
                    return new RotationInstruction(Direction.Right, rot2);
                }

                return new RotationInstruction(Direction.Left, rot1);
            }
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
