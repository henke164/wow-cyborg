--[[
  Button    Spell
]]--

local consecration = 1;

WowCyborg_PAUSE_KEYS = {
  "§",
  "F",
}

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation()
  local empower = UnitPower("player", 19);
  local speed = GetUnitSpeed("player");
  local essenseBursts, ebTl, ebStacks = FindBuff("player", "Essence Burst");

  if UnitChannelInfo("player") or UnitCastingInfo("player") then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if speed > 0 then
    if IsCastableAtEnemyTarget("Azure Strike", 0) then
      WowCyborg_CURRENTATTACK = "Azure Strike";
      return SetSpellRequest("2");
    end
  end
  
  if (empower == 1) then
    if IsCastableAtEnemyTarget("Fire Breath", 0) then
      WowCyborg_CURRENTATTACK = "Fire Breath";
      return SetSpellRequest(nil);
    end
  end

  if IsCastableAtEnemyTarget("Shattering Star", 0) then
    WowCyborg_CURRENTATTACK = "Shattering Star";
    return SetSpellRequest("6");
  end

  if (empower == 1) then
    if IsCastableAtEnemyTarget("Eternity Surge", 0) then
      WowCyborg_CURRENTATTACK = "Eternity Surge";
      return SetSpellRequest("7");
    end
  end

  if IsCastableAtEnemyTarget("Disintegrate", 0) and empower >= 3 then
    WowCyborg_CURRENTATTACK = "Disintegrate";
    return SetSpellRequest("5");
  end

  if IsCastableAtEnemyTarget("Living Flame", 0) then
    WowCyborg_CURRENTATTACK = "Living Flame";
    return SetSpellRequest("1");
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Prot pala rotation loaded");