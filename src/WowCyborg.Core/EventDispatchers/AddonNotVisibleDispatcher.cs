using System;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.Core.EventDispatchers
{
    public class AddonNotVisibleDispatcher : AddonBehaviourEventDispatcher
    {
        private int addonUnseenTimes = 0;
        private bool isVisible = true;

        public AddonNotVisibleDispatcher()
        {
            EventName = "AddonNotVisible";
        }

        protected override void GameHandleUpdate(IntPtr hWnd)
        {
            var color = GetColorAt(hWnd, 1, 1);
            if (color.R != 255 || color.G != 0 || color.B != 255)
            {
                addonUnseenTimes++;
                if (addonUnseenTimes == 50)
                {
                    isVisible = false;
                    TriggerEvent(hWnd, true);
                }
            }
            else
            {
                addonUnseenTimes = 0;
                if (!isVisible)
                {
                    isVisible = true;
                    TriggerEvent(hWnd, false);
                }
            }
        }

        protected override void Update()
        {
        }
    }
}
