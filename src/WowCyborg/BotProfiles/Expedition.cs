using System;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WowCyborg.Core;
using WowCyborg.Core.Commanders;
using WowCyborg.Core.Handlers;
using WowCyborg.Core.Models;
using WowCyborg.Core.Models.Abstractions;
using WowCyborg.Core.Utilities;

namespace WowCyborg.BotProfiles
{
    public class Expedition : Bot
    {
        private EnemyTargettingCommander _enemyTargettingCommander;
        private bool _isInCombat = false;
        private int _currentZone = 0;
        private DateTime _timeSinceLastAttackInCombat;
        private LootingCommander _lootingCommander;

        public Expedition(IntPtr hWnd)
            : base(hWnd)
        {
            _enemyTargettingCommander = new EnemyTargettingCommander(KeyHandler);
            _lootingCommander = new LootingCommander(hWnd, ref _isInCombat);
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
                        KeyHandler.PressKey(Keys.D, 500);
                    }
                    Thread.Sleep(500);
                }
            });
        }

        protected override void SetupBehaviour()
        {
            EventManager.On("PlayerTransformChanged", (Event ev) =>
            {
                var loc = (Transform)ev.Data;
                var zone = loc.ZoneId;

                if (_currentZone != zone)
                {
                    if (zone == 1165)
                    {
                        _lootingCommander.Loot(() => { });
                    }

                    if (zone != 0)
                    {
                        _currentZone = zone;
                    }
                }

                if (TargetLocation != null && !_isInCombat && !Paused && CorpseTransform == null)
                {
                    _enemyTargettingCommander.Update();
                }
            });

            EventManager.On("CombatChanged", (Event ev) =>
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

                ResumeMovement();
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

                if (_isInCombat)
                {
                    _timeSinceLastAttackInCombat = DateTime.Now;
                }
            });

            EventManager.On("WrongFacing", (Event _) =>
            {
                PauseMovement();
                KeyHandler.PressKey(Keys.D, 500);
            });

            EventManager.On("TooFarAway", (Event _) =>
            {
                KeyHandler.PressKey(Keys.Tab);
            });
        }
    }
}
