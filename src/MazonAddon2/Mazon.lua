WowCyborg_AOE_Rotation = false;
WowCyborg_CLASSIC = true;
WowCyborg_CURRENTATTACK = "-";
WowCyborg_DISABLED = false;
WowCyborg_PAUSE = false;
WowCyborg_PAUSE_UNTIL = 0;
WowCyborg_INCOMBAT = false;
WowCyborg_PAUSE_KEYS = {};

WowCyborg_MeleeDetectionSpell = "";
WowCyborg_NearbyEnemyDetectionSpell = "";

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
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local slot = GetHighlightedActionSlot();

  if WowCyborg_ClassRotation ~= nil then
    local result = WowCyborg_ClassRotation(slot);
    if result == true then
      return;
    end
  end

  if UnitChannelInfo("player") ~= nil then
    WowCyborg_CURRENTATTACK = "Channeling";
    return SetSpellRequest(nil);
  end

  if UnitCastingInfo("player") ~= nil then
    WowCyborg_CURRENTATTACK = "Casting";
    return SetSpellRequest(nil);
  end

  if UnitCanAttack("player", "target") == false or UnitIsDead("target") then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if slot ~= nil then
    local actionType, id = GetActionInfo(slot)
    if (id ~= nil and actionType == "spell") then
      local inRange = IsSpellInRange(id, "target")
      local nearbyEnemies = GetNearbyEnemyCount(WowCyborg_NearbyEnemyDetectionSpell);

      if inRange or nearbyEnemies > 0 then
        if slot == 10 then
          slot = 0;
        end

        SetSpellRequest(slot);
        WowCyborg_CURRENTATTACK = slot;
      else
        WowCyborg_CURRENTATTACK = "Out of range";
        SetSpellRequest(nil);
      end
    end
  else
    WowCyborg_CURRENTATTACK = "-";
    SetSpellRequest(nil);
  end
end
