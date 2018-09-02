using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;
using Tesseract;
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
            using (var engine = new TesseractEngine(@"tessdata", "eng"))
            {
                engine.SetVariable("tessedit_char_whitelist", "0123456789.");

                using (var img = PixConverter.ToPix(AddonScreenshot))
                {
                    using (var page = engine.Process(img))
                    {
                        try
                        {
                            var transformData = page.GetText().Replace('.', ',').Split('\n');
                            var newTransform = new Transform(
                                float.Parse(transformData[0]),
                                0,
                                float.Parse(transformData[1]),
                                float.Parse(transformData[2]));

                            if (_transform.Position.X != newTransform.Position.X ||
                                _transform.Position.Z != newTransform.Position.Z ||
                                _transform.Rotation != newTransform.Rotation)
                            {
                                _transform = newTransform;
                                TriggerEvent(_transform);
                            }
                        }
                        catch
                        {

                        }
                    }
                }
            }
        }

        private Bitmap CaptureScreenShot()
        {
            var bounds = Screen.GetBounds(Point.Empty);

            using (var bitmap = new Bitmap(bounds.Width, bounds.Height))
            {
                using (var g = Graphics.FromImage(bitmap))
                {
                    g.CopyFromScreen(Point.Empty, Point.Empty, bounds.Size);
                }

                return bitmap.Clone(bounds, PixelFormat.Format24bppRgb);
            }
        }
    }
}
