using System.Windows.Forms;
using WowCyborg.Handlers;
using WowCyborg.Models;
using WowCyborg.Models.Abstractions;
using WowCyborg.Utilities;

namespace WowCyborg.Runners
{
    public class BotFollower : BotRunnerBase
    {
        public BotFollower()
        {
        }

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

            EventManager.On("WrongFacing", (Event _) =>
            {
                KeyHandler.PressKey(Keys.D, 75);
            });
        }
    }
}
