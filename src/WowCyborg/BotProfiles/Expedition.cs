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

        public Expedition(IntPtr hWnd)
            : base(hWnd)
        {
            _enemyTargettingCommander = new EnemyTargettingCommander(KeyHandler);
        }

        protected override void SetupBehaviour()
        {
            EventManager.On("PlayerTransformChanged", (Event ev) =>
            {
                if (TargetLocation != null && !_isInCombat && !Paused && CorpseTransform == null)
                {
                    _enemyTargettingCommander.Update();
                }
            });

            EventManager.On("KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;

                if (keyRequest.ModifierKey == Keys.LShiftKey && keyRequest.Key == Keys.D4)
                {
                    KeyHandler.PressKey(Keys.Tab);
                    return;
                }

                if (keyRequest.ModifierKey != Keys.None)
                {
                    KeyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
                }
                else
                {
                    KeyHandler.PressKey(keyRequest.Key);
                }
            });

            EventManager.On("TooFarAway", (Event _) =>
            {
                KeyHandler.PressKey(Keys.Tab);
            });
        }
    }
}
