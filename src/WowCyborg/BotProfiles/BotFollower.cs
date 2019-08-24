using System;
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
                        KeyHandler.PressKey(Keys.S, 10);
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
