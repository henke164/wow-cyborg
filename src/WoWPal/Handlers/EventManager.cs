using System;
using System.Collections.Generic;
using WoWPal.Models.Abstractions;

namespace WoWPal.Handlers
{
    public static class EventManager
    {
        private static IDictionary<string, IList<Action<Event>>> EventSubscribers = new Dictionary<string, IList<Action<Event>>>();

        private static IList<EventDispatcherBase> Dispatchers = new List<EventDispatcherBase>();
        
        public static EventDispatcherBase StartEventDispatcher(Type dispatcherType)
        {
            var dispatcher = (EventDispatcherBase)Activator.CreateInstance(dispatcherType, 
                new Action<Event>((Event ev) => { BroadcastEvent(ev); }));

            dispatcher.Start();

            Dispatchers.Add(dispatcher);

            return dispatcher;
        }
        
        public static void On(string eventName, Action<Event> onEvent)
        {
            if (!EventSubscribers.ContainsKey(eventName))
            {
                EventSubscribers.Add(eventName, new List<Action<Event>>());
            }

            EventSubscribers[eventName].Add(onEvent);
        }

        private static void BroadcastEvent(Event ev)
        {
            if (!EventSubscribers.ContainsKey(ev.Name))
            {
                return;
            }

            foreach(var subscriber in EventSubscribers[ev.Name])
            {
                subscriber(ev);
            };
        }
    }
}
