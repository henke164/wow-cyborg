using Newtonsoft.Json;
using System;
using WowCyborg.Runners;
using WowCyborg.Utilities;
using WowCyborgAddonUtilities.Models;

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

        public BotTransform GetCurrentTransform()
        {
            var currentTransform = _botRunner.CurrentTransform;
            if (currentTransform == null)
            {
                return null;
            }

            return new BotTransform
            {
                X = currentTransform.Position.X,
                Z = currentTransform.Position.Z,
                R = currentTransform.Rotation,
                ZoneId = currentTransform.ZoneId
            };
        }
    }
}
