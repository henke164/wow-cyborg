using System.Windows.Forms;
using WowCyborg.Handlers;
using WowCyborg.Models;
using WowCyborg.Models.Abstractions;

namespace WowCyborg.Runners
{
    public class AutoCaster : BotRunnerBase
    {
        protected override void SetupBehaviour()
        {
            EventManager.On("KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;
                if (keyRequest.ModifierKey != Keys.None)
                {
                    KeyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
                }
                else
                {
                    KeyHandler.PressKey(keyRequest.Key);
                }
            });
        }
    }
}
