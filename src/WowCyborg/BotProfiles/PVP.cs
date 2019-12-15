using System;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WowCyborg.Core;
using WowCyborg.Core.Handlers;
using WowCyborg.Core.Models;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.BotProfiles
{
    public class PVP : Bot
    {
        private DateTime _queuedAt = DateTime.MinValue;
        private DateTime _joinedAt = DateTime.MinValue;
        private bool _bgLogicStarted = false;

        public PVP(IntPtr hWnd)
            : base (hWnd)
        {
        }

        protected override void SetupBehaviour()
        {
            EventManager.On("KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;
                if (keyRequest.Key == Keys.D0 && keyRequest.ModifierKey == Keys.LShiftKey)
                {
                    if ((DateTime.Now - _queuedAt).Seconds < 10)
                    {
                        return;
                    }
                    _queuedAt = DateTime.Now;
                    Task.Run(Queue);
                }
                else if (keyRequest.Key == Keys.D9 && keyRequest.ModifierKey == Keys.LShiftKey)
                {
                    if ((DateTime.Now - _joinedAt).Seconds < 10)
                    {
                        return;
                    }
                    _joinedAt = DateTime.Now;
                    Task.Run(Join);
                }
                else if (keyRequest.Key == Keys.D1 && keyRequest.ModifierKey == Keys.LShiftKey)
                {
                    if ((DateTime.Now - _joinedAt).Seconds < 10)
                    {
                        return;
                    }
                    _joinedAt = DateTime.Now;
                    Task.Run(Leave);
                }

                if (keyRequest.Key == Keys.D9 && keyRequest.ModifierKey == Keys.None)
                {
                    if (_bgLogicStarted)
                    {
                        return;
                    }

                    _bgLogicStarted = true;
                    Task.Run(DoBgLogic);
                }

                if (keyRequest.ModifierKey != Keys.None)
                {
                    KeyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
                }
                else
                {
                    KeyHandler.PressKey(keyRequest.Key);
                }
            });
        }

        private void Queue()
        {
            Thread.Sleep(3000);
            MouseHandler.LeftClick(235, 235);
            Thread.Sleep(2000);
            MouseHandler.LeftClick(200, 480);
        }

        private void Join()
        {
            Thread.Sleep(3000);
            MouseHandler.LeftClick(895, 175);
            Thread.Sleep(2000);
        }

        private void Leave()
        {
            Console.WriteLine("Leave....");
            Thread.Sleep(3000);
            MouseHandler.LeftClick(980, 700);
            _bgLogicStarted = false;
            Thread.Sleep(5000);
        }

        private async Task DoBgLogic()
        {
            Console.WriteLine("Bg logic....");
            Thread.Sleep(30000);
            KeyHandler.PressKey(Keys.A, 400);
            KeyHandler.PressKey(Keys.W, 2500);
            KeyHandler.PressKey(Keys.D, 400);
            KeyHandler.HoldKey(Keys.W);
            Thread.Sleep(5000);
            KeyHandler.PressKey(Keys.A, 100);
            Thread.Sleep(5000);
            KeyHandler.ReleaseKey(Keys.W);
            KeyHandler.PressKey(Keys.D, 100);
            Thread.Sleep(80000);
            KeyHandler.HoldKey(Keys.W);
            Thread.Sleep(5000);
            KeyHandler.ReleaseKey(Keys.W);
            Thread.Sleep(1000);
            KeyHandler.PressKey(Keys.F, 100);
            Thread.Sleep(5000);
            KeyHandler.HoldKey(Keys.W);
            Thread.Sleep(5000);
            KeyHandler.PressKey(Keys.A, new Random().Next(0,1000));

            while (_bgLogicStarted)
            {
                KeyHandler.PressKey(Keys.Space, 200);
                Thread.Sleep(10000);
            }
            KeyHandler.ReleaseKey(Keys.W);
        }
    }
}
