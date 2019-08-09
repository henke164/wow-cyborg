using System;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.Core.EventDispatchers
{
    public class TooFarAwayDispatcher : AddonBehaviourEventDispatcher
    {
        private int _framesSinceLastTargetCheck = 0;

        public TooFarAwayDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "TooFarAway";
        }

        protected override void Update()
        {
            _framesSinceLastTargetCheck++;

            if (_framesSinceLastTargetCheck >= 20)
            {
                _framesSinceLastTargetCheck = 0;
                if (AddonIsBlueAt(2, 2))
                {
                    TriggerEvent(true);
                }
            }
        }
    }
}
