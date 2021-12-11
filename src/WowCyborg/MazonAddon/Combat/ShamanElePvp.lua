--[[
  Button    Spell
local flameShock = "3";
local stormKeeper = "4";
local earthShock = "5";
local lavaBurst = "6";
local cancelCast = "7";
local lightningBolt = "8";
local frostShock = "9";
local echoingShock = "0";
local hsTotem = "CTRL+1";
local earthShield = "CTRL+2";
]]--

local flameShock = "3";
local stormKeeper = "4";
local earthShock = "5";
local lavaBurst = "6";
local cancelCast = "7";
local lightningBolt = "8";
local frostShock = "9";
local echoingShock = "0";
local hsTotem = "CTRL+1";
local earthShield = "CTRL+2";

WowCyborg_PAUSE_KEYS = {
  "1",
  "2",
  "R",
  "F",
}

-- Movement
local function RenderTargetRotationInMovement()
  local lsBuff = FindBuff("player", "Lava Surge");
  local fsDot, fsDotTimeLeft = FindDebuff("target", "Flame Shock");

  if fsDot == nil or fsDotTimeLeft <= 6.5 then
    if IsCastableAtEnemyTarget("Flame Shock", 0) then
      WowCyborg_CURRENTATTACK = "Flame Shock";
      return SetSpellRequest(flameShock);
    end
  end

  if lsBuff == "Lava Surge" then
    if IsCastableAtEnemyTarget("Lava Burst", 0) then
      WowCyborg_CURRENTATTACK = "Lava Burst";
      return SetSpellRequest(lavaBurst);
    end
  end

  local moeBuff = FindBuff("player", "Master of the Elements");
  if IsCastableAtEnemyTarget("Earth Shock", 60) then
    if moeBuff ~= nil and IsCastableAtEnemyTarget("Echoing Shock", 0) then
      WowCyborg_CURRENTATTACK = "Echoing Shock";
      return SetSpellRequest(echoingShock);
    end
    WowCyborg_CURRENTATTACK = "Earth Shock";
    return SetSpellRequest(earthShock);
  end
  
  if IsCastableAtEnemyTarget("Frost Shock", 0) then
    WowCyborg_CURRENTATTACK = "Frost Shock";
    return SetSpellRequest(frostShock);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

-- Single target
function RenderSingleTargetRotation()
  local esBuff = FindBuff("player", "Earth Shield");

  if esBuff == nil then
    if IsCastable("Earth Shield", 0) then
      WowCyborg_CURRENTATTACK = "Earth Shield";
      return SetSpellRequest(earthShield);
    end
  end

  if UnitChannelInfo("player") == "Lightning Lasso" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local gwBuff = FindBuff("player", "Ghost Wolf");
  if gwBuff ~= nil then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local skBuff = FindBuff("player", "Stormkeeper");
  if skBuff ~= nil then
    if IsCastableAtEnemyTarget("Lightning Bolt", 0) then
      WowCyborg_CURRENTATTACK = "Lightning Bolt";
      return SetSpellRequest(lightningBolt);
    end
  end

  if IsMoving() == true and spiritWalkerBuff == nil then
    return RenderTargetRotationInMovement();
  end

  local lsBuff = FindBuff("player", "Lava Surge");
  local fsDot, fsDotTimeLeft = FindDebuff("target", "Flame Shock");

  local hp = GetHealthPercentage("player");
  if hp < 70 then
    if IsCastable("Healing Stream Totem", 0) then
      WowCyborg_CURRENTATTACK = "Healing Stream Totem";
      return SetSpellRequest(hsTotem);
    end
  end

  if lsBuff == "Lava Surge" then
    local cast, cast2, castTl = UnitCastingInfo("player");
    if UnitCastingInfo("player") ~= nil and UnitCastingInfo("player") ~= "Hex" then 
      WowCyborg_CURRENTATTACK = "Cancel";
      return SetSpellRequest(cancelCast);
    end

    if IsCastableAtEnemyTarget("Lava Burst", 0) then
      WowCyborg_CURRENTATTACK = "Lava Burst";
      return SetSpellRequest(lavaBurst);
    end
  end

  if IsCastableAtEnemyTarget("Flame Shock", 0) then
    if fsDot == nil or fsDotTimeLeft <= 6 then
      WowCyborg_CURRENTATTACK = "Flame Shock";
      return SetSpellRequest(flameShock);
    end
  end
  
  local maelstrom = UnitPower("player");
  local moeBuff = FindBuff("player", "Master of the Elements");

  if IsCastableAtEnemyTarget("Earth Shock", 60) and moeBuff ~= nil then 
    if IsCastableAtEnemyTarget("Echoing Shock", 0) then
      WowCyborg_CURRENTATTACK = "Echoing Shock";
      return SetSpellRequest(echoingShock);
    end

    local esStart, esDuration = GetSpellCooldown("Echoing Shock");
    local esCdLeft = esStart + esDuration - GetTime();
    local esBuff = FindBuff("Echoing Shock");
    if esBuff ~= nil or esCdLeft > 6 then
      WowCyborg_CURRENTATTACK = "Earth Shock";
      return SetSpellRequest(earthShock);
    end
  end

  if IsCastableAtEnemyTarget("Lava Burst", 0) and fsDot ~= nil then
    WowCyborg_CURRENTATTACK = "Lava Burst";
    return SetSpellRequest(lavaBurst);
  end

  if IsCastableAtEnemyTarget("Earth Shock", 60) then
    WowCyborg_CURRENTATTACK = "Earth Shock";
    return SetSpellRequest(earthShock);
  end

  if IsCastableAtEnemyTarget("Lightning Bolt", 0) then
    WowCyborg_CURRENTATTACK = "Lightning Bolt";
    return SetSpellRequest(lightningBolt);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Elemental shaman rotation loaded");