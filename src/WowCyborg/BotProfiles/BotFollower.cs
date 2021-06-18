using System;
using System.ComponentModel;
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
        }
        
        private bool _isFollowing = false;

        protected override void SetupBehaviour()
        {
            EventManager.On(HWnd, "KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;
                if (keyRequest.ModifierKey != Keys.None)
                {
                    if (keyRequest.ModifierKey == Keys.F1)
                    {
                        var converter = TypeDescriptor.GetConverter(typeof(Keys));
                        var key = (Keys)converter.ConvertFromString("F" + keyRequest.Key.ToString().Replace("D", ""));

                        if (key == Keys.F8)
                        {
                            _isFollowing = true;
                        }
                        else if (key == Keys.F9)
                        {
                            if (_isFollowing)
                            {
                                _isFollowing = false;

                                KeyHandler.PressKey(Keys.S, 10);
                            }
                        }
                        KeyHandler.PressKey(key);
                    }
                    else
                    {
                        KeyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
                    }
                }
                else
                {
                    KeyHandler.PressKey(keyRequest.Key);
                }
            });

            EventManager.On(HWnd, "WrongFacing", (Event _) =>
            {
                KeyHandler.PressKey(Keys.D, 75);
            });
        }
    }
}
