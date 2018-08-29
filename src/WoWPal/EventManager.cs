using System;
using System.Collections.Generic;
using WoWPal.EventDispatchers.Abstractions;

namespace WoWPal
{
    public class EventManager
    {
        public IDictionary<string, IList<Action<Event>>> EventSubscribers { get; set; }

        public EventManager()
        {
            EventSubscribers = new Dictionary<string, IList<Action<Event>>>();
        }

        public void StartEventDispatcher(Type dispatcherType)
        {
            if (dispatcherType.BaseType != typeof(EventDispatcherBase))
            {
                throw new InvalidOperationException("Tried to start an invalid dispatcher");
            }

            var dispatcher = (EventDispatcherBase)Activator.CreateInstance(dispatcherType, 
                new Action<Event>((Event ev) => { BroadcastEvent(ev); }));

            dispatcher.Start();
        }

        public void On(string eventName, Action<Event> onEvent)
        {
            if (!EventSubscribers.ContainsKey(eventName))
            {
                EventSubscribers.Add(eventName, new List<Action<Event>>());
            }

            EventSubscribers[eventName].Add(onEvent);
        }

        private void BroadcastEvent(Event ev)
        {
            if (!EventSubscribers.ContainsKey(ev.Name))
            {
                return;
            }

            foreach (var subscriber in EventSubscribers[ev.Name])
            {
                subscriber(ev);
            }
        }
    }
}
