using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace WowCyborg.Core.Models.Abstractions
{
    public abstract class EventDispatcherBase
    {
        public string EventName { get; set; }

        protected Action<IntPtr> OnGameHandleAdded;

        private bool _isRunning = false;

        private Dictionary<IntPtr, Action<Event>> _onEventTriggeredCallbacks = new Dictionary<IntPtr, Action<Event>>();

        private IList<IntPtr> _hWnds = new List<IntPtr>();

        public void AddGameHandle(IntPtr hWnd, Action<Event> onEventTriggeredCallback)
        {
            _onEventTriggeredCallbacks.Add(hWnd, onEventTriggeredCallback);
            _hWnds.Add(hWnd);

            OnGameHandleAdded?.Invoke(hWnd);
        }

        public void Start()
        {
            Task.Run(() => {
                _isRunning = true;
                while (_isRunning)
                {
                    try
                    {
                        Update();

                        foreach (var hWnd in _hWnds)
                        {
                            GameHandleUpdate(hWnd);
                        }

                        Thread.Sleep(1000 / 30);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("Error in event dispatcher");
                        Console.WriteLine(ex.Message);
                        Console.WriteLine(ex.StackTrace);
                    }
                }
            });
        }
        
        public void Stop()
            => _isRunning = false;

        protected abstract void Update();

        protected abstract void GameHandleUpdate(IntPtr hWnd);

        protected void TriggerEvent(IntPtr hWnd, object eventData)
            => _onEventTriggeredCallbacks[hWnd](new Event {
                Name = EventName,
                Data = eventData
            });
    }
}
