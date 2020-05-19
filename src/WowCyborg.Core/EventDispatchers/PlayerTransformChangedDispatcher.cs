using System;
using System.Collections.Generic;
using WowCyborg.Core.Models.Abstractions;
using WowCyborg.Core.Utilities;

namespace WowCyborg.Core.EventDispatchers
{
    public class PlayerTransformChangedDispatcher : AddonBehaviourEventDispatcher
    {
        private Transform _transform = new Transform(0, 0, 0, 0);

        public PlayerTransformChangedDispatcher()
        {
            EventName = "PlayerTransformChanged";
        }


        protected override void GameHandleUpdate(IntPtr hWnd)
        {
            var zoneId = GetZoneId(hWnd);
            var xPos = GetXPosition(hWnd);
            var zPos = GetZPosition(hWnd);
            var rotation = GetRotation(hWnd);

            var newTransform = new Transform(xPos, 0, zPos, rotation)
            {
                ZoneId = zoneId
            };

            if (_transform.Position.X != newTransform.Position.X ||
                _transform.Position.Z != newTransform.Position.Z ||
                _transform.Rotation != newTransform.Rotation)
            {
                _transform = newTransform;
                TriggerEvent(hWnd, _transform);
            }
        }

        protected override void Update()
        {
        }

        private int GetZoneId(IntPtr hWnd)
        {
            var numbers = new List<string> {
                GetCharacterAt(hWnd, 1, 6),
                GetCharacterAt(hWnd, 2, 6),
                GetCharacterAt(hWnd, 3, 6),
                GetCharacterAt(hWnd, 4, 6)
            };

            if (int.TryParse(string.Join("", numbers), out int zoneId))
            {
                return zoneId;
            }

            return 0;
        }

        private float GetXPosition(IntPtr hWnd)
        {
            var numbers = new List<string> {
                "0,",
                GetCharacterAt(hWnd, 1, 5),
                GetCharacterAt(hWnd, 2, 5),
                GetCharacterAt(hWnd, 3, 5),
                GetCharacterAt(hWnd, 4, 5)
            };

            if (float.TryParse(string.Join("", numbers), out float xPosition))
            {
                return xPosition;
            }

            return 0;
        }

        private float GetZPosition(IntPtr hWnd)
        {
            var numbers = new List<string> {
                "0,",
                GetCharacterAt(hWnd, 1, 4),
                GetCharacterAt(hWnd, 2, 4),
                GetCharacterAt(hWnd, 3, 4),
                GetCharacterAt(hWnd, 4, 4)
            };

            if (float.TryParse(string.Join("", numbers), out float yPosition))
            {
                return yPosition;
            }

            return 0;
        }

        private float GetRotation(IntPtr hWnd)
        {
            var numbers = new List<string> {
                GetCharacterAt(hWnd, 1, 3),
                GetCharacterAt(hWnd, 2, 3),
                GetCharacterAt(hWnd, 3, 3),
                GetCharacterAt(hWnd, 4, 3)
            };

            if (float.TryParse(string.Join("", numbers), out float rotation))
            {
                return rotation / 1000;
            }

            return 0;
        }
    }
}
