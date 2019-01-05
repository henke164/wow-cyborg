using System;
using System.Threading;
using System.Threading.Tasks;
using WoWPal.CombatHandler;
using WoWPal.CombatHandler.Rotators;
using WoWPal.Commanders;
using WoWPal.EventDispatchers;
using WoWPal.Events;
using WoWPal.Events.Abstractions;
using WoWPal.Utilities;

namespace WoWPal
{
    public class BotRunner
    {
        public Action<string> OnLog { get; set; } = (string s) => { };
        private Vector3 _currentLocation;
        private Vector3 _targetLocation;
        private Action _onDestinationReached;
        private RotationCommander _rotationCommander = new RotationCommander();
        private MovementCommander _movementCommander = new MovementCommander();
        private EnemyTargettingCommander _enemyTargettingCommander = new EnemyTargettingCommander();
        private CombatRotator _rotator;
        private Task _runningTask;
        private bool _isInCombat = false;
        private bool _isCasting = false;
        private bool _isInRange = false;

        public BotRunner()
        {
            StartEventDispatchers();
            SetupBehaviour();
            _rotator = new MonkRotator(() => {
                return _isCasting;
            });
            _rotator.RunRotation(RotationType.None);
        }

        public void FaceTowards(Vector3 target)
        {
            _targetLocation = null;
            _rotationCommander.FaceLocation(target, () => { });
        }

        public void MoveTo(Vector3 target, Action onDestinationReached = null)
        {
            _onDestinationReached = onDestinationReached;

            OnLog("Move to:" + target.X + "," + target.Z);
            _targetLocation = target;

            _rotationCommander.FaceLocation(_targetLocation, () => {
                if (_targetLocation == null || _isInCombat || _isInRange)
                {
                    return;
                }
                _movementCommander.MoveToLocation(_targetLocation);
            });

            StartMovementTask();
        }

        private void StartMovementTask()
        {
            _runningTask = Task.Run(() => 
            {
                for (var x = 0; x < 4; x++)
                {
                    Thread.Sleep(1000);

                    if (_targetLocation == null || _isInCombat || _isInRange)
                    {
                        _rotationCommander.Abort();
                        _movementCommander.Stop();
                        return;
                    }
                }

                var distanceToTarget = Vector3.Distance(_targetLocation, _currentLocation);
                if (distanceToTarget < 0.03)
                {
                    _movementCommander.Stop();
                }

                Task.Run(() =>
                {
                    MoveTo(_targetLocation, _onDestinationReached);
                });
            });
        }

        private void StartEventDispatchers()
        {
            EventManager.StartEventDispatcher(typeof(ScreenChangedDispatcher));
            EventManager.StartEventDispatcher(typeof(PlayerTransformChangedDispatcher));
            EventManager.StartEventDispatcher(typeof(CombatChangedDispatcher));
            EventManager.StartEventDispatcher(typeof(NewTargetDispatcher));
            EventManager.StartEventDispatcher(typeof(IsCastingDispatcher));
        }

        private void SetupBehaviour()
        {
            EventManager.On("IsCasting", (Event ev) =>
            {
                _isCasting = (bool)ev.Data;
            });

            EventManager.On("PlayerTransformChanged", (Event ev) => 
            {
                HandleOnPlayerTransformChanged((Transform)ev.Data);

                if (_targetLocation != null && !_isInRange)
                {
                    _enemyTargettingCommander.Update();
                }
            });

            EventManager.On("TargetInRange", (Event ev) =>
            {
                HandleTargetInRange((bool)ev.Data);
            });

            EventManager.On("CombatChanged", (Event ev) =>
            {
                _isInCombat = (bool)ev.Data;

                if (_isInCombat)
                {
                    _rotationCommander.Abort();
                    _movementCommander.Stop();
                }
            });
        }

        private void HandleOnPlayerTransformChanged(Transform currentTransform)
        {
            _currentLocation = currentTransform.Position;
            _rotationCommander.UpdateCurrentTransform(currentTransform);

            if (_targetLocation == null)
            {
                return;
            }            

            if (Vector3.Distance(_targetLocation, currentTransform.Position) <= 0.0025)
            {
                _targetLocation = null;
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
        
        private void HandleTargetInRange(bool inRange)
        {
            if (inRange)
            {
                _rotator.RunRotation(RotationType.SingleTarget);
                _rotationCommander.Abort();
                _movementCommander.Stop();
                _isInCombat = true;
                _isInRange = true;
                OnLog("Target in range: Stopping movement and starting combat.");
            }
            else
            {
                _rotator.RunRotation(RotationType.None);
                _isInCombat = false;
                _isInRange = false;

                if (_targetLocation != null)
                {
                    _enemyTargettingCommander.TargetNearestEnemy();
                    Thread.Sleep(1000);
                    MoveTo(_targetLocation, _onDestinationReached);
                }
                OnLog("No targets in range: Continue moving.");
            }
        }
    }
}
