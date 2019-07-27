using System;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.Core.EventDispatchers
{
    public class WrongFacingDispatcher : AddonBehaviourEventDispatcher
    {
        private bool _triggeredOnce = false;

        public WrongFacingDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "WrongFacing";
        }

        protected override void Update()
        {
            if (AddonIsRedAt(2, 2))
            {
                if (!_triggeredOnce)
                {
                    TriggerEvent(true);
                    _triggeredOnce = true;
                }
            }

            _triggeredOnce = false;
        }
    }
}
