using System;
using System.Windows.Forms;
using WowCyborg.Handlers;
using WowCyborg.Models;
using WowCyborg.Models.Abstractions;

namespace WowCyborg.EventDispatchers
{
    public class WrongFacingDispatcher : AddonBehaviourEventDispatcher
    {
        private Keys _lastKey = Keys.None;
        private int _keyRepeatCount = 0;

        public WrongFacingDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "WrongFacing";

            EventManager.On("KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;

                if (_lastKey == keyRequest.Key)
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
                    _lastKey = keyRequest.Key;
                    _keyRepeatCount = 0;
                }
            });
        }

        protected override void Update()
        {
        }
    }
}
