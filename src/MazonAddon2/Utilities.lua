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

  if UnitCanAttack("player", unit) == false then
    return false
  end

  local inRange = C_Spell.IsSpellInRange(spellID, unit)
  return inRange
end

function ExtractSecretNumber(secretValue)
  local str = tostring(secretValue)
  local i = 0
  for part in str:gmatch("[^-]+") do
    i = i + 1
    if i == 6 then
      return tonumber(part)
    end
  end
  return nil
end

function IsSpellUsable(spellId)
  local usable = C_Spell.IsSpellUsable(spellId)
  return usable == true
end

function HasActiveBuff(spellId)
  return WowCyborg_ActiveBuffs[spellId] == true
end

function BuffRemainingTime(spellId)
  local expiry = WowCyborg_ActiveTimers[spellId]
  if not expiry then return 0 end
  local remaining = expiry - GetTime()
  if remaining < 0 then return 0 end
  return remaining
end

function ShouldRefreshBuff(spellId, threshold)
  if not HasActiveBuff(spellId) then return true end
  return BuffRemainingTime(spellId) <= threshold
end

function GetHighlightedActionSlot()
  for slot = 1, 10 do
    if IsActionSlotAssistedHighlighted(slot) then
      return slot
    end
  end
  return nil
end
