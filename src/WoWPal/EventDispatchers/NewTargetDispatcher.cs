using System;
using WoWPal.Commanders;
using WoWPal.Events;
using WoWPal.Events.Abstractions;
using WoWPal.Handlers;
using WoWPal.Utilities;

namespace WoWPal.EventDispatchers
{
    public class NewTargetDispatcher : AddonBehaviourEventDispatcher
    {
        private bool _hasTarget = false;
        private ActionbarCommander _actionbarCommander;

        public NewTargetDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "TargetInRange";

            _actionbarCommander = ActionbarCommander.FromSettingFile("actionbarsettings.json");

            EventManager.On("PlayerTransformChanged", (Event ev) => {
                var currentTransform = (Transform)ev.Data;

                if (!InputHandler.IsRightButtonDown && !_hasTarget)
                {
                    _actionbarCommander.ClickOnActionBar("AutoTarget");
                }
            });
        }

        protected override void Update()
        {
            if (AddonScreenshot == null)
            {
                return;
            }

            if (AddonIsGreenAt(0, AddonScreenshot.Height - 1))
            {
                _hasTarget = true;
                TriggerEvent(_hasTarget);
            }
            else
            {
                _hasTarget = false;
            }
        }
    }
}
