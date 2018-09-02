using System.Linq;
using System.Threading.Tasks;
using WoWPal.Handlers;
using WoWPal.Models;
using WoWPal.Utilities;

namespace WoWPal.Commanders
{
    public class ActionbarCommander
    {
        private ActionbarSettings _settings;

        public ActionbarCommander(ActionbarSettings settings)
            => _settings = settings;
        
        public static ActionbarCommander FromSettingFile(string filePath)
            => new ActionbarCommander(SettingsLoader.LoadSettings<ActionbarSettings>(filePath));
        
        public async Task ClickOnActionBarAsync(string name)
        {
            var button = _settings.Buttons.FirstOrDefault(b => b.Name == name);
            if (button == null)
            {
                return;
            }

            await Task.Delay(10);
            InputHandler.SetCursorPos(button.X, button.Y);
            InputHandler.LeftMouseDown(button.X, button.Y);

            await Task.Delay(50);
            InputHandler.LeftMouseUp(button.X, button.Y);

            await Task.Delay(50);
            await InputHandler.CenterMouseAsync();
        }
    }
}
