using System.Windows.Forms;
using WowCyborg.Handlers;
using WowCyborg.Models;
using WowCyborg.Models.Abstractions;
using WowCyborg.Utilities;

namespace WowCyborg.Runners
{
    public class AutoCaster : BotRunnerBase
    {
        public AutoCaster()
        {
        }

        protected override void SetupBehaviour()
        {
            EventManager.On("KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;
                if (keyRequest.ModifierKey != Keys.None)
                {
                    KeyHandler.PressKey(keyRequest.ModifierKey, 50);
                    KeyHandler.PressKey(keyRequest.Key);
                }
                else
                {
                    KeyHandler.PressKey(keyRequest.Key);
                }
            });
        }
    }
}
