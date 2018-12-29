using System;

namespace WoWPal.CombatHandler.Models
{
    public class Spell
    {
        public string Name { get; set; }
        public int Cooldown { get; set; }
        public string Button { get; set; }
        public DateTime CastedAt { get; set; }
    }
}
