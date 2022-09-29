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
        protected IntPtr HWnd;

        public Action<string> OnLog { get; set; } = (string s) => { };
        public Transform CurrentTransform { get; protected set; }
        public Vector3 TargetLocation { get; protected set; }
        public Transform CorpseTransform { get; protected set; }
        public bool DestinationReached { get; set; } = true;

        protected KeyHandler KeyHandler;
        protected bool Paused = false;

        private Action _onDestinationReached;
        private RotationCommander _rotationCommander;
        private MovementCommander _movementCommander;
        private Task _runningTask;

        public Bot(IntPtr hWnd)
        {
            HWnd = hWnd;

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
            DestinationReached = false;
            StopMovement(() => {
                _onDestinationReached = onDestinationReached;

                if (target == null)
                {
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
            });
        }

        public void StopMovement(Action onStopped)
        {
            TargetLocation = null;
            _rotationCommander.Abort();
            _movementCommander.Stop();

            while (_runningTask != null && !_runningTask.IsCompleted)
            {
                OnLog("Waiting for runningtask to complete");
                Thread.Sleep(1000);
            }

            onStopped();
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
            EventManager.On(HWnd, "PlayerTransformChanged", OnPlayerTransformChanged);
            EventManager.On(HWnd, "DeathChanged", OnDeathChanged);
        }

        private void OnPlayerTransformChanged(Event ev)
        {
            CurrentTransform = (Transform)ev.Data;
            _rotationCommander.UpdateCurrentTransform(CurrentTransform);

            if (TargetLocation == null)
            {
                return;
            }

            if (Vector3.Distance(TargetLocation, CurrentTransform.Position) <= 0.0025)
            {
                TargetLocation = null;
                _movementCommander.Stop();
                OnLog("Destination reached");
                while (!_runningTask.IsCompleted)
                {
                    OnLog("Waiting for runningtask to complete");
                    Thread.Sleep(1000);
                }
                DestinationReached = true;
                _onDestinationReached?.Invoke();
            }
        }

        private void OnDeathChanged(Event ev)
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
            EventManager.StartEventDispatcher<ScreenChangedDispatcher>(HWnd);
            EventManager.StartEventDispatcher<PlayerTransformChangedDispatcher>(HWnd);
            EventManager.StartEventDispatcher<CombatChangedDispatcher>(HWnd);
            EventManager.StartEventDispatcher<CombatCastingDispatcher>(HWnd);
            EventManager.StartEventDispatcher<WrongFacingDispatcher>(HWnd);
            EventManager.StartEventDispatcher<TooFarAwayDispatcher>(HWnd);
            EventManager.StartEventDispatcher<DeathDispatcher>(HWnd);
            EventManager.StartEventDispatcher<AddonNotVisibleDispatcher>(HWnd);
        }
    }
}
