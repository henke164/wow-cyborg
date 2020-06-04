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
        private bool _isAlive = true;
        private DateTime _timeSinceLastAttackInCombat;
        private Thread _restingTask;
        private bool _initialResting = true;

        public SoloRunner(IntPtr hWnd)
            : base (hWnd)
        {
            _enemyTargettingCommander = new EnemyTargettingCommander(KeyHandler);
            _lootingCommander = new LootingCommander(hWnd, ref _isInCombat);
        }

        // Check if player is in combat without pressing any keys.
        // Player might be targetting something else than the enemy target.
        private void RunTargetSwitchHandler()
        {
            var now = DateTime.Now;
            _timeSinceLastAttackInCombat = now;

            Task.Run(() => {
                while (_isInCombat)
                {
                    if ((now - _timeSinceLastAttackInCombat).Seconds > 1)
                    {
                        KeyHandler.PressKey(Keys.Tab);
                    }
                    Thread.Sleep(500);
                }
            });
        }

        protected override void SetupBehaviour()
        {
            EventManager.On(HWnd, "PlayerTransformChanged", (Event _) =>
            {
                if (TargetLocation != null && !_isInCombat && !Paused && CorpseTransform == null)
                {
                    _enemyTargettingCommander.Update();
                }
            });

            EventManager.On(HWnd, "DeathChanged", (Event ev) =>
            {
                if ((bool)ev.Data)
                {
                    _isAlive = false;
                    Task.Run(() =>
                    {
                        Thread.Sleep(6000);
                        KeyHandler.PressKey(Keys.F8);
                        while (!_isAlive)
                        {
                            KeyHandler.PressKey(Keys.F8);
                            Thread.Sleep(1000);
                        }
                    });
                }
                else
                {
                    _isAlive = true;
                }
            });
            
            EventManager.On(HWnd, "CombatChanged", (Event ev) =>
            {
                _isInCombat = (bool)ev.Data;
                Console.WriteLine("Combat: " + _isInCombat);
                if (_isInCombat)
                {
                    PauseMovement();
                    Task.Run(() => {
                        Thread.Sleep(3000);
                        RunTargetSwitchHandler();
                    });
                    return;
                }

                _lootingCommander.Loot(() => {
                    if (!_isInCombat)
                    {
                        ResumeMovement();
                    }
                });
            });

            EventManager.On(HWnd, "KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;

                if (keyRequest.ModifierKey != Keys.None)
                {
                    KeyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
                }
                else
                {
                    if (keyRequest.Key == Keys.D9)
                    {
                        if (_initialResting)
                        {
                            _initialResting = false;
                            KeyHandler.PressKey(keyRequest.Key);
                        }

                        if (_restingTask != null)
                        {
                            _restingTask.Abort();
                        }

                        _restingTask = new Thread(() =>
                        {
                            PauseMovement();
                            Thread.Sleep(3500);
                            if (!_isInCombat)
                            {
                                _initialResting = true;
                                ResumeMovement();
                            }
                        });
                        _restingTask.Start();
                    }
                    else
                    {
                        KeyHandler.PressKey(keyRequest.Key);
                    }
                }

                if (_isInCombat)
                {
                    _timeSinceLastAttackInCombat = DateTime.Now;
                }
            });

            EventManager.On(HWnd, "WrongFacing", (Event _) =>
            {
                PauseMovement();
                KeyHandler.PressKey(Keys.S, 1500);
            });

            EventManager.On(HWnd, "TooFarAway", (Event _) =>
            {
                KeyHandler.PressKey(Keys.Tab);
            });
        }
    }
}
