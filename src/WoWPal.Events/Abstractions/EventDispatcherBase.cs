using System;
using System.Threading;
using System.Threading.Tasks;

namespace WoWPal.Events.Abstractions
{
    public abstract class EventDispatcherBase
    {
        public string EventName { get; set; }

        private bool _isRunning = false;
        private Action<Event> _onEventTriggered;

        public EventDispatcherBase(Action<Event> onEventTriggered)
            => _onEventTriggered = onEventTriggered;
        
        public void Start()
        {
            Task.Run(() => {
                _isRunning = true;
                while (_isRunning)
                {
                    try
                    {
                        Update();
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

        protected void TriggerEvent(object eventData)
            => _onEventTriggered(new Event {
                Name = EventName,
                Data = eventData
            });
    }
}
