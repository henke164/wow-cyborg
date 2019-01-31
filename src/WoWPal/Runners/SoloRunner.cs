using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WoWPal.Commanders;
using WoWPal.Handlers;
using WoWPal.Models.Abstractions;
using WoWPal.Utilities;

namespace WoWPal.Runners
{
    public class SoloRunner : BotRunnerBase
    {
        private EnemyTargettingCommander _enemyTargettingCommander = new EnemyTargettingCommander();
        private LootingCommander _lootingCommander = new LootingCommander();
        private bool _isInCombat = false;
        private bool _isInRange = false;

        public SoloRunner()
        {
            ShouldPauseMovement = () =>
            {
                return _isInCombat || _isInRange;
            };
        }

        protected override void SetupBehaviour()
        {
            EventManager.On("PlayerTransformChanged", (Event _) =>
            {
                if (TargetLocation != null && !_isInRange)
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
                    StopMovement();
                    Task.Run(() => {
                        while (!_isInRange)
                        {
                            _enemyTargettingCommander.TargetNearestEnemy();
                            Thread.Sleep(500);
                        }
                    });
                }
            });

            EventManager.On("CastRequested", (Event ev) =>
            {
                var button = (Keys)ev.Data;
                KeyHandler.PressKey(button);
            });

            EventManager.On("WrongFacing", (Event _) =>
            {
                KeyHandler.PressKey(Keys.D, 500);
            });
        }


        private void HandleTargetInRange(bool inRange)
        {
            if (inRange)
            {
                StopMovement();
                _isInCombat = true;
                _isInRange = true;
                OnLog("Target in range: Stopping movement and starting combat.");
            }
            else
            {
                _isInRange = false;
                _isInCombat = false;

                _lootingCommander.Loot(() => {
                    if (TargetLocation != null)
                    {
                        _enemyTargettingCommander.TargetNearestEnemy();
                        Thread.Sleep(1000);
                        ResumeMovement();
                    }
                    OnLog("No targets in range: Continue moving.");
                });
            }
        }
    }
}
