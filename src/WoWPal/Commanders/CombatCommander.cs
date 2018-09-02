using System;
using System.Collections.Generic;
using System.Linq;
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
            => _inCombat = false;
        
        private void RunCombatTask()
        {
            _inCombat = true;
            _combatTask = Task.Run(async () => {
                while (_inCombat)
                {
                    var now = DateTime.Now;
                    var spell = _combatSpells.FirstOrDefault(c => (now - c.LastUsed).Seconds > c.CooldownInSeconds);

                    if (spell == null)
                    {
                        await Task.Delay(500);
                        continue;
                    }

                    await Task.Delay(200);

                    await _actionbarCommander.ClickOnActionBarAsync(spell.ActionbarName);

                    spell.LastUsed = now;

                    await Task.Delay(100);
                }
            });
        }
    }
}
