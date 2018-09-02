using System;
using System.Threading;
using System.Threading.Tasks;
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
        public Action<string> OnLog { get; set; } = (string s) => { };
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

            if (!InputHandler.IsRightButtonDown && !_hasTarget)
            {
                await _actionbarCommander.ClickOnActionBarAsync("AutoTarget");
            }

            if (Vector3.Distance(_targetLocation, currentTransform.Position) < 0.005)
            {
                await _movementCommander.StopAsync();
                _targetLocation = null;
                _rotationCommander.TargetPoint = null;
                OnLog("Destination reached");
            }
        }
        
        private async Task HandleTargetInRange(bool inRange)
        {
            _hasTarget = inRange;
            if (inRange)
            {
                OnLog("Target in range: Stopping movement and starting combat.");
                await StartCombatAsync();
            }
            else
            {
                OnLog("No targets in range: Continue moving.");
                await EndCombatAsync();
            }
        }

        private async Task StartCombatAsync()
        {
            _rotationCommander.Stop();
            await _movementCommander.StopAsync();
            await Task.Delay(200);
            _combatCommander.StartOrContinueCombatTask();
        }

        private async Task EndCombatAsync()
        {
            _combatCommander.StopCombat();
            await Task.Delay(200);
            await _actionbarCommander.ClickOnActionBarAsync("ClearTarget");
            await Task.Delay(1000);
            ContinueMoving();
        }
    }
}
