namespace WoWPal.Utilities
{
    public class Transform
    {
        public float X { get; set; }
        public float Z { get; set; }
        public float R { get; set; }

        public Transform(float x, float z, float r)
        {
            X = x;
            Z = z;
            R = r;
        }
    }
}
