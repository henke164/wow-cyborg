using System;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WowCyborg.Core;
using WowCyborg.Core.Commanders;
using WowCyborg.Core.Handlers;
using WowCyborg.Core.Models;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.BotProfiles
{
    public class SoloRunner : Bot
    {
        private EnemyTargettingCommander _enemyTargettingCommander;
        private LootingCommander _lootingCommander;
        private bool _isInCombat = false;
        private DateTime _timeSinceLastAttackInCombat;
        private Task _restingTask;

        public SoloRunner(IntPtr hWnd)
            : base (hWnd)
        {
            _enemyTargettingCommander = new EnemyTargettingCommander(KeyHandler);
        _lootingCommander = new LootingCommander(hWnd);
    }

        // Check if player is in combat without pressing any keys.
        // Player might be targetting something else than the enemy target.
        private void RunTargetSwitchHandler()
        {
            _timeSinceLastAttackInCombat = DateTime.Now;

            Task.Run(() => {
                while (_isInCombat)
                {
                    if ((DateTime.Now - _timeSinceLastAttackInCombat).Seconds > 1)
                    {
                        KeyHandler.PressKey(Keys.Tab);
                    }
                    Thread.Sleep(500);
                }
            });
        }

        protected override void SetupBehaviour()
        {
            EventManager.On("PlayerTransformChanged", (Event _) =>
            {
                if (TargetLocation != null && !_isInCombat && !Paused)
                {
                    _enemyTargettingCommander.Update();
                }
            });

            EventManager.On("CombatChanged", (Event ev) =>
            {
                _isInCombat = (bool)ev.Data;

                if (_isInCombat)
                {
                    PauseMovement();
                    RunTargetSwitchHandler();
                    return;
                }

                while (_restingTask != null && _restingTask.Status != TaskStatus.RanToCompletion)
                {
                    Thread.Sleep(1000);
                }

                _lootingCommander.Loot(() => {
                    ResumeMovement();
                });
            });

            EventManager.On("KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;

                if (Paused && keyRequest.Key == Keys.D1)
                {
                    return;
                }

                if (keyRequest.Key == Keys.D1)
                {
                    _isInCombat = true;
                }

                if (keyRequest.ModifierKey != Keys.None)
                {
                    KeyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
                }
                else
                {
                    
                    KeyHandler.PressKey(keyRequest.Key);
                    if (keyRequest.Key == Keys.D9)
                    {
                        _restingTask = Task.Run(() =>
                        {
                            PauseMovement();
                            Thread.Sleep(1000);
                            if (!_isInCombat)
                            {
                                Paused = false;
                            }
                        });
                    }
                }

                if (_isInCombat)
                {
                    _timeSinceLastAttackInCombat = DateTime.Now;
                }
            });

            EventManager.On("WrongFacing", (Event _) =>
            {
                PauseMovement();
                KeyHandler.PressKey(Keys.S, 1500);
            });

            EventManager.On("TooFarAway", (Event _) =>
            {
                KeyHandler.PressKey(Keys.Tab);
            });
        }
    }
}
