using System;
using System.Collections.Generic;
using System.Windows.Forms;
using WowCyborg.Core.Models;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.Core.EventDispatchers
{
    public class CombatCastingDispatcher : AddonBehaviourEventDispatcher
    {
        private Dictionary<IntPtr, DateTime> _lastCasts = new Dictionary<IntPtr, DateTime>();

        public CombatCastingDispatcher()
        {
            EventName = "KeyPressRequested";
        }

        protected override void GameHandleUpdate(IntPtr hWnd)
        {
            var now = DateTime.Now;

            if (!AddonScreenshots.ContainsKey(hWnd))
            {
                return;
            }

            if (!_lastCasts.ContainsKey(hWnd))
            {
                _lastCasts.Add(hWnd, now);
            }

            if ((now - _lastCasts[hWnd]).TotalMilliseconds < 150)
            {
                return;
            }

            var requestedKey = GetCharacterAt(hWnd, 3, 2);

            if (requestedKey == "")
            {
                return;
            }

            var key = GetKeyFromCharacter(requestedKey);
            if (key != Keys.None)
            {
                var modifier = GetModifierKeyAt(hWnd, 4, 2);
                _lastCasts[hWnd] = now;
                TriggerEvent(hWnd, new KeyPressRequest
                {
                    ModifierKey = modifier,
                    Key = key
                });
            }
        }

        protected override void Update()
        {
        }

        private Keys GetKeyFromCharacter(string character)
        {
            switch (character)
            {
                case "1": return Keys.D1;
                case "2": return Keys.D2;
                case "3": return Keys.D3;
                case "4": return Keys.D4;
                case "5": return Keys.D5;
                case "6": return Keys.D6;
                case "7": return Keys.D7;
                case "8": return Keys.D8;
                case "9": return Keys.D9;
                case "0": return Keys.D0;
            }

            return Keys.None;
        }
    }
}
