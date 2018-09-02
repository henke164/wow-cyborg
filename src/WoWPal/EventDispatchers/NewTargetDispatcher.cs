using System;
using WoWPal.Commanders;
using WoWPal.Events;
using WoWPal.Events.Abstractions;
using WoWPal.Utilities;

namespace WoWPal.EventDispatchers
{
    public class NewTargetDispatcher : AddonBehaviourEventDispatcher
    {
        private int _timer = 0;

        private ActionbarCommander _actionbarCommander;

        public NewTargetDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "TargetInRange";

            _actionbarCommander = ActionbarCommander.FromSettingFile("actionbarsettings.json");

            EventManager.On("PlayerTransformChanged", (Event ev) => {
                var currentTransform = (Transform)ev.Data;

            });
        }

        protected override void Update()
        {
            _timer++;
            if (_timer > 1000)
            {
                _actionbarCommander.ClickOnActionBar("AutoTarget");
                _timer = 0;
            }
        }
    }
}
