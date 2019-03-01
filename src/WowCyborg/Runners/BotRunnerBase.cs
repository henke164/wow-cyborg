using System;
using System.Threading;
using System.Threading.Tasks;
using WowCyborg.Commanders;
using WowCyborg.EventDispatchers;
using WowCyborg.Handlers;
using WowCyborg.Models.Abstractions;
using WowCyborg.Utilities;

namespace WowCyborg.Runners
{
    public abstract class BotRunnerBase
    {
        public Action<string> OnLog { get; set; } = (string s) => { };
        public Transform CurrentTransform { get; protected set; }
        public Vector3 TargetLocation { get; protected set; }
        protected Func<bool> ShouldPauseMovement = () => false;
        protected KeyHandler KeyHandler;

        private Action _onDestinationReached;
        private RotationCommander _rotationCommander;
        private MovementCommander _movementCommander;
        private Task _runningTask;

        public BotRunnerBase(IntPtr gameHandle)
        {
            KeyHandler = new KeyHandler(gameHandle);

            _rotationCommander = new RotationCommander(KeyHandler);
            _movementCommander = new MovementCommander(KeyHandler);

            StartEventDispatchers();
            SetupBehaviour();
            SetupTransformBehaviour();
        }

        public void FaceTowards(Vector3 target)
        {
            TargetLocation = null;
            _rotationCommander.FaceLocation(target, () => { });
        }

        public void MoveTo(Vector3 target, Action onDestinationReached = null)
        {
            _onDestinationReached = onDestinationReached;

            OnLog("Move to:" + target.X + "," + target.Z);
            TargetLocation = target;

            _rotationCommander.FaceLocation(TargetLocation, () => {
                if (TargetLocation == null || ShouldPauseMovement())
                {
                    return;
                }
                _movementCommander.MoveToLocation(TargetLocation);
            });

            StartMovementTask();
        }

        public void StopMovement()
        {
            _rotationCommander.Abort();
            _movementCommander.Stop();
        }

        public void ResumeMovement()
        {
            MoveTo(TargetLocation, _onDestinationReached);
        }

        protected abstract void SetupBehaviour();

        private void SetupTransformBehaviour()
        {
            EventManager.On("PlayerTransformChanged", (Event ev) =>
            {
                HandleOnPlayerTransformChanged((Transform)ev.Data);
            });
        }

        private void HandleOnPlayerTransformChanged(Transform currentTransform)
        {
            CurrentTransform = currentTransform;
            _rotationCommander.UpdateCurrentTransform(currentTransform);

            if (TargetLocation == null)
            {
                return;
            }

            if (Vector3.Distance(TargetLocation, currentTransform.Position) <= 0.0025)
            {
                TargetLocation = null;
                _movementCommander.Stop();
                OnLog("Destination reached");
                while (!_runningTask.IsCompleted)
                {
                    OnLog("Waiting for runningtask to complete");
                    Thread.Sleep(1000);
                }
                _onDestinationReached?.Invoke();
            }
        }
        
        private void StartMovementTask()
        {
            _runningTask = Task.Run(() =>
            {
                for (var x = 0; x < 4; x++)
                {
                    Thread.Sleep(1000);

                    if (TargetLocation == null || ShouldPauseMovement())
                    {
                        _rotationCommander.Abort();
                        _movementCommander.Stop();
                        return;
                    }
                }

                var distanceToTarget = Vector3.Distance(TargetLocation, CurrentTransform.Position);
                if (distanceToTarget < 0.03)
                {
                    _movementCommander.Stop();
                }

                Task.Run(() =>
                {
                    MoveTo(TargetLocation, _onDestinationReached);
                });
            });
        }

        private void StartEventDispatchers()
        {
            EventManager.StartEventDispatcher(typeof(ScreenChangedDispatcher));
            EventManager.StartEventDispatcher(typeof(PlayerTransformChangedDispatcher));
            EventManager.StartEventDispatcher(typeof(CombatChangedDispatcher));
            EventManager.StartEventDispatcher(typeof(CombatCastingDispatcher));
            EventManager.StartEventDispatcher(typeof(WrongFacingDispatcher));
        }
    }
}
