using System;
using WowCyborg.Models.Abstractions;

namespace WowCyborg.EventDispatchers
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
            if (AddonIsRedAt(1, 2))
            {
                if (!_inCombat)
                {
                    return;
                }

                _inCombat = false;
                TriggerEvent(false);
            }
            else if (AddonIsGreenAt(1, 2))
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
