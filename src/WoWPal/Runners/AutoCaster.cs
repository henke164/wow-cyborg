using System.Windows.Forms;
using WoWPal.Handlers;
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
            EventManager.On("CastRequested", (Event ev) =>
            {
                var button = (Keys)ev.Data;
                KeyHandler.PressKey(button);
            });

            EventManager.On("WrongFacing", (Event _) =>
            {
                //KeyHandler.PressKey(Keys.D, 500);
            });
        }
    }
}
