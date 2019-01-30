using System;
using System.Collections.Generic;
using WoWPal.Models.Abstractions;
using WoWPal.Utilities;

namespace WoWPal.EventDispatchers
{
    public class LeaderTransformChangedDispatcher : AddonBehaviourEventDispatcher
    {
        private Transform _transform = new Transform(0, 0, 0, 0);

        public LeaderTransformChangedDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "LeaderTransformChanged";
        }

        protected override void Update()
        {
            var zoneId = GetZoneId();
            var xPos = GetXPosition();
            var zPos = GetZPosition();

            var newTransform = new Transform(xPos, 0, zPos, 0)
            {
                ZoneId = zoneId
            };

            if (_transform.Position.X != newTransform.Position.X ||
                _transform.Position.Z != newTransform.Position.Z ||
                _transform.Rotation != newTransform.Rotation)
            {
                _transform = newTransform;
                TriggerEvent(_transform);
            }
        }

        private int GetZoneId()
        {
            var numbers = new List<string> {
                GetCharacterAt(0, 6),
                GetCharacterAt(1, 6),
                GetCharacterAt(2, 6),
                GetCharacterAt(3, 6)
            };

            return int.Parse(string.Join("", numbers));
        }

        private float GetXPosition()
        {
            var numbers = new List<string> {
                "0,",
                GetCharacterAt(0, 7),
                GetCharacterAt(1, 7),
                GetCharacterAt(2, 7),
                GetCharacterAt(3, 7)
            };

            return float.Parse(string.Join("", numbers));
        }

        private float GetZPosition()
        {
            var numbers = new List<string> {
                "0,",
                GetCharacterAt(0, 8),
                GetCharacterAt(1, 8),
                GetCharacterAt(2, 8),
                GetCharacterAt(3, 8)
            };

            return float.Parse(string.Join("", numbers));
        }
    }
}
