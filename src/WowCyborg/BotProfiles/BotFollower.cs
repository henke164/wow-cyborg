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
        private bool _isInCombat = false;

        public BotFollower(IntPtr hWnd)
            : base(hWnd)
        {
        }
        
        private bool _isFollowing = false;

        protected override void SetupBehaviour()
        {
            EventManager.On("CombatChanged", (Event ev) =>
            {
                _isInCombat = (bool)ev.Data;
            });
            
            EventManager.On("KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;
                if (keyRequest.ModifierKey != Keys.None)
                {
                    KeyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
                    if (keyRequest.ModifierKey == Keys.LShiftKey && keyRequest.Key == Keys.D8)
                    {
                        _isFollowing = true;
                    }

                    if (keyRequest.ModifierKey == Keys.LShiftKey && keyRequest.Key == Keys.D9)
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
