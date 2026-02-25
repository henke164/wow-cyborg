WowCyborg_AOE_Rotation = false;
WowCyborg_CLASSIC = true;
WowCyborg_CURRENTATTACK = "-";
WowCyborg_DISABLED = false;
WowCyborg_PAUSE = false;
WowCyborg_PAUSE_UNTIL = 0;
WowCyborg_INCOMBAT = false;

if WowCyborg_PAUSE_KEYS == nil then
  WowCyborg_PAUSE_KEYS = {
    "NUMPAD1",
    "NUMPAD5",
    "NUMPAD7",
    "NUMPAD8",
    "NUMPAD9",
    "X",
  }
end

function IsActionSlotAssistedHighlighted(slot)
  local button = _G["ActionButton" .. slot]
  if not button then return false end

  if button.AssistedCombatHighlightFrame and button.AssistedCombatHighlightFrame:IsShown() then
    return true
  end

  return false
end

function UpdateMazonRotation()
  if WowCyborg_DISABLED == true then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if WowCyborg_PAUSE_UNTIL > GetTime() then
    WowCyborg_CURRENTATTACK = "Paused";
    return SetSpellRequest(nil);
  end

  local slot = GetHighlightedActionSlot();
  if slot ~= nil then
    local actionType, id = GetActionInfo(slot)
    if (id ~= nil and actionType == "spell") then
      local inRange = IsSpellInRange(id, "target")
      local nearbyEnemies = GetNearbyEnemyCount("Hammer of Justice");

      if inRange or nearbyEnemies > 0 then
        SetSpellRequest(slot);
        WowCyborg_CURRENTATTACK = slot;
      else
        WowCyborg_CURRENTATTACK = "Out of range";
        SetSpellRequest(nil);
      end
    end
  else
    WowCyborg_CURRENTATTACK = "-";
  end
end
