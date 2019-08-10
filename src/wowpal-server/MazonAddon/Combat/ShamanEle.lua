--[[
  Button    Spell
  1         Totem Mastery
  2         Flame Shock
  3         Earthquake
  4         Stormkeeper
  5         Earth Shock
  6         Lava Burst
  7         Chain Lightning
  8         Lightning Bolt
  9         Frost Shock
]]--

local totemMastery = "1";
local flameShock = "2";
local earthQuake = "3";
local stormKeeper = "4";
local earthShock = "5";
local lavaBurst = "6";
local chainLightning = "7";
local lightningBolt = "8";
local frostShock = "9";
local recentlyCastedLavaBurst = false;

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

  if IsCastableAtEnemyTarget("Earth Shock", 60) then
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
  if UnitChannelInfo("player") == "Lightning Lasso" then
    return SetSpellRequest(nil);
  end

  if IsMoving() == true then
    return RenderTargetRotationInMovement();
  end

  local fsDot, fsDotTimeLeft = FindDebuff("target", "Flame Shock");

  if IsCastableAtEnemyTarget("Lightning Bolt", 0) then
    if IsCastableAtEnemyTarget("Flame Shock", 0) then
      if fsDot == nil then
        WowCyborg_CURRENTATTACK = "Flame Shock";
        return SetSpellRequest(flameShock);
      end
    end
    
    if IsCastableAtEnemyTarget("Stormkeeper", 0) then
      WowCyborg_CURRENTATTACK = "Stormkeeper";
      return SetSpellRequest(stormKeeper);
    end
  end
  
  local maelstrom = UnitPower("player");
  local moeBuff = FindBuff("player", "Master of the Elements");

  if IsCastableAtEnemyTarget("Earthquake", 60) and 
    moeBuff == "Master of the Elements" then
    WowCyborg_CURRENTATTACK = "Earthquake";
    return SetSpellRequest(earthQuake);
  end

  if fsDot == "Flame Shock" and fsDotTimeLeft <= 7 then
    WowCyborg_CURRENTATTACK = "Flame Shock";
    return SetSpellRequest(flameShock);
  end

  if IsCastableAtEnemyTarget("Earthquake", 60) then
    WowCyborg_CURRENTATTACK = "Earthquake";
    return SetSpellRequest(earthQuake);
  end

  if IsCastableAtEnemyTarget("Chain Lightning", 0) then
    WowCyborg_CURRENTATTACK = "Chain Lightning";
    return SetSpellRequest(chainLightning);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

-- Single target
function RenderSingleTargetRotation()
  local castingSpell = UnitCastingInfo("player");
  recentlyCastedLavaBurst = castingSpell == "Lava Burst";

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

  if IsMoving() == true then
    return RenderTargetRotationInMovement();
  end

  local fsDot, fsDotTimeLeft = FindDebuff("target", "Flame Shock");

  if IsCastableAtEnemyTarget("Lightning Bolt", 0) then
    local totemBuff = FindBuff("player", "Storm Totem");	
    if totemBuff == nil then 	
      return SetSpellRequest(totemMastery);	
    end
    
    if IsCastableAtEnemyTarget("Flame Shock", 0) then
      if fsDot == nil then
        if IsCastableAtEnemyTarget("Lava Burst", 0) and recentlyCastedLavaBurst == false then
          WowCyborg_CURRENTATTACK = "Lava Burst";
          return SetSpellRequest(lavaBurst);
        else
          WowCyborg_CURRENTATTACK = "Flame Shock";
          return SetSpellRequest(flameShock);
        end
      end
    end

    if IsCastableAtEnemyTarget("Stormkeeper", 0) then
      WowCyborg_CURRENTATTACK = "Stormkeeper";
      return SetSpellRequest(stormKeeper);
    end
  end
  
  local maelstrom = UnitPower("player");
  local moeBuff = FindBuff("player", "Master of the Elements");

  if IsCastableAtEnemyTarget("Earth Shock", 90) then 
    WowCyborg_CURRENTATTACK = "Earth Shock";
    return SetSpellRequest(earthShock);
  end
  
  if IsCastableAtEnemyTarget("Earth Shock", 60) and moeBuff ~= nil then 
    WowCyborg_CURRENTATTACK = "Earth Shock";
    return SetSpellRequest(earthShock);
  end

  if IsCastableAtEnemyTarget("Lava Burst", 0) and fsDot ~= nil then
    WowCyborg_CURRENTATTACK = "Lava Burst";
    return SetSpellRequest(lavaBurst);
  end

  if fsDot == "Flame Shock" and fsDotTimeLeft <= 6 then
    WowCyborg_CURRENTATTACK = "Flame Shock";
    return SetSpellRequest(flameShock);
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