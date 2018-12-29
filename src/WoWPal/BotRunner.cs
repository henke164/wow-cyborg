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
        private Vector3 _targetLocation;
        private RotationCommander _rotationCommander = new RotationCommander();
        private MovementCommander _movementCommander = new MovementCommander();
        private CombatRotator _rotator;

        public BotRunner()
        {
            StartEventDispatchers();
            SetupBehaviour();
            _rotator = new ShamanRotator();
            _rotator.RunRotation(RotationType.None);
        }

        public void MoveTo(Vector3 target)
        {
            OnLog("Move to:" + target.X + "," + target.Z);
            _targetLocation = target;
            _rotationCommander.FaceLocation(_targetLocation, () => {
                _movementCommander.MoveToLocation(_targetLocation);
            });

            Task.Run(() => 
            {
                Thread.Sleep(4000);

                if (_targetLocation != null)
                {
                    _movementCommander.Stop();
                    MoveTo(_targetLocation);
                }
            });
        }

        private void StartEventDispatchers()
        {
            EventManager.StartEventDispatcher(typeof(ScreenChangedDispatcher));
            EventManager.StartEventDispatcher(typeof(PlayerTransformChangedDispatcher));
            EventManager.StartEventDispatcher(typeof(CombatChangedDispatcher));
            EventManager.StartEventDispatcher(typeof(NewTargetDispatcher));
        }

        private void SetupBehaviour()
        {
            EventManager.On("PlayerTransformChanged", (Event ev) => 
            {
                HandleOnPlayerTransformChanged((Transform)ev.Data);
            });

            EventManager.On("TargetInRange", (Event ev) =>
            {
                HandleTargetInRange((bool)ev.Data);
            });
        }

        private void HandleOnPlayerTransformChanged(Transform currentTransform)
        {
            _rotationCommander.UpdateCurrentTransform(currentTransform);

            if (_targetLocation == null)
            {
                return;
            }            

            if (Vector3.Distance(_targetLocation, currentTransform.Position) < 0.005)
            {
                _targetLocation = null;
                _movementCommander.Stop();
                OnLog("Destination reached");
            }
        }
        
        private void HandleTargetInRange(bool inRange)
        {
            if (inRange)
            {
                _rotator.RunRotation(RotationType.SingleTarget);
                _movementCommander.Stop();
                OnLog("Target in range: Stopping movement and starting combat.");
            }
            else
            {
                _rotator.RunRotation(RotationType.None);
                OnLog("No targets in range: Continue moving.");
            }
        }
    }
}
