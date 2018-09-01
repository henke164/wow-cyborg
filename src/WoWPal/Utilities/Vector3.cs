using System;

namespace WoWPal.Utilities
{
    public class Vector3
    {
        public float X { get; set; }
        public float Y { get; set; }
        public float Z { get; set; }

        public Vector3(float x, float y, float z)
        {
            X = x;
            Y = y;
            Z = z;
        }

        public static float Distance(Vector3 v1, Vector3 v2)
        {
            var deltaX = v2.X - v1.X;
            var deltaY = v2.Y - v1.Y;
            var deltaZ = v2.Z - v1.Z;
            return (float)Math.Sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);
        }
    }
}
