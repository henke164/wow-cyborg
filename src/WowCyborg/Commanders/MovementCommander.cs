using System.Windows.Forms;
using WowCyborg.Handlers;
using WowCyborg.Utilities;

namespace WowCyborg.Commanders
{
    public class MovementCommander
    {
        private KeyHandler _keyHandler;

        public MovementCommander(KeyHandler keyHandler)
        {
            _keyHandler = keyHandler;
        }

        public void MoveToLocation(Vector3 location)
        {
            _keyHandler.HoldKey(Keys.W);
        }

        public void Stop()
        {
            _keyHandler.ReleaseKey(Keys.W);
        }
    }
}
