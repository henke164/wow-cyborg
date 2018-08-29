using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;
using Tesseract;
using WoWPal.Events.Abstractions;
using WoWPal.Utilities;

namespace WoWPal.EventDispatchers
{
    public class PlayerTransformChangedDispatcher : EventDispatcherBase
    {
        private Rectangle _inGameAddonLocation = new Rectangle(0, 450, 300, 200);
        private Transform _transform = new Transform(0, 0, 0);

        public PlayerTransformChangedDispatcher(Action<Event> onEvent)
            : base(onEvent)
        {
            EventName = "PlayerTransformChanged";
        }

        protected override void Update()
        {
        }

        public override void ReceiveEvent(Event ev)
        {
            try
            {
                if (ev.Name != "ScreenChanged")
                {
                    return;
                }

                var screenshot = (Bitmap)ev.Data;

                var addonBitmap = screenshot.Clone(_inGameAddonLocation, screenshot.PixelFormat);

                using (var engine = new TesseractEngine(@"tessdata", "eng"))
                {
                    engine.SetVariable("tessedit_char_whitelist", "0123456789.");

                    using (var img = PixConverter.ToPix(addonBitmap))
                    {
                        using (var page = engine.Process(img))
                        {
                            var transformData = page.GetText().Replace('.', ',').Split('\n');
                            var newTransform = new Transform(
                                float.Parse(transformData[0]),
                                float.Parse(transformData[1]),
                                float.Parse(transformData[2]));

                            if (_transform.X != newTransform.X ||
                                _transform.Z != newTransform.Z ||
                                _transform.R != newTransform.R)
                            {
                                _transform = newTransform;
                                TriggerEvent(_transform);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {

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
