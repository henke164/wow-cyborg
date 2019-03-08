using Newtonsoft.Json;
using System;
using WowCyborg.Runners;
using WowCyborg.Utilities;

namespace WowCyborgAddonUtilities
{
    public class BotApi
    {
        private BotRunnerBase _botRunner;

        public BotApi(BotRunnerBase botRunner)
        {
            _botRunner = botRunner;
        }

        public void MoveTo(float x, float z, Action onDestinationReached = null)
        {
            _botRunner.MoveTo(new Vector3(x, 0, z), onDestinationReached);
        }

        public void FaceTowards(float x, float z, Action onDestinationReached = null)
        {
            _botRunner.FaceTowards(new Vector3(x, 0, z), onDestinationReached);
        }

        public string GetCurrentTransform()
        {
            if (_botRunner.CurrentTransform == null)
            {
                return JsonConvert.SerializeObject(new
                {
                    error = "Location not found"
                });
            }

            return JsonConvert.SerializeObject(new
            {
                x = _botRunner.CurrentTransform.Position.X,
                z = _botRunner.CurrentTransform.Position.Z,
                r = _botRunner.CurrentTransform.Rotation,
                zone = _botRunner.CurrentTransform.ZoneId
            });
        }
    }
}
