using System;
using System.Windows.Forms;
using WoWPal.Handlers;
using WoWPal.Models.Abstractions;

namespace WoWPal.EventDispatchers
{
    public class WrongFacingDispatcher : AddonBehaviourEventDispatcher
    {
        private Keys _lastKey = Keys.None;
        private int _keyRepeatCount = 0;

        public WrongFacingDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "WrongFacing";

            EventManager.On("CastRequested", (Event ev) =>
            {
                if (_lastKey == (Keys)ev.Data)
                {
                    _keyRepeatCount++;
                    if (_keyRepeatCount >= 5)
                    {
                        TriggerEvent(true);
                        _keyRepeatCount = 0;
                    }
                }
                else
                {
                    _lastKey = (Keys)ev.Data;
                    _keyRepeatCount = 0;
                }
            });
        }

        protected override void Update()
        {
        }
    }
}
