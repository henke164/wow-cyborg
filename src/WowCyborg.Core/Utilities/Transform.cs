namespace WowCyborg.Core.Utilities
{
    public class Transform
    {
        public int ZoneId { get; set; }
        public Vector3 Position { get; set; }
        public float Rotation { get; set; }

        public Transform(float x, float y, float z, float rotation)
        {
            Position = new Vector3(x, y, z);
            Rotation = rotation;
        }
    }
}
