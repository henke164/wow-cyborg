using System;
using System.ComponentModel;
using System.Windows.Forms;
using WowCyborg.Core;
using WowCyborg.Core.Handlers;
using WowCyborg.Core.Models;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.BotProfiles
{
    public class AutoCaster : Bot
    {
        public AutoCaster(IntPtr hWnd) 
            : base(hWnd)
        {
        }

        protected override void SetupBehaviour()
        {
            EventManager.On("KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;
                if (keyRequest.ModifierKey != Keys.None)
                {
                    if (keyRequest.ModifierKey == Keys.F1)
                    {
                        var converter = TypeDescriptor.GetConverter(typeof(Keys));
                        var key = (Keys)converter.ConvertFromString("F" + keyRequest.Key.ToString().Replace("D", ""));
                        KeyHandler.PressKey(key);
                        return;
                    }
                    KeyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
                }
                else
                {
                    KeyHandler.PressKey(keyRequest.Key);
                }
            });
        }
    }
}
