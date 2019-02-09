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
        protected Vector3 CurrentLocation;
        protected Vector3 TargetLocation;
        protected Func<bool> ShouldPauseMovement = () => false;

        private Action _onDestinationReached;
        private RotationCommander _rotationCommander = new RotationCommander();
        private MovementCommander _movementCommander = new MovementCommander();
        private Task _runningTask;

        public BotRunnerBase()
        {
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
            CurrentLocation = currentTransform.Position;
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

                var distanceToTarget = Vector3.Distance(TargetLocation, CurrentLocation);
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
            EventManager.StartEventDispatcher(typeof(LeaderTransformChangedDispatcher));
            EventManager.StartEventDispatcher(typeof(CombatChangedDispatcher));
            EventManager.StartEventDispatcher(typeof(CombatCastingDispatcher));
            EventManager.StartEventDispatcher(typeof(NewTargetDispatcher));
            EventManager.StartEventDispatcher(typeof(WrongFacingDispatcher));
        }
    }
}
