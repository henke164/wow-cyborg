using System;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.Core.EventDispatchers
{
    public class DeathDispatcher : AddonBehaviourEventDispatcher
    {
        private bool _isDead = false;

        public DeathDispatcher()
        {
            EventName = "DeathChanged";
        }

        protected override void GameHandleUpdate(IntPtr hWnd)
        {
            if (AddonIsBlueAt(hWnd, 1, 2))
            {
                if (_isDead)
                {
                    return;
                }

                _isDead = true;
                TriggerEvent(hWnd, true);
            }
            else if (AddonIsRedAt(hWnd, 1, 2) || AddonIsGreenAt(hWnd, 1, 2))
            {
                if (!_isDead)
                {
                    return;
                }

                _isDead = false;
                TriggerEvent(hWnd, false);
            }
        }

        protected override void Update()
        {
        }
    }
}
