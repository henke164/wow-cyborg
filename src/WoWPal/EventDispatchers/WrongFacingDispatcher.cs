using System;
using WoWPal.Events;
using WoWPal.Events.Abstractions;

namespace WoWPal.EventDispatchers
{
    public class WrongFacingDispatcher : AddonBehaviourEventDispatcher
    {
        private DateTime _lastCast;

        public WrongFacingDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "WrongFacing";

            _lastCast = DateTime.Now;

            EventManager.On("CastRequested", (Event ev) =>
            {
                var lastCastAttempt = (DateTime.Now - _lastCast).TotalMilliseconds;
                if (lastCastAttempt <= 550)
                {
                    TriggerEvent(true);
                }
                _lastCast = DateTime.Now;
            });
        }

        protected override void Update()
        {
        }
    }
}
