using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WowCyborg.Commanders;
using WowCyborg.Handlers;
using WowCyborg.Models;
using WowCyborg.Models.Abstractions;

namespace WowCyborg.Runners
{
    public class SoloRunner : BotRunnerBase
    {
        private EnemyTargettingCommander _enemyTargettingCommander;
        private LootingCommander _lootingCommander = new LootingCommander();
        private bool _isInCombat = false;

        public SoloRunner()
        {
            _enemyTargettingCommander = new EnemyTargettingCommander(KeyHandler);
            ShouldPauseMovement = () =>
            {
                return _isInCombat;
            };
        }

        protected override void SetupBehaviour()
        {
            EventManager.On("PlayerTransformChanged", (Event _) =>
            {
                if (TargetLocation != null && !_isInCombat)
                {
                    _enemyTargettingCommander.Update();
                }
            });

            EventManager.On("CombatChanged", (Event ev) =>
            {
                _isInCombat = (bool)ev.Data;

                if (!_isInCombat)
                {
                    ResumeMovement();
                }
            });

            EventManager.On("KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;
                if (keyRequest.ModifierKey != Keys.None)
                {
                    KeyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
                }
                else
                {
                    KeyHandler.PressKey(keyRequest.Key);
                }
            });

            EventManager.On("WrongFacing", (Event _) =>
            {
                KeyHandler.PressKey(Keys.D, 200);
            });
        }
    }
}
