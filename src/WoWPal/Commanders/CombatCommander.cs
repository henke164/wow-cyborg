using System;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WoWPal.Events;
using WoWPal.Events.Abstractions;
using WoWPal.Handlers;
using WoWPal.Utilities;

namespace WoWPal.Commanders
{
    public class CombatCommander
    {
        private bool _inCombat = false;

        public CombatCommander()
        {
            EventManager.On("CombatChanged", (Event ev) =>
            {
                var data = (bool)ev.Data;
                _inCombat = data;
            });
        }
    }
}
