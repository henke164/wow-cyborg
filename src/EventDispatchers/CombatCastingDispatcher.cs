using System;
using System.Collections.Generic;
using System.Windows.Forms;
using WowCyborg.Models;
using WowCyborg.Models.Abstractions;

namespace WowCyborg.EventDispatchers
{
    public class CombatCastingDispatcher : AddonBehaviourEventDispatcher
    {
        private Dictionary<IntPtr, DateTime> _lastCasts = new Dictionary<IntPtr, DateTime>();

        public CombatCastingDispatcher()
        {
            EventName = "KeyPressRequested";
        }

        protected override void GameHandleUpdate(IntPtr hWnd)
        {
            var now = DateTime.Now;

            if (!AddonScreenshots.ContainsKey(hWnd))
            {
                return;
            }

            if (!_lastCasts.ContainsKey(hWnd))
            {
                _lastCasts.Add(hWnd, now);
            }

            if ((now - _lastCasts[hWnd]).TotalMilliseconds < 150)
            {
                return;
            }

            var isLetter = GetCharacterAt(hWnd, 2, 2) == "4";
            var requestedKey = GetCharacterAt(hWnd, 3, 2);

            if (requestedKey == "")
            {
                return;
            }

            if (isLetter)
            {
                var letterCodes = new Keys[] { GetKeyFromCharacter(requestedKey), GetKeyFromCharacter(GetCharacterAt(hWnd, 4, 2)) };
                var letterKey = GetKeyFromLetterCodes(letterCodes);
                if (letterKey != Keys.None)
                {
                    _lastCasts[hWnd] = now;
                    TriggerEvent(hWnd, new KeyPressRequest
                    {
                        ModifierKey = Keys.None,
                        Key = letterKey
                    });
                }
            }
            else
            {
                var key = GetKeyFromCharacter(requestedKey);
                if (key != Keys.None)
                {
                    var modifier = GetModifierKeyAt(hWnd, 4, 2);
                    _lastCasts[hWnd] = now;
                    TriggerEvent(hWnd, new KeyPressRequest
                    {
                        ModifierKey = modifier,
                        Key = key
                    });
                }
            }
        }

        protected override void Update()
        {
        }

        private Keys GetKeyFromCharacter(string character)
        {
            switch (character)
            {
                case "1": return Keys.D1;
                case "2": return Keys.D2;
                case "3": return Keys.D3;
                case "4": return Keys.D4;
                case "5": return Keys.D5;
                case "6": return Keys.D6;
                case "7": return Keys.D7;
                case "8": return Keys.D8;
                case "9": return Keys.D9;
                case "0": return Keys.D0;
            }

            return Keys.None;
        }

        private Keys GetKeyFromLetterCodes(Keys[] letterCodes)
        {
            var c1 = letterCodes[0];
            var c2 = letterCodes[1];

            if (c1 == Keys.D0)
            {
                if (c2 == Keys.D1)
                {
                    return Keys.A;
                }
                if (c2 == Keys.D2)
                {
                    return Keys.B;
                }
                if (c2 == Keys.D3)
                {
                    return Keys.C;
                }
                if (c2 == Keys.D4)
                {
                    return Keys.D;
                }
                if (c2 == Keys.D5)
                {
                    return Keys.E;
                }
                if (c2 == Keys.D6)
                {
                    return Keys.F;
                }
                if (c2 == Keys.D7)
                {
                    return Keys.G;
                }
                if (c2 == Keys.D8)
                {
                    return Keys.H;
                }
                if (c2 == Keys.D9)
                {
                    return Keys.I;
                }
            }

            if (c1 == Keys.D1)
            {
                if (c2 == Keys.D0)
                {
                    return Keys.J;
                }
                if (c2 == Keys.D1)
                {
                    return Keys.K;
                }
                if (c2 == Keys.D2)
                {
                    return Keys.L;
                }
                if (c2 == Keys.D3)
                {
                    return Keys.M;
                }
                if (c2 == Keys.D4)
                {
                    return Keys.N;
                }
                if (c2 == Keys.D5)
                {
                    return Keys.O;
                }
                if (c2 == Keys.D6)
                {
                    return Keys.P;
                }
                if (c2 == Keys.D7)
                {
                    return Keys.Q;
                }
                if (c2 == Keys.D8)
                {
                    return Keys.R;
                }
                if (c2 == Keys.D9)
                {
                    return Keys.S;
                }
            }

            if (c1 == Keys.D2)
            {
                if (c2 == Keys.D0)
                {
                    return Keys.T;
                }
                if (c2 == Keys.D1)
                {
                    return Keys.U;
                }
                if (c2 == Keys.D2)
                {
                    return Keys.V;
                }
                if (c2 == Keys.D3)
                {
                    return Keys.W;
                }
                if (c2 == Keys.D4)
                {
                    return Keys.X;
                }
                if (c2 == Keys.D5)
                {
                    return Keys.Y;
                }
                if (c2 == Keys.D6)
                {
                    return Keys.Z;
                }
            }

            return Keys.None;
        }
    }
}
