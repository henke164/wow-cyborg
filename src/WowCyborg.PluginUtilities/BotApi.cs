using System;
using WowCyborg.Core;
using WowCyborg.Core.Utilities;
using WowCyborg.PluginUtilities.Models;

namespace WowCyborg.PluginUtilities
{
    public class BotApi
    {
        private Bot _botRunner;

        public BotApi(Bot botRunner)
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
