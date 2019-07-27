using System.Windows.Forms;
using WowCyborg.Core.Handlers;
using WowCyborg.Core.Utilities;

namespace WowCyborg.Core.Commanders
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
