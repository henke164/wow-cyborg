using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WowCyborg.Core;
using WowCyborg.Core.Handlers;
using WowCyborg.Core.Models;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.BotProfiles
{
    public class PVP : Bot
    {
        private DateTime _queuedAt = DateTime.MinValue;
        private DateTime _joinedAt = DateTime.MinValue;
        private DateTime _bgLogicStartedAt = DateTime.MinValue;
        private BattlegroundRunner _runner = new BattlegroundRunner();
        private bool _bgLogicStarted = false;

        public PVP(IntPtr hWnd)
            : base (hWnd)
        {
            Task.Run(() => {
                while (true)
                {
                    KeyHandler.PressKey(Keys.Space);
                    Thread.Sleep(60000 * 15);
                }
            });
        }

        protected override void SetupBehaviour()
        {
            EventManager.On("KeyPressRequested", (Event ev) =>
            {
                var keyRequest = (KeyPressRequest)ev.Data;
                if (keyRequest.Key == Keys.D3 && keyRequest.ModifierKey == Keys.LShiftKey)
                {
                    _bgLogicStarted = false;
                    _runner.Stop();
                    return;
                }

                if (keyRequest.Key == Keys.D0 && keyRequest.ModifierKey == Keys.LShiftKey)
                {
                    if ((DateTime.Now - _queuedAt).Seconds < 10)
                    {
                        return;
                    }
                    _queuedAt = DateTime.Now;
                    Task.Run(() => { Queue(); });
                }
                else if (keyRequest.Key == Keys.D9 && keyRequest.ModifierKey == Keys.LShiftKey)
                {
                    if ((DateTime.Now - _joinedAt).Seconds < 10)
                    {
                        return;
                    }
                    _joinedAt = DateTime.Now;
                    Task.Run(() => { Join(); });
                }
                else if (keyRequest.Key == Keys.D1 && keyRequest.ModifierKey == Keys.LShiftKey)
                {
                    if ((DateTime.Now - _joinedAt).Seconds < 10)
                    {
                        return;
                    }
                    _joinedAt = DateTime.Now;
                    Task.Run(() => { Leave(); });
                }

                if (keyRequest.Key == Keys.D9 && keyRequest.ModifierKey == Keys.None)
                {
                    if ((DateTime.Now - _bgLogicStartedAt).Seconds < 10)
                    {
                        return;
                    }

                    if (_bgLogicStarted)
                    {
                        return;
                    }
                    _bgLogicStartedAt = DateTime.Now;
                    _bgLogicStarted = true;
                    Task.Run(() => DoBgLogic());
                }

                if (keyRequest.ModifierKey != Keys.None)
                {
                    KeyHandler.ModifiedKeypress(keyRequest.ModifierKey, keyRequest.Key);
                }
                else
                {
                    KeyHandler.PressKey(keyRequest.Key);
                }
            });
        }

        private void Queue()
        {
            _runner.Stop();
            _bgLogicStarted = false;
            Thread.Sleep(3000);
            _bgLogicStarted = false;
            MouseHandler.LeftClick(235, 235);
            Thread.Sleep(2000);
            MouseHandler.LeftClick(200, 480);
        }

        private void Join()
        {
            _runner.Stop();
            _bgLogicStarted = false;
            Thread.Sleep(3000);
            if (_bgLogicStarted)
            {
                return;
            }
            _bgLogicStarted = true;
            MouseHandler.LeftClick(895, 175);
            Thread.Sleep(2000);
        }

        private void Leave()
        {
            _runner.Stop();
            Console.WriteLine("Leave....");
            Thread.Sleep(3000);
            MouseHandler.LeftClick(980, 700);
            _bgLogicStarted = false;
            Thread.Sleep(5000);
            _bgLogicStartedAt = DateTime.Now;
            _joinedAt = DateTime.Now;
        }

        private void DoBgLogic()
        {/*
            Thread.Sleep(12000);
            _runner.Play(KeyHandler);
            */
            Console.WriteLine("Bg logic....");
            Thread.Sleep(new Random().Next(29000, 33000));
            KeyHandler.PressKey(Keys.A, new Random().Next(390, 420));
            KeyHandler.PressKey(Keys.W, 2500);
            KeyHandler.PressKey(Keys.D, 400);
            KeyHandler.HoldKey(Keys.W);
            Thread.Sleep(5000);
            KeyHandler.PressKey(Keys.A, 100);
            Thread.Sleep(5000);
            KeyHandler.ReleaseKey(Keys.W);
            KeyHandler.PressKey(Keys.D, 100);
            Thread.Sleep(80000);
            KeyHandler.HoldKey(Keys.W);
            Thread.Sleep(5000);
            KeyHandler.ReleaseKey(Keys.W);
            Thread.Sleep(1000);
            KeyHandler.PressKey(Keys.F, 100);
            Thread.Sleep(5000);
            KeyHandler.PressKey(Keys.D, 500);
            Thread.Sleep(5000);
            KeyHandler.PressKey(Keys.W, 2000);
            KeyHandler.PressKey(Keys.A, 400);
            Thread.Sleep(400);
            KeyHandler.PressKey(Keys.W, 4000);
            Thread.Sleep(4000);
            KeyHandler.PressKey(Keys.E, 500);
            KeyHandler.PressKey(Keys.W, 8000);
            Thread.Sleep(8000);
            KeyHandler.PressKey(Keys.D, 50);
            KeyHandler.PressKey(Keys.W, 5000);
            Thread.Sleep(5000);
            KeyHandler.PressKey(Keys.D, 50);
            KeyHandler.PressKey(Keys.W, 5000);
            Thread.Sleep(5000);
            KeyHandler.PressKey(Keys.D, 500);
            Thread.Sleep(1000);
            KeyHandler.PressKey(Keys.W, new Random().Next(29000, 33000));
            while (_bgLogicStarted)
            {
                KeyHandler.PressKey(Keys.Space, 200);
                Thread.Sleep(new Random().Next(30000, 120000));
            }
        }

        internal class BattlegroundRunner
        {
            private IList<InputEvent> _inputEvents;
            private bool _running = false;

            public void Stop()
            {
                _running = false;
            }

            public void Play(KeyHandler keyhandler)
            {
                LoadEvents();
                var sw = new Stopwatch();
                sw.Start();
                var previousMs = 0d;
                var currentIndex = 0;
                _running = true;
                while (_running)
                {
                    if (previousMs != sw.ElapsedMilliseconds)
                    {
                        if (_inputEvents.Count <= currentIndex)
                        {
                            Console.WriteLine("Done");
                            break;
                        }

                        var currentEvent = _inputEvents[currentIndex];
                        if (sw.ElapsedMilliseconds >= currentEvent.Time)
                        {
                            Console.WriteLine(currentEvent.Time + " " + currentEvent.Key + " " + currentEvent.Down);
                            if (currentEvent.Down)
                            {
                                keyhandler.HoldKey(currentEvent.Key);
                            }
                            else
                            {
                                keyhandler.ReleaseKey(currentEvent.Key);
                            }
                            currentIndex++;
                        }
                    }
                    previousMs = sw.ElapsedMilliseconds;
                }
            }

            private void LoadEvents()
            {
                Console.WriteLine("Loading");
                try
                {
                    using (var sw = new StreamReader("recording.json"))
                    {
                        _inputEvents = JsonConvert.DeserializeObject<List<InputEvent>>(sw.ReadToEnd());
                    }
                }
                catch
                {
                    _inputEvents = new List<InputEvent>();
                }

                Console.WriteLine("Loaded: " + _inputEvents.Count + " events");
            }

            internal class InputEvent
            {
                public Keys Key { get; set; }
                public bool Down { get; set; }
                public int Time { get; set; }
            }
        }
    }

}
