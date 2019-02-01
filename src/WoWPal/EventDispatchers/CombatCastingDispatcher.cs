using System;
using System.Windows.Forms;
using WoWPal.Models.Abstractions;

namespace WoWPal.EventDispatchers
{
    public class CombatCastingDispatcher : AddonBehaviourEventDispatcher
    {
        private DateTime _lastCast;

        public CombatCastingDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "CastRequested";
        }

        protected override void Update()
        {
            if (AddonScreenshot == null)
            {
                return;
            }

            if ((DateTime.Now - _lastCast).TotalMilliseconds < 500)
            {
                return;
            }

            var button = GetCharacterAt(3, 2);

            if (button == "")
            {
                return;
            }

            var key = GetKeyFromCharacter(button);

            if (key != Keys.None)
            {
                _lastCast = DateTime.Now;
                TriggerEvent(key);
            }
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
