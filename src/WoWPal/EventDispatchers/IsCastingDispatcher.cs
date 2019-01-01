using System;
using WoWPal.Events.Abstractions;

namespace WoWPal.EventDispatchers
{
    public class IsCastingDispatcher : AddonBehaviourEventDispatcher
    {
        private bool _isCasting = false;
        private int _seenGreen = 0;
        private int _total = 0;

        public IsCastingDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "IsCasting";
        }

        protected override void Update()
        {
            _total++;

            if (AddonIsGreenAt(AddonScreenshot.Width - 1, 0))
            {
                _seenGreen++;
            }

            if (_total > 30)
            {
                var isCasting = _seenGreen > 10;
                _seenGreen = 0;
                _total = 0;

                if (isCasting != _isCasting)
                {
                    _isCasting = isCasting;
                    TriggerEvent(_isCasting);
                }
            }
        }
    }
}
