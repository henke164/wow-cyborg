using System;
using System.Collections.Generic;
using System.Windows.Forms;
using WoWPal.CombatHandler.Models;

namespace WoWPal.CombatHandler.Rotators
{
    public class MonkRotator : CombatRotator
    {
        public MonkRotator(Func<bool> checkSuccessfulCast)
            : base(checkSuccessfulCast)
        {
            SingleTargetSpellRotation = new List<Spell>
            {
                new Dot
                {
                    Name = "Provoke",
                    Button = Keys.D1,
                    Cooldown = 8,
                    Duration = 30,
                },
                new Spell
                {
                    Name = "BlackoutStrike",
                    Button = Keys.D3,
                    Cooldown = 3,
                },
                new Spell
                {
                    Name = "BlackStrike",
                    Button = Keys.D4,
                    Cooldown = 7,
                },
                new Spell
                {
                    Name = "HealinElixir",
                    Button = Keys.D5,
                    Cooldown = 15,
                },
                new Spell
                {
                    Name = "TigerPalm",
                    Button = Keys.D2,
                    Cooldown = 1,
                },
            };
        }
    }
}
