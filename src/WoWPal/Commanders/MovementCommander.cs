using System.Windows.Forms;
using WoWPal.Utilities;

namespace WoWPal.Commanders
{
    public class MovementCommander
    {
        private bool _isMoving = false;

        public void MoveToLocation(Vector3 location)
        {
            _isMoving = true;
            KeyHandler.HoldKey(Keys.W);
        }

        public void Stop()
        {
            if (_isMoving)
            {
                _isMoving = false;
                KeyHandler.ReleaseKey(Keys.W);
            }
        }
    }
}
