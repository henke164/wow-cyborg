using System;
using System.Collections.Generic;
using WoWPal.Models.Abstractions;
using WoWPal.Utilities;

namespace WoWPal.EventDispatchers
{
    public class PlayerTransformChangedDispatcher : AddonBehaviourEventDispatcher
    {
        private Transform _transform = new Transform(0, 0, 0, 0);

        public PlayerTransformChangedDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "PlayerTransformChanged";
        }

        protected override void Update()
        {
            var zoneId = GetZoneId();
            var xPos = GetXPosition();
            var zPos = GetZPosition();
            var rotation = GetRotation();

            var newTransform = new Transform(xPos, 0, zPos, rotation)
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
                GetCharacterAt(1, 6),
                GetCharacterAt(2, 6),
                GetCharacterAt(3, 6),
                GetCharacterAt(4, 6)
            };

            return int.Parse(string.Join("", numbers));
        }

        private float GetXPosition()
        {
            var numbers = new List<string> {
                "0,",
                GetCharacterAt(1, 5),
                GetCharacterAt(2, 5),
                GetCharacterAt(3, 5),
                GetCharacterAt(4, 5)
            };

            return float.Parse(string.Join("", numbers));
        }

        private float GetZPosition()
        {
            var numbers = new List<string> {
                "0,",
                GetCharacterAt(1, 4),
                GetCharacterAt(2, 4),
                GetCharacterAt(3, 4),
                GetCharacterAt(4, 4)
            };

            return float.Parse(string.Join("", numbers));
        }

        private float GetRotation()
        {
            var numbers = new List<string> {
                GetCharacterAt(1, 3),
                GetCharacterAt(2, 3),
                GetCharacterAt(3, 3),
                GetCharacterAt(4, 3)
            };

            var rotation = float.Parse(string.Join("", numbers));
            return rotation / 1000;
        }
    }
}
