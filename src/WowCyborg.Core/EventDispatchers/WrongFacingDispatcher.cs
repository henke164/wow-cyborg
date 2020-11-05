using System;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.Core.EventDispatchers
{
    public class WrongFacingDispatcher : AddonBehaviourEventDispatcher
    {
        private bool _triggeredOnce = false;

        public WrongFacingDispatcher()
        {
            EventName = "WrongFacing";
        }

        protected override void GameHandleUpdate(IntPtr hWnd)
        {
            if (AddonIsRedAt(hWnd, 2, 2))
            {
                if (!_triggeredOnce)
                {
                    TriggerEvent(hWnd, true);
                    _triggeredOnce = true;
                }
            }

            _triggeredOnce = false;
        }

        protected override void Update()
        {
        }
    }
}
