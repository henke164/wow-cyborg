using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WowCyborg.Core;
using WowCyborg.Core.Commanders;
using WowCyborg.Core.Handlers;

namespace WowCyborg.BotProfiles
{
    public class Looter : Bot
    {
        [DllImport("User32.dll")]
        static extern int SetForegroundWindow(IntPtr point);

        [DllImport("user32.dll", SetLastError = true)]
        internal static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

        private int _timeLeft = 60;
        private bool _isInCombat = false;
        private List<LootingCommander> _lootingCommanders;
        private List<KeyHandler> _keyHandlers;

        public Looter(IntPtr hWnd)
            : base(hWnd)
        {
            var processes = Process.GetProcessesByName("Wow");
            _lootingCommanders = new List<LootingCommander>();
            _keyHandlers = new List<KeyHandler>();
            foreach (var proc in processes)
            {
                _lootingCommanders.Add(new LootingCommander(proc.MainWindowHandle, ref _isInCombat));
                _keyHandlers.Add(new KeyHandler(proc.MainWindowHandle));
            }

            SetWindowSizeAndPosition(processes, 400);

            Task.Run(() => {
                while(true)
                {
                    Console.WriteLine(_timeLeft--);
                    Thread.Sleep(1000);
                }
            });

            RunLootHandler();
        }

        private void RunLootHandler(int index = 0)
        {
            if (_lootingCommanders.Count <= index)
            {
                index = 0;

                if (_timeLeft <= 0)
                {
                    _timeLeft = 60;
                }
                Thread.Sleep(60000);
            }

            Console.WriteLine("Loot window: " + index);

            var commander = _lootingCommanders[index];

            Thread.Sleep(200);
            _keyHandlers[index].ModifiedKeypress(Keys.LShiftKey, Keys.CapsLock);
            Thread.Sleep(500);

            _lootingCommanders[index].Loot(() =>
            {
                Thread.Sleep(200);
                _keyHandlers[index].PressKey(Keys.CapsLock);
                Thread.Sleep(100);
                RunLootHandler(index + 1);
            });
        }

        private void SetWindowSizeAndPosition(IList<Process> processes, int width)
        {
            var height = (int)(width * 0.75);
            var left = 0;
            var top = 0;
            for (var i = 0; i < processes.Count; i++)
            {
                if ((left * width) + width > Screen.PrimaryScreen.Bounds.Width)
                {
                    left = 0;
                    top++;
                }

                var rectangle = new Rectangle(left * width, top * height, width, height);

                MoveWindow(
                    processes[i].MainWindowHandle,
                    rectangle.X,
                    rectangle.Y,
                    rectangle.Width,
                    rectangle.Height,
                    true);

                left++;
            }
        }

        protected override void SetupBehaviour()
        {
        }
    }
}
