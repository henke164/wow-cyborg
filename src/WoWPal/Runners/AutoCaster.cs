using System.Windows.Forms;
using WoWPal.Handlers;
using WoWPal.Models;
using WoWPal.Models.Abstractions;
using WoWPal.Utilities;

namespace WoWPal.Runners
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
