using System.Windows.Forms;
using WowCyborg.Utilities;

namespace WowCyborg.Commanders
{
    public class MovementCommander
    {
        public void MoveToLocation(Vector3 location)
        {
            KeyHandler.HoldKey(Keys.W);
        }

        public void Stop()
        {
            KeyHandler.ReleaseKey(Keys.W);
        }
    }
}
