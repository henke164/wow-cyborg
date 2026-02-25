function IsNearby(target, spellRangeCheck)
  if UnitCanAttack("player", target) == false then
    return false
  end

  return IsSpellInRange(spellRangeCheck, target)
end

function GetNearbyEnemyCount(spellRangeCheck)
  if spellRangeCheck == nil then
    return 0;
  end

  local count = 0;

  for i = 1, 40 do
    if IsNearby("nameplate" .. i, spellRangeCheck) == true then
      if UnitIsDead("nameplate" .. i) == false then
        count = count + 1;
      end
    end
  end

  return count;
end

function GetSpellCooldown(spellName)
  if (C_Spell == nil) then
    return 0;
  end

  local spellCd = C_Spell.GetSpellCooldown(spellName)
  if spellCd == nil then
    return nil;
  end

  return spellCd.startTime, spellCd.duration;
end

function Pause(secondsAfterGcd)
  local cdUntil = GetSpellCooldown(61304);
  local globalTl = GetTime() - cdUntil;
  if globalTl > 1.5 or globalTl < 0 then
    globalTl = 0;
  end

  WowCyborg_PAUSE_UNTIL = GetTime() + globalTl + secondsAfterGcd;
end

function IsSpellInRange(spellID, unit)
  if not UnitExists(unit) then return false end
  if UnitIsDead(unit) then return false end

  if C_Spell.IsSpellInRange("Rebuke", "target") then
    return true
  end

  local inRange = C_Spell.IsSpellInRange(spellID, unit)
  return inRange
end

function GetHighlightedActionSlot()
  for slot = 1, 9 do
    if IsActionSlotAssistedHighlighted(slot) then
      return slot
    end
  end
  return nil
end
