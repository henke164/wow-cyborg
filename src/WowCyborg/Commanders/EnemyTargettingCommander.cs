using System;
using System.Windows.Forms;
using WowCyborg.Utilities;

namespace WowCyborg.Commanders
{
    public class EnemyTargettingCommander
    {
        private int _framesSinceLastTargetCheck = 0;

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
            KeyHandler.PressKey(Keys.Tab);
            Console.WriteLine("check target");
        }
    }
}
