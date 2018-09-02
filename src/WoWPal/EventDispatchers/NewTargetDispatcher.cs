using System;
using WoWPal.Events.Abstractions;

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
            if (AddonScreenshot == null)
            {
                return;
            }

            if (AddonIsRedAt(0, AddonScreenshot.Height - 1))
            {
                if (!_hasTarget)
                {
                    return;
                }

                _hasTarget = false;
                TriggerEvent(false);
            }
            else if (AddonIsGreenAt(0, AddonScreenshot.Height - 1))
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
