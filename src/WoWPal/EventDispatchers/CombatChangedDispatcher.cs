using System;
using WoWPal.Events.Abstractions;

namespace WoWPal.EventDispatchers
{
    public class CombatChangedDispatcher : AddonBehaviourEventDispatcher
    {
        private bool? _inCombat = null;

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
                    if (!_inCombat.HasValue)
                    {
                        _inCombat = false;
                    }
                    else if (_inCombat == true)
                    {
                        _inCombat = false;
                        TriggerEvent(false);
                    }
                }
                else if (AddonIsRedAt(0, 0))
                {
                    if (!_inCombat.HasValue)
                    {
                        _inCombat = true;
                    }
                    else if (_inCombat == false)
                    {
                        _inCombat = true;
                        TriggerEvent(true);
                    }
                }
            }
            catch (Exception ex)
            {

            }
        }
    }
}
