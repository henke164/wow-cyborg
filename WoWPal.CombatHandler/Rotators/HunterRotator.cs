using System;
using System.Collections.Generic;
using System.Windows.Forms;
using WoWPal.CombatHandler.Models;

namespace WoWPal.CombatHandler.Rotators
{
    public class HunterRotator : CombatRotator
    {
        public HunterRotator(Func<bool> checkSuccessfulCast)
            : base(checkSuccessfulCast)
        {
            SingleTargetSpellRotation = new List<Spell>
            {
                new Spell
                {
                    Name = "BeastialWrath",
                    Button = Keys.D5,
                    Cooldown = 95,
                },
                new Spell
                {
                    Name = "BarbedShot",
                    Button = Keys.D2,
                    Cooldown = 5,
                },
                new Spell
                {
                    Name = "KillCommand",
                    Button = Keys.D0,
                    Cooldown = 7,
                },
                new Spell
                {
                    Name = "CobraShot",
                    Button = Keys.D4,
                    Cooldown = 1,
                },
            };
        }
    }
}
