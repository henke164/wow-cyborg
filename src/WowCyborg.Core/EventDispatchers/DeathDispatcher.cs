using System;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.Core.EventDispatchers
{
    public class DeathDispatcher : AddonBehaviourEventDispatcher
    {
        private bool _isDead = false;

        public DeathDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "DeathChanged";
        }

        protected override void Update()
        {
            if (AddonIsBlueAt(1, 2))
            {
                if (_isDead)
                {
                    return;
                }

                _isDead = true;
                TriggerEvent(true);
            }
            else if (AddonIsRedAt(1, 2) || AddonIsGreenAt(1, 2))
            {
                if (!_isDead)
                {
                    return;
                }

                _isDead = false;
                TriggerEvent(false);
            }
        }
    }
}
