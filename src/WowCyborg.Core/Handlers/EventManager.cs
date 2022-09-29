using System;
using System.Collections.Generic;
using System.Linq;
using WowCyborg.Core.EventDispatchers;
using WowCyborg.Core.Models.Abstractions;

namespace WowCyborg.Core.Handlers
{
    public static class EventManager
    {
        private static Dictionary<IntPtr, Dictionary<string, List<Action<Event>>>> EventSubscribers = new Dictionary<IntPtr, Dictionary<string, List<Action<Event>>>>();

        private static List<EventDispatcherBase> Dispatchers = new List<EventDispatcherBase>();
        
        public static EventDispatcherBase StartEventDispatcher<T>(IntPtr hWnd)
        {
            var dispatcher = Dispatchers.FirstOrDefault(d => typeof(T) == d.GetType());

            if (dispatcher == null)
            {
                dispatcher = (EventDispatcherBase)Activator.CreateInstance(typeof(T));
                dispatcher.Start();
                Dispatchers.Add(dispatcher);
            }

            dispatcher.AddGameHandle(hWnd, new Action<IntPtr, Event>((IntPtr h, Event ev) => { BroadcastEvent(h, ev); }));

            return dispatcher;
        }

        public static void On(IntPtr hWnd, string eventName, Action<Event> onEvent)
        {
            if (!EventSubscribers.ContainsKey(hWnd))
            {
                EventSubscribers.Add(hWnd, new Dictionary<string, List<Action<Event>>>());
            }

            if (!EventSubscribers[hWnd].ContainsKey(eventName))
            {
                EventSubscribers[hWnd].Add(eventName, new List<Action<Event>>());
            }

            if (!EventSubscribers[hWnd][eventName].Contains(onEvent))
            {
                EventSubscribers[hWnd][eventName].Add(onEvent);
            }
        }

        private static void BroadcastEvent(IntPtr hWnd, Event ev)
        {
            if (!EventSubscribers.ContainsKey(hWnd))
            {
                return;
            }

            if (!EventSubscribers[hWnd].ContainsKey(ev.Name))
            {
                return;
            }

            var subscriberCount = EventSubscribers[hWnd][ev.Name].Count;
            ev.HWnd = hWnd;

            for (var x = 0; x < subscriberCount; x++)
            {
                EventSubscribers[hWnd][ev.Name][x](ev);
            }
        }
    }
}
