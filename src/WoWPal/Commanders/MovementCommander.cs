using System.Windows.Forms;
using WoWPal.Utilities;

namespace WoWPal.Commanders
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
