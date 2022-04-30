using System;
using System.ComponentModel;
using System.Windows.Forms;
using WowCyborg.Core;
using WowCyborg.Core.Commanders;
using WowCyborg.Core.Handlers;
using WowCyborg.Core.Models;
using WowCyborg.Core.Models.Abstractions;

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
            EventManager.On(HWnd, "PlayerTransformChanged", (Event ev) =>
            {
                if (TargetLocation != null && !_isInCombat && !Paused && CorpseTransform == null)
                {
                    _enemyTargettingCommander.Update();
                }
            });

            EventManager.On(HWnd, "KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;

                if (keyRequest.ModifierKey == Keys.LShiftKey && keyRequest.Key == Keys.D4)
                {
                    KeyHandler.PressKey(Keys.Tab);
                    return;
                }

                if (keyRequest.ModifierKey != Keys.None)
                {
                    if (keyRequest.ModifierKey == Keys.F1)
                    {
                        var converter = TypeDescriptor.GetConverter(typeof(Keys));
                        var key = (Keys)converter.ConvertFromString("F" + keyRequest.Key.ToString().Replace("D", ""));
                        KeyHandler.PressKey(key);
                        return;
                    }
                    KeyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
                }
                else
                {
                    KeyHandler.PressKey(keyRequest.Key);
                }
            });

            EventManager.On(HWnd, "TooFarAway", (Event _) =>
            {
                KeyHandler.PressKey(Keys.Tab);
            });
        }
    }
}
