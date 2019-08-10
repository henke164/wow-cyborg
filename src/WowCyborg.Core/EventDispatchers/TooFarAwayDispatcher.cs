using System;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.Core.EventDispatchers
{
    public class TooFarAwayDispatcher : AddonBehaviourEventDispatcher
    {
        private int _framesSinceLastCheck = 0;

        public TooFarAwayDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "TooFarAway";
        }

        protected override void Update()
        {
            if (AddonIsBlueAt(2, 2))
            {
                if (_framesSinceLastCheck == 0)
                {
                    TriggerEvent(true);
                }

                _framesSinceLastCheck++;

                if (_framesSinceLastCheck > 50)
                {
                    _framesSinceLastCheck = 0;
                }
            }
            else
            {
                _framesSinceLastCheck = 0;
            }
        }
    }
}
