using System.Threading.Tasks;
using WoWPal.Handlers;
using WoWPal.Utilities;

namespace WoWPal.Commanders
{
    public class MovementCommander
    {
        private bool _isMoving = false;

        public async Task MoveToLocation(Vector3 location)
        {
            await Task.Delay(500);
            var mousePos = await InputHandler.CenterMouseAsync();

            await Task.Delay(100);
            InputHandler.MiddleMouseDown((int)mousePos.X, (int)mousePos.Y);

            await Task.Delay(100);
            InputHandler.MiddleMouseUp((int)mousePos.X, (int)mousePos.Y);
        }

        public async Task StopAsync()
        {
            await Task.Delay(100);
            var mousePos = await InputHandler.CenterMouseAsync();

            await Task.Delay(100);
            InputHandler.LeftMouseDown((int)mousePos.X, (int)mousePos.Y);
            await Task.Delay(10);
            InputHandler.RightMouseDown((int)mousePos.X, (int)mousePos.Y);

            await Task.Delay(100);
            InputHandler.LeftMouseUp((int)mousePos.X, (int)mousePos.Y);
            await Task.Delay(10);
            InputHandler.RightMouseUp((int)mousePos.X, (int)mousePos.Y);
        }
    }
}
