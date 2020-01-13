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

        public bool IsRunning()
            => !_botRunner.DestinationReached;

        public bool IsAlive()
            => _botRunner.CorpseTransform == null;

        public BotTransform GetCorpseTransform()
        {
            var corpseTransform = _botRunner.CorpseTransform;
            if (corpseTransform == null)
            {
                return null;
            }

            return new BotTransform
            {
                X = corpseTransform.Position.X,
                Z = corpseTransform.Position.Z,
                R = corpseTransform.Rotation,
                ZoneId = corpseTransform.ZoneId
            };
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
