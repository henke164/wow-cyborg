using System.Threading;
using System.Windows.Forms;
using WowCyborg.Core.Handlers;

namespace WowCyborg.Core.Commanders
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
            _keyHandler.PressKey(Keys.Space);
            Thread.Sleep(200);
        }
    }
}
