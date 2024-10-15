using System;
using WowCyborg.Models.Abstractions;

namespace WowCyborg.EventDispatchers
{
    public class CombatChangedDispatcher : AddonBehaviourEventDispatcher
    {
        private bool _inCombat = false;

        public CombatChangedDispatcher()
            : base()
        {
            EventName = "CombatChanged";
        }

        protected override void GameHandleUpdate(IntPtr hWnd)
        {
            if (AddonIsRedAt(hWnd, 1, 2))
            {
                if (!_inCombat)
                {
                    return;
                }

                _inCombat = false;
                TriggerEvent(hWnd, false);
            }
            else if (AddonIsGreenAt(hWnd, 1, 2))
            {
                if (_inCombat)
                {
                    return;
                }

                _inCombat = true;
                TriggerEvent(hWnd, true);
            }
        }

        protected override void Update()
        {
        }
    }
}
