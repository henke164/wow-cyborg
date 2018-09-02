using System;

namespace WoWPal.Models
{
    public class CombatSpell
    {
        public string ActionbarName { get; set; }
        public int CooldownInSeconds { get; set; }
        public DateTime LastUsed { get; set; }
    }
}
