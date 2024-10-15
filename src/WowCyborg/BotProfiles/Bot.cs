using System;
using System.Threading.Tasks;
using WowCyborg.EventDispatchers;
using WowCyborg.Handlers;

namespace WowCyborg
{
    public abstract class Bot
    {
        protected IntPtr HWnd;

        protected KeyHandler KeyHandler;
        protected bool Paused = false;

        private Action _onDestinationReached;
        private Task _runningTask;

        public Bot(IntPtr hWnd)
        {
            HWnd = hWnd;

            KeyHandler = new KeyHandler(hWnd);

            StartEventDispatchers();
            SetupBehaviour();
        }

        protected abstract void SetupBehaviour();

        private void StartEventDispatchers()
        {
            EventManager.StartEventDispatcher<ScreenChangedDispatcher>(HWnd);
            EventManager.StartEventDispatcher<CombatChangedDispatcher>(HWnd);
            EventManager.StartEventDispatcher<CombatCastingDispatcher>(HWnd);
            EventManager.StartEventDispatcher<AddonNotVisibleDispatcher>(HWnd);
        }
    }
}
