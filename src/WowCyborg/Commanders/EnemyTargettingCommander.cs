using System.Threading;
using System.Windows.Forms;
using WowCyborg.Handlers;

namespace WowCyborg.Commanders
{
    public class EnemyTargettingCommander
    {
        private int _framesSinceLastTargetCheck = 0;
        private KeyHandler _keyHandler;

        public EnemyTargettingCommander(KeyHandler keyHandler)
        {
            _keyHandler = keyHandler;
        }

        public void Update()
        {
            _framesSinceLastTargetCheck++;

            if (_framesSinceLastTargetCheck >= 5)
            {
                _framesSinceLastTargetCheck = 0;
                TargetNearestEnemy();
            }
        }

        public void TargetNearestEnemy()
        {
            _keyHandler.PressKey(Keys.Tab);
            Thread.Sleep(200);
            _keyHandler.PressKey(Keys.D0);
        }
    }
}
