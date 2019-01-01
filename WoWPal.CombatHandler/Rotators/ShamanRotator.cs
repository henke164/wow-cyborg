using System;
using System.Collections.Generic;
using System.Windows.Forms;
using WoWPal.CombatHandler.Models;

namespace WoWPal.CombatHandler.Rotators
{
    public class ShamanRotator : CombatRotator
    {
        public ShamanRotator(Func<bool> checkSuccessfulCast)
            : base(checkSuccessfulCast)
        {
            SingleTargetSpellRotation = new List<Spell>
            {
                new Dot
                {
                    Name = "FlameShock",
                    Button = Keys.D1,
                    Cooldown = 6,
                    Duration = 23,
                },
                new Spell
                {
                    Name = "Lightningbolt",
                    Button = Keys.D2,
                    Cooldown = 1,
                }
            };
        }
    }
}
