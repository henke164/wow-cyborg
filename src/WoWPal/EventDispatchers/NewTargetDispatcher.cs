using System;
using WoWPal.Commanders;
using WoWPal.Events;
using WoWPal.Events.Abstractions;
using WoWPal.Handlers;
using WoWPal.Utilities;

namespace WoWPal.EventDispatchers
{
    public class NewTargetDispatcher : AddonBehaviourEventDispatcher
    {
        private bool? _hasTarget = null;
        
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

            if (AddonIsGreenAt(0, AddonScreenshot.Height - 1))
            {
                if (!_hasTarget.HasValue)
                {
                    _hasTarget = false;
                }
                else if (_hasTarget == true)
                {
                    _hasTarget = false;
                    TriggerEvent(false);
                }
            }
            else if (AddonIsRedAt(0, AddonScreenshot.Height - 1))
            {
                if (!_hasTarget.HasValue)
                {
                    _hasTarget = true;
                }
                else if (_hasTarget == false)
                {
                    _hasTarget = true;
                    TriggerEvent(true);
                }
            }
        }
    }
}
