using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WoWPal.CombatHandler.Models;

namespace WoWPal.CombatHandler.Rotators
{
    public abstract class CombatRotator
    {
        protected IList<Spell> SingleTargetSpellRotation { get; set; }
        protected IList<Spell> AOESpellRotation { get; set; }
        private IList<Spell> _currentRotation;
        private int _failedCastAttempts = 0;

        public CombatRotator(Func<bool> checkSuccessfulCast)
        {
            Task.Run(() =>
            {
                while (true)
                {
                    if (_currentRotation != null)
                    {
                        Update();
                        Thread.Sleep(200);

                        var isCasting = checkSuccessfulCast();
                        if (!isCasting)
                        {
                            _failedCastAttempts++;

                            if (_failedCastAttempts > 10)
                            {
                                KeyHandler.PressKey(Keys.D, 600);
                                _failedCastAttempts = 0;
                            }
                        }
                        else
                        {
                            _failedCastAttempts = 0;
                        }
                    }
                    else
                    {
                        _failedCastAttempts = 0;
                        Thread.Sleep(200);
                    }
                }
            });
        }

        public void RunRotation(RotationType type)
        {
            return;
            switch (type)
            {
                case RotationType.SingleTarget:
                    _currentRotation = SingleTargetSpellRotation;
                    break;
                case RotationType.AOE:
                    _currentRotation = AOESpellRotation;
                    break;
                default:
                    ResetDotTimers();
                    _currentRotation = null;
                    break;
            }
        }

        private void ResetDotTimers()
        {
            foreach (var dot in SingleTargetSpellRotation.Where(s => IsDot(s)))
            {
                ((Dot)dot).CastedAt = DateTime.MinValue;
            }
        }

        private bool IsDot(Spell s)
            => s is Dot;

        private bool DurationExceeded(Dot dot, DateTime now)
            => dot.CastedAt.AddSeconds(dot.Duration) < now;

        private bool CooldownExceeded(Spell spell, DateTime now)
            => spell.CastedAt.AddSeconds(spell.Cooldown) < now;

        private bool HasGlobalCooldown(int globalCooldownMS, DateTime now)
            => _currentRotation.OrderByDescending(s => s.CastedAt)
            .FirstOrDefault()
            .CastedAt
            .AddMilliseconds(globalCooldownMS) > now;

        public void Update()
        {
            var now = DateTime.Now;

            if (HasGlobalCooldown(1500, now))
            {
                return;
            }

            var dot = _currentRotation.FirstOrDefault(s => IsDot(s) &&
                DurationExceeded((Dot)s, now));

            if (dot != null)
            {
                Console.WriteLine("DOT");
                KeyHandler.PressKey(dot.Button);
                dot.CastedAt = now;
            }
            else
            {
                var spell = _currentRotation.FirstOrDefault(s => !IsDot(s) &&
                    CooldownExceeded(s, now));

                if (spell != null)
                {
                    Console.WriteLine("Attack");
                    KeyHandler.PressKey(spell.Button);
                    spell.CastedAt = now;
                }
            }
        }
    }
}
