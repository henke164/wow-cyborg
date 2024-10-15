using System;
using System.ComponentModel;
using System.Windows.Forms;
using WowCyborg.EventDispatchers;
using WowCyborg.Handlers;
using WowCyborg.Models.Abstractions;
using WowCyborg.Models;
using System.Net;

namespace WowCyborg
{
    public class Bot
    {
        public IntPtr Hwnd;
        private KeyHandler _keyHandler;

        public Bot(IntPtr hWnd)
        {
            Hwnd = hWnd;
            _keyHandler = new KeyHandler(hWnd);

            EventManager.StartEventDispatcher<ScreenChangedDispatcher>(hWnd);
            EventManager.StartEventDispatcher<CombatChangedDispatcher>(hWnd);
            EventManager.StartEventDispatcher<CombatCastingDispatcher>(hWnd);
            EventManager.On(hWnd, "KeyPressRequested", OnKeyPressRequested);
        }

        public void PressKey(Keys key)
        {
            _keyHandler.PressKey(key);
        }

        public void ModifiedPressKey(Keys modifierKey, Keys key)
        {
            _keyHandler.ModifiedKeypress(modifierKey, key);
        }

        private void OnKeyPressRequested(Event ev)
        {
            var keyRequest = (KeyPressRequest)ev.Data;
            if (keyRequest.ModifierKey != Keys.None)
            {
                if (keyRequest.ModifierKey == Keys.F1)
                {
                    var converter = TypeDescriptor.GetConverter(typeof(Keys));
                    var key = (Keys)converter.ConvertFromString("F" + keyRequest.Key.ToString().Replace("D", ""));
                    _keyHandler.PressKey(key);
                    return;
                }
                _keyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
            }
            else
            {
                _keyHandler.PressKey(keyRequest.Key);
            }
        }
    }
}
