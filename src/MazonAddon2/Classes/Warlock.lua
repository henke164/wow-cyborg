if UnitClassBase("player") ~= "WARLOCK" then
  return
end

WowCyborg_MeleeDetectionSpell = ""
WowCyborg_NearbyEnemyDetectionSpell = "Drain Soul"
WowCyborg_PAUSE_KEYS = {
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "X",
  "F",
  "F2",
  "R",
  "F1",
}
local implosionId = "Implosion";
local implosionSpellId = 196277;
local handOfGuldanId = "Hand of Gul'dan";
local seedofCorruptionId = "Seed of Corruption";
TrackSpell(implosionSpellId, 15)

WowCyborg_ClassRotation = function(highlightedSlot)
  if WowCyborg_INCOMBAT == false then
    return false;
  end

  local canCastGuldan = IsSpellUsable(handOfGuldanId);
  local casting = UnitCastingInfo("player");
  if casting == "Shadow Bolt" or casting == "Infernal Bolt" then
    if canCastGuldan then
      return SetSpellRequest("7");
    end
    return SetSpellRequest("4");
  end

  if IsSpellUsable(handOfGuldanId) then
    local inRange = IsSpellInRange(handOfGuldanId, "target")
    if inRange then
      return SetSpellRequest("4");
    end
  end

  if WowCyborg_AOE_Rotation == true then
    if not HasActiveBuff(implosionSpellId) and IsSpellUsable(implosionId) then
      local inRange = IsSpellInRange(implosionId, "target")
      if inRange then
        return SetSpellRequest("8");
      end
    end

    local channel = UnitChannelInfo("player");
    if channel == nil or channel == "Drain Soul" then
      if IsSpellUsable(seedofCorruptionId) then
        if highlightedSlot == 1 then
          local inRange = IsSpellInRange(seedofCorruptionId, "target")
          if inRange then
            return SetSpellRequest("8");
          end
        end
      end
    end
  end

  return false;
end
