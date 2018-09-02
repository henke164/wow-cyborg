using System.Threading;
using WoWPal.Handlers;
using WoWPal.Utilities;

namespace WoWPal.Commanders
{
    public class MovementCommander
    {
        private bool _isMoving = false;

        public void MoveToLocation(Vector3 location)
        {
            if (!_isMoving)
            {
                ToggleMovement();
            }
        }

        public void Stop()
        {
            if (_isMoving)
            {
                ToggleMovement();
            }
        }

        public void ToggleMovement()
        {
            _isMoving = !_isMoving;

            var mousePos = InputHandler.CenterMouse();
            InputHandler.MiddleMouseDown((int)mousePos.X, (int)mousePos.Y);
            Thread.Sleep(10);
            InputHandler.MiddleMouseUp((int)mousePos.X, (int)mousePos.Y);
        }
    }
}
