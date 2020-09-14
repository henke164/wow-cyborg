using System;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.Core.EventDispatchers
{
    public class TooFarAwayDispatcher : AddonBehaviourEventDispatcher
    {
        private int _framesSinceLastCheck = 0;

        public TooFarAwayDispatcher()
        {
            EventName = "TooFarAway";
        }

        protected override void GameHandleUpdate(IntPtr hWnd)
        {
            if (AddonIsBlueAt(hWnd, 2, 2))
            {
                if (_framesSinceLastCheck == 0)
                {
                    TriggerEvent(hWnd, true);
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

        protected override void Update()
        {
        }
    }
}
