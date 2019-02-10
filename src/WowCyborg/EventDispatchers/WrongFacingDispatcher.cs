using System;
using WowCyborg.Models.Abstractions;

namespace WowCyborg.EventDispatchers
{
    public class WrongFacingDispatcher : AddonBehaviourEventDispatcher
    {
        public WrongFacingDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "WrongFacing";
        }

        protected override void Update()
        {
            if (AddonIsRedAt(2, 2))
            {
                TriggerEvent(true);
            }
        }
    }
}
