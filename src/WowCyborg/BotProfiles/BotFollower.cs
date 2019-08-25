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
    public class BotFollower : Bot
    {
        public BotFollower(IntPtr hWnd)
            : base(hWnd)
        {
            Task.Run(() => DoRandomJumping());
        }

        private void DoRandomJumping()
        {
            KeyHandler.PressKey(Keys.Space);
            Thread.Sleep(new Random().Next(1000, 20000));
            Task.Run(() => DoRandomJumping());
        }

        private bool _isFollowing = false;

        protected override void SetupBehaviour()
        {
            EventManager.On("KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;
                if (keyRequest.ModifierKey != Keys.None)
                {
                    KeyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
                    if (keyRequest.ModifierKey == Keys.LControlKey && keyRequest.Key == Keys.D1)
                    {
                        _isFollowing = true;
                    }

                    if (keyRequest.ModifierKey == Keys.LControlKey && keyRequest.Key == Keys.D9)
                    {
                        KeyHandler.PressKey(Keys.S, 1500);
                    }

                    if (keyRequest.ModifierKey == Keys.LControlKey && keyRequest.Key == Keys.D2)
                    {
                        if (!_isFollowing)
                        {
                            return;
                        }
                        _isFollowing = false;

                        Task.Run(() =>
                        {
                            var random = new Random().Next(0, 6);
                            switch (random)
                            {
                                case 0:
                                    KeyHandler.PressKey(Keys.E, 1500);
                                    break;
                                case 1:
                                    KeyHandler.PressKey(Keys.W, 1500);
                                    break;
                                case 2:
                                    KeyHandler.PressKey(Keys.E, 1500);
                                    break;
                                case 3:
                                    KeyHandler.PressKey(Keys.S, 10);
                                    break;
                                case 4:
                                    KeyHandler.PressKey(Keys.E, 1500);
                                    KeyHandler.PressKey(Keys.W, 1500);
                                    break;
                                case 5:
                                    KeyHandler.PressKey(Keys.Q, 1500);
                                    KeyHandler.PressKey(Keys.W, 1500);
                                    break;
                            }
                        });
                    }
                }
                else
                {
                    KeyHandler.PressKey(keyRequest.Key);
                }
            });

            EventManager.On("WrongFacing", (Event _) =>
            {
                KeyHandler.PressKey(Keys.D, 75);
            });
        }
    }
}
