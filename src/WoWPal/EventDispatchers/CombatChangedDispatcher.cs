using System;
using WoWPal.Events.Abstractions;

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
            try
            {
                if (AddonIsGreenAt(0, 0))
                {
                    if (_inCombat)
                    {
                        _inCombat = false;
                        TriggerEvent(false);
                    }
                }
                else if (!_inCombat)
                {
                    _inCombat = true;
                    TriggerEvent(true);
                }
            }
            catch (Exception ex)
            {

            }
        }
    }
}
