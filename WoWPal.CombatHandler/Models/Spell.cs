using System;
using System.Windows.Forms;

namespace WoWPal.CombatHandler.Models
{
    public class Spell
    {
        public string Name { get; set; }
        public int Cooldown { get; set; }
        public Keys Button { get; set; }
        public DateTime CastedAt { get; set; }
    }
}
