using System;
using WoWPal.Models.Abstractions;

namespace WoWPal.EventDispatchers
{
    public class NewTargetDispatcher : AddonBehaviourEventDispatcher
    {
        public bool _hasTarget = false;
        
        public NewTargetDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "TargetInRange";
        }

        protected override void Update()
        {
            if (AddonIsRedAt(2, 2))
            {
                if (!_hasTarget)
                {
                    return;
                }

                _hasTarget = false;
                TriggerEvent(false);
            }
            else if (AddonIsGreenAt(2, 2))
            {
                if (_hasTarget)
                {
                    return;
                }

                _hasTarget = true;
                TriggerEvent(true);
            }
        }
    }
}
