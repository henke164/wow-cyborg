using System.Linq;
using System.Threading;
using WoWPal.Handlers;
using WoWPal.Models;
using WoWPal.Utilities;

namespace WoWPal.Commanders
{
    public class ActionbarCommander
    {
        private ActionbarSettings _settings;

        public ActionbarCommander(ActionbarSettings settings)
        {
            _settings = settings;
        }

        public static ActionbarCommander FromSettingFile(string filePath)
            => new ActionbarCommander(SettingsLoader.LoadSettings<ActionbarSettings>(filePath));
        
        public void ClickOnActionBar(string name)
        {
            var button = _settings.Buttons.FirstOrDefault(b => b.Name == name);
            if (button == null)
            {
                return;
            }
            Thread.Sleep(10);
            InputHandler.SetCursorPos(button.X, button.Y);
            InputHandler.LeftMouseDown(button.X, button.Y);
            Thread.Sleep(50);
            InputHandler.LeftMouseUp(button.X, button.Y);
            Thread.Sleep(10);
            InputHandler.CenterMouse();
        }
    }
}
