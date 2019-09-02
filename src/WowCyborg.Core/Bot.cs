using System;
using System.Threading;
using System.Threading.Tasks;
using WowCyborg.Core.Commanders;
using WowCyborg.Core.EventDispatchers;
using WowCyborg.Core.Handlers;
using WowCyborg.Core.Models.Abstractions;
using WowCyborg.Core.Utilities;

namespace WowCyborg.Core
{
    public abstract class Bot
    {
        public Action<string> OnLog { get; set; } = (string s) => { };
        public Transform CurrentTransform { get; protected set; }
        public Vector3 TargetLocation { get; protected set; }
        public Transform CorpseTransform { get; protected set; }

        protected KeyHandler KeyHandler;
        protected bool Paused = false;

        private Action _onDestinationReached;
        private RotationCommander _rotationCommander;
        private MovementCommander _movementCommander;
        private Task _runningTask;

        public Bot(IntPtr hWnd)
        {
            KeyHandler = new KeyHandler(hWnd);

            _rotationCommander = new RotationCommander(KeyHandler);
            _movementCommander = new MovementCommander(KeyHandler);

            StartEventDispatchers();
            SetupBehaviour();
            SetupEventBehaviours();
        }

        public void FaceTowards(Vector3 target, Action onFacing = null)
        {
            TargetLocation = null;
            _rotationCommander.FaceLocation(target, onFacing);
        }

        public void MoveTo(Vector3 target, Action onDestinationReached = null)
        {
            StopMovement();

            _onDestinationReached = onDestinationReached;

            if (target == null)
            {
                onDestinationReached();
                return;
            }

            OnLog("Move to:" + target.X + "," + target.Z);
            TargetLocation = target;

            _rotationCommander.FaceLocation(TargetLocation, () => {
                if (TargetLocation == null || Paused)
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

        public void PauseMovement()
        {
            Paused = true;
        }

        public void ResumeMovement()
        {
            Paused = false;

            if (TargetLocation == null)
            {
                return;
            }

            MoveTo(TargetLocation, _onDestinationReached);
        }

        protected abstract void SetupBehaviour();

        private void SetupEventBehaviours()
        {
            EventManager.On("PlayerTransformChanged", (Event ev) =>
            {
                HandleOnPlayerTransformChanged((Transform)ev.Data);
            });

            EventManager.On("DeathChanged", (Event ev) =>
            {
                if ((bool)ev.Data)
                {
                    CorpseTransform = new Transform(
                        CurrentTransform.Position.X,
                        CurrentTransform.Position.Y,
                        CurrentTransform.Position.Z,
                        CurrentTransform.Rotation);

                    TargetLocation = null;
                    Paused = false;
                }
                else
                {
                    CorpseTransform = null;
                }
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

                    if (TargetLocation == null || Paused)
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
            EventManager.StartEventDispatcher(typeof(TooFarAwayDispatcher));
            EventManager.StartEventDispatcher(typeof(DeathDispatcher));
        }
    }
}
