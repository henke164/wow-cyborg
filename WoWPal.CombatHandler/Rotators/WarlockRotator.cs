using System;
using System.Collections.Generic;
using System.Windows.Forms;
using WoWPal.CombatHandler.Models;

namespace WoWPal.CombatHandler.Rotators
{
    public class WarlockRotator : CombatRotator
    {
        public WarlockRotator(Func<bool> checkSuccessfulCast)
            : base(checkSuccessfulCast)
        {
            SingleTargetSpellRotation = new List<Spell>
            {
                new Spell
                {
                    Name = "UnstableAffliction",
                    Button = Keys.D1,
                    Cooldown = 8,
                },
                new Dot
                {
                    Name = "Agony",
                    Button = Keys.D2,
                    Cooldown = 1,
                    Duration = 18,
                },
                new Dot
                {
                    Name = "Corruption",
                    Button = Keys.D3,
                    Cooldown = 1,
                    Duration = 14,
                },
                new Dot
                {
                    Name = "Corruption",
                    Button = Keys.D4,
                    Cooldown = 1,
                    Duration = 15,
                },
                new Spell
                {
                    Name = "Haunt",
                    Button = Keys.D5,
                    Cooldown = 15,
                },
                new Spell
                {
                    Name = "ShadowBolt",
                    Button = Keys.D6,
                    Cooldown = 1,
                },
            };
        }
    }
}
