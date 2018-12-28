using System;
using System.Threading.Tasks;
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
        private bool _hasTarget = false;
        private Vector3 _targetLocation;
        private RotationCommander _rotationCommander = new RotationCommander();
        private MovementCommander _movementCommander = new MovementCommander();

        public BotRunner()
        {
            StartEventDispatchers();
            SetupBehaviour();
        }

        public void MoveTo(Vector3 target)
        {
            OnLog("Move to:" + target.X + "," + target.Z);
            _targetLocation = target;
            _rotationCommander.FaceLocation(_targetLocation, () => {
                _movementCommander.MoveToLocation(_targetLocation);
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

        private async Task HandleOnPlayerTransformChanged(Transform currentTransform)
        {
            if (_targetLocation == null)
            {
                return;
            }
            
            _rotationCommander.UpdateCurrentTransform(currentTransform);

            if (Vector3.Distance(_targetLocation, currentTransform.Position) < 0.005)
            {
                _targetLocation = null;
                _movementCommander.Stop();
                OnLog("Destination reached");
            }
        }
        
        private async Task HandleTargetInRange(bool inRange)
        {
            _hasTarget = inRange;
            if (inRange)
            {
                OnLog("Target in range: Stopping movement and starting combat.");
            }
            else
            {
                OnLog("No targets in range: Continue moving.");
            }
        }
    }
}
