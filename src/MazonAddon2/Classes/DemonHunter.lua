if UnitClassBase("player") ~= "DEMONHUNTER" then
  return
end

WowCyborg_MeleeDetectionSpell = "Disrupt"
WowCyborg_NearbyEnemyDetectionSpell = "Throw Glaive"
WowCyborg_PAUSE_KEYS = {
  "NUMPAD1",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "X",
  "F",
  "R",
  "§",
}

WowCyborg_ClassRotation = function()
  if WowCyborg_INCOMBAT == false then
    return false;
  end

  local channel = UnitChannelInfo("player");
  if channel == "Void Ray" then
    WowCyborg_CURRENTATTACK = "Channeling";
    Pause(0.25);
  end

  return false;
end
