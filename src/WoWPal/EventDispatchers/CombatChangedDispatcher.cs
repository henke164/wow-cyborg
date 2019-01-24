using System;
using WoWPal.Models.Abstractions;

namespace WoWPal.EventDispatchers
{
    public class CombatChangedDispatcher : AddonBehaviourEventDispatcher
    {
        private bool _inCombat = false;

        public CombatChangedDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "CombatChanged";
        }

        protected override void Update()
        {
            if (AddonIsRedAt(0, 0))
            {
                if (!_inCombat)
                {
                    return;
                }

                _inCombat = false;
                TriggerEvent(false);
            }
            else if (AddonIsGreenAt(0, 0))
            {
                if (_inCombat)
                {
                    return;
                }

                _inCombat = true;
                TriggerEvent(true);
            }
        }
    }
}
