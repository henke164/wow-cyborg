using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using WoWPal.Models;
using WoWPal.Utilities;

namespace WoWPal.Commanders
{
    public class CombatCommander
    {
        private bool _inCombat;

        private IList<CombatSpell> _combatSpells;

        private ActionbarCommander _actionbarCommander;
        
        private Task _combatTask;

        public CombatCommander()
        {
            _actionbarCommander = ActionbarCommander.FromSettingFile("actionbarsettings.json");

            var settings = SettingsLoader.LoadSettings<CombatSettings>("combatsettings.json");

            _combatSpells = settings.CombatSpells;
        }

        public void StartOrContinueCombatTask()
        {
            if (_inCombat)
            {
                return;
            }

            RunCombatTask();
        }

        public void StopCombat()
        {
            _inCombat = false;
        }

        private void RunCombatTask()
        {
            _inCombat = true;
            _combatTask = Task.Run(() => {
                while (_inCombat)
                {
                    var now = DateTime.Now;
                    var spell = _combatSpells.FirstOrDefault(c => (now - c.LastUsed).Seconds > c.CooldownInSeconds);

                    if (spell == null)
                    {
                        Thread.Sleep(500);
                        continue;
                    }

                    Thread.Sleep(200);

                    _actionbarCommander.ClickOnActionBar(spell.ActionbarName);

                    spell.LastUsed = now;
                    Thread.Sleep(100);
                }
            });
        }
    }
}
