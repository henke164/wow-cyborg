using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using WoWPal.Commanders;
using WoWPal.Handlers;
using WoWPal.Models.Abstractions;
using WoWPal.Utilities;

namespace WoWPal.Runners
{
    public class PartyRunner : BotRunnerBase
    {
        private LootingCommander _lootingCommander = new LootingCommander();
        private IList<Transform> _leaderTransformHistory = new List<Transform>();
        
        protected override void SetupBehaviour()
        {
            EventManager.On("CastRequested", (Event ev) =>
            {
                var button = (Keys)ev.Data;
                //KeyHandler.PressKey(button);
            });

            EventManager.On("WrongFacing", (Event ev) =>
            {
                KeyHandler.PressKey(Keys.D, 500);
            });

            EventManager.On("LeaderTransformChanged", (Event ev) => 
            {
                var transform = (Transform)ev.Data;
                HandleNewLeaderTransform(transform);
                HandleFollowing();
            });
        }

        private void HandleNewLeaderTransform(Transform transform)
        {
            if (_leaderTransformHistory.Count == 0)
            {
                _leaderTransformHistory.Add(transform);
            }

            var distanceSinceLastWaypoint = Vector3.Distance(_leaderTransformHistory.Last().Position, transform.Position);
            if (distanceSinceLastWaypoint > 0.001)
            {
                _leaderTransformHistory.Add(transform);
            }
        }

        private void HandleFollowing()
        {
            if (TargetLocation == null && CurrentLocation != null && _leaderTransformHistory.Count > 0)
            {
                try
                {
                    var distanceToLeader = Vector3.Distance(_leaderTransformHistory.Last().Position, CurrentLocation);
                    if (distanceToLeader > 0.005)
                    {
                        MoveTo(_leaderTransformHistory.First().Position, () =>
                        {
                            try
                            {
                                _leaderTransformHistory.RemoveAt(0);
                            }
                            catch
                            {

                            }
                        });
                    }
                }
                catch(Exception ex)
                {

                }
            }
        }
    }
}
