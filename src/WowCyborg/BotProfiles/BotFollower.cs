using System;
using System.ComponentModel;
using System.Threading;
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
            EventManager.On(HWnd, "KeyPressRequested", OnKeyPressRequested);
            EventManager.On(HWnd, "WrongFacing", WrongFacing);
        }

        private void OnKeyPressRequested(Event ev)
        {
            var keyRequest = (KeyPressRequest)ev.Data;
            if (keyRequest.ModifierKey == Keys.None)
            {
                KeyHandler.PressKey(keyRequest.Key);
                return;
            }

            if (keyRequest.ModifierKey != Keys.F1)
            {
                KeyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
                return;
            }

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
            else if (key == Keys.F7)
            {
                var proc = (int)HWnd;
                var rnd = new Random(proc);
                Thread.Sleep(rnd.Next(100, 1500));
                KeyHandler.PressKey(Keys.Space);
            }

            KeyHandler.PressKey(key);
        }

        private void WrongFacing(Event ev)
        {
            KeyHandler.PressKey(Keys.D, 75);
        }
    }
}
