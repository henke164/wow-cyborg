using System;
using System.Threading;
using WoWPal.Commanders;
using WoWPal.EventDispatchers;
using WoWPal.Events;
using WoWPal.Events.Abstractions;
using WoWPal.Handlers;
using WoWPal.Utilities;

namespace WoWPal
{
    public class BotRunner
    {
        public Action<string> OnLog { get; set; }
        private bool _hasTarget = false;
        private Vector3 _targetLocation;
        private CombatCommander _combatCommander = new CombatCommander();
        private MovementCommander _movementCommander = new MovementCommander();
        private RotationCommander _rotationCommander = new RotationCommander();
        private ActionbarCommander _actionbarCommander = ActionbarCommander.FromSettingFile("actionbarsettings.json");

        public BotRunner()
        {
            StartEventDispatchers();
            SetupBehaviour();
        }

        public void MoveTo(Vector3 target)
        {
            OnLog("Move to:" + target.X + "," + target.Z);
            _targetLocation = target;
            _rotationCommander.TargetPoint = _targetLocation;
            ContinueMoving();
        }

        public void ContinueMoving()
        {
            _rotationCommander.Start();
            _movementCommander.MoveToLocation(_targetLocation);
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

            EventManager.On("CombatChanged", (Event ev) =>
            {
                HandleCombatChanged((bool)ev.Data);
            });

            EventManager.On("TargetInRange", (Event ev) =>
            {
                HandleTargetInRange((bool)ev.Data);
            });
        }

        private void HandleOnPlayerTransformChanged(Transform currentTransform)
        {
            if (_targetLocation == null)
            {
                return;
            }
            
            _rotationCommander.UpdateCurrentTransform(currentTransform);

            if (!InputHandler.IsRightButtonDown && !_hasTarget)
            {
                _actionbarCommander.ClickOnActionBar("AutoTarget");
            }

            if (Vector3.Distance(_targetLocation, currentTransform.Position) < 0.005)
            {
                _movementCommander.Stop();
                _targetLocation = null;
                _rotationCommander.TargetPoint = null;
                OnLog("Destination reached");
            }
        }

        private void HandleCombatChanged(bool inCombat)
        {
            if (inCombat)
            {
                OnLog("In combat");
                StartCombat();
            }
            else
            {
                OnLog("Not in combat, continue moving");
                EndCombat();
            }
        }

        private void HandleTargetInRange(bool inRange)
        {
            _hasTarget = inRange;
            if (inRange)
            {
                OnLog("Target in range: Stopping movement and starting combat.");
                StartCombat();
            }
            else
            {
                OnLog("No targets in range: Continue moving.");
                EndCombat();
            }
        }

        private void StartCombat()
        {
            _rotationCommander.Stop();
            _movementCommander.Stop();
            Thread.Sleep(200);
            _combatCommander.StartOrContinueCombatTask();
        }

        private void EndCombat()
        {
            ContinueMoving();
            _combatCommander.StopCombat();
        }
    }
}
