using System.Collections.Generic;
using WoWPal.CombatHandler.Models;

namespace WoWPal.CombatHandler.Rotators
{
    public class ShamanRotator : CombatRotator
    {
        public ShamanRotator()
        {
            SingleTargetSpellRotation = new List<Spell>
            {
                new Dot
                {
                    Name = "FlameShock",
                    Button = "1",
                    Cooldown = 6,
                    Duration = 23,
                },
                new Spell
                {
                    Name = "Lightningbolt",
                    Button = "2",
                    Cooldown = 1,
                }
            };
        }
    }
}
