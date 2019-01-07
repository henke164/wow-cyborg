using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using WoWPal.Events.Abstractions;
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
                GetCharacterAt(0, 1),
                GetCharacterAt(1, 1),
                GetCharacterAt(2, 1),
                GetCharacterAt(3, 1)
            };

            return int.Parse(string.Join("", numbers));
        }

        private float GetXPosition()
        {
            var numbers = new List<string> {
                "0,",
                GetCharacterAt(0, 2),
                GetCharacterAt(1, 2),
                GetCharacterAt(2, 2),
                GetCharacterAt(3, 2)
            };

            return float.Parse(string.Join("", numbers));
        }

        private float GetZPosition()
        {
            var numbers = new List<string> {
                "0,",
                GetCharacterAt(0, 3),
                GetCharacterAt(1, 3),
                GetCharacterAt(2, 3),
                GetCharacterAt(3, 3)
            };

            return float.Parse(string.Join("", numbers));
        }

        private float GetRotation()
        {
            var numbers = new List<string> {
                GetCharacterAt(0, 4),
                GetCharacterAt(1, 4),
                GetCharacterAt(2, 4),
                GetCharacterAt(3, 4)
            };

            var rotation = float.Parse(string.Join("", numbers));
            return rotation / 1000;
        }

        private string GetCharacterAt(int x, int y)
        {
            var frameWidth = AddonScreenshot.Width / 4;
            var frameHeight = AddonScreenshot.Height / 4;
            var color = AddonScreenshot.GetPixel(frameWidth * x, frameHeight * y);
            return GetCharacterFromColor(color);
        }

        private string GetCharacterFromColor(Color c)
        {
            if (c.R == 0 && c.G == 0 && c.B == 0)
            {
                return "0";
            }

            if (c.R == 0 && c.G == 0 && c.B > 100 && c.B < 200)
            {
                return "1";
            }

            if (c.R == 0 && c.G == 0 && c.B > 200)
            {
                return "2";
            }

            if (c.R == 0 && c.G > 100 && c.G < 200 && c.B == 0)
            {
                return "3";
            }

            if (c.R == 0 && c.G > 200 && c.B == 0)
            {
                return "4";
            }

            if (c.R > 100 && c.R < 200 && c.G == 0 && c.B == 0)
            {
                return "5";
            }

            if (c.R > 200 && c.G == 0 && c.B == 0)
            {
                return "6";
            }

            if (c.R == 0 && c.G > 100 && c.G < 200 && c.B > 200)
            {
                return "7";
            }

            if (c.R == 0 && c.G > 200 && c.B > 200)
            {
                return "8";
            }

            if (c.R > 100 && c.R < 200 && c.G == 0 && c.B > 200)
            {
                return "9";
            }

            return "";
        }
    }
}
