using System;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WowCyborg.Core.Handlers;
using WowCyborg.Core.Utilities;

namespace WowCyborg.Core.Commanders
{
    public class RotationCommander
    {
        private KeyHandler _keyHandler;

        private Transform _currentTransform;

        private Thread _facingTask;

        private Vector3 _targetPoint;

        public RotationCommander(KeyHandler keyHandler)
        {
            _keyHandler = keyHandler;
        }

        public void FaceLocation(Vector3 targetPoint, Action onDone)
        {
            _targetPoint = targetPoint;
            if (_facingTask != null)
            {
                _facingTask.Abort();
                _facingTask = null;
            }

            _facingTask = new Thread(() =>
            {
                HandleRotation();
                onDone?.Invoke();
            });

            if (_facingTask.ThreadState != ThreadState.Running)
            {
                _facingTask.Start();
            }
        }

        public void Abort()
        {
            _targetPoint = null;
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

        private void HandleRotation()
        {
            while (_targetPoint != null)
            {
                if (_currentTransform == null)
                {
                    continue;
                }

                var rotationInstructions = GetRotationInstructions(_currentTransform, _targetPoint);
                if (rotationInstructions.Distance > 0.1)
                {
                    var keyDownTime = (int)(rotationInstructions.Distance * 200);

                    if (rotationInstructions.Direction == Direction.Right)
                    {
                        _keyHandler.PressKey(Keys.D, keyDownTime);
                    }
                    else
                    {
                        _keyHandler.PressKey(Keys.A, keyDownTime);
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

            var rot1 = Math.Abs(targetRadian - transform.Rotation);
            var rot2 = Math.Abs(rot1 - (Math.PI * 2));

            if (rot1 > rot2)
            {
                return new RotationInstruction(
                    targetRadian > transform.Rotation ? Direction.Right : Direction.Left, rot2);
            }

            return new RotationInstruction(
                targetRadian > transform.Rotation ? Direction.Left : Direction.Right, rot1);
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
