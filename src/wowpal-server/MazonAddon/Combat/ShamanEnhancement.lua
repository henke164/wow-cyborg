--[[
  flametongue = "2"
  frostbrand = "4"
  stormstrike = "5"
  lavaLash = "7"
  crashLightning = "8"
  lightningShield = "9"
]]--

local flametongue = "8";
local frostbrand = "7";
local stormstrike = "2";
local lavaLash = "3";
local crashLightning = "4";
local lightningBolt = "5";
local lightningShield = "9";

WowCyborg_PAUSE_KEYS = {
}

function IsMelee()
  return CheckInteractDistance("target", 5);
end

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

-- Single target
function RenderSingleTargetRotation(aoe)
  if aoe == nil then
    aoe = false
  end
  
  if WowCyborg_INCOMBAT == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local lsBuff = FindBuff("player", "Lightning Shield");
  if lsBuff == nil then
    WowCyborg_CURRENTATTACK = "Lightning Shield";
    return SetSpellRequest(lightningShield);
  end
  
  local maelstromWeapon, mswTl, mswStacks = FindBuff("player", "Maelstrom Weapon");
  if mswStacks ~= nil and mswStacks > 5 then
    if IsCastableAtEnemyTarget("Lightning Bolt", 0) then
      WowCyborg_CURRENTATTACK = "Lightning Bolt";
      return SetSpellRequest(lightningBolt);
    end
  end

  -- frostbrand
  local frBuff, frTimeLeft = FindBuff("player", "Natural Harmony: Frost");
  if (frBuff ~= nil and frTimeLeft <= 3) then
    if IsCastableAtEnemyTarget("Frostbrand", 20) then
      WowCyborg_CURRENTATTACK = "Frostbrand";
      return SetSpellRequest(frostbrand);
    end
  end
  
  -- flametongue
  local fBuff, fTimeLeft = FindBuff("player", "Natural Harmony: Fire");
  if (fBuff ~= nil and fTimeLeft <= 3) then
    if IsCastableAtEnemyTarget("Flametongue", 0) then
      WowCyborg_CURRENTATTACK = "Flametongue";
      return SetSpellRequest(flametongue);
    end
  end
  
  if aoe and IsMelee() and IsCastableAtEnemyTarget("Crash Lightning", 0) then
    WowCyborg_CURRENTATTACK = "Crash Lightning";
    return SetSpellRequest(crashLightning);
  end

  local ftBuff, ftBuffTl = FindBuff("player", "Flametongue")
  if ftBuff == nil then
    if IsCastableAtEnemyTarget("Flametongue", 0) then
      WowCyborg_CURRENTATTACK = "Flametongue";
      return SetSpellRequest(flametongue);
    end
  end

  local fbBuff, fbBuffTl = FindBuff("player", "Frostbrand")
  if fbBuff == nil then
    if IsCastableAtEnemyTarget("Frostbrand", 20) then
      WowCyborg_CURRENTATTACK = "Frostbrand";
      return SetSpellRequest(frostbrand);
    end
  end

  local sbringerBuff = FindBuff("player", "Stormbringer")
  if sbringerBuff == nil then
    if IsCastableAtEnemyTarget("Stormstrike", 30) then
      WowCyborg_CURRENTATTACK = "Stormstrike";
      return SetSpellRequest(stormstrike);
    end
  else
    if IsCastableAtEnemyTarget("Stormstrike", 0) then
      WowCyborg_CURRENTATTACK = "Stormstrike";
      return SetSpellRequest(stormstrike);
    end
  end

  if aoe and IsMelee() and IsCastableAtEnemyTarget("Crash Lightning", 0) then
    WowCyborg_CURRENTATTACK = "Crash Lightning";
    return SetSpellRequest(crashLightning);
  end

  if ftBuffTl ~= nil and ftBuffTl < GetGCDMax() * 2 then
    if IsCastableAtEnemyTarget("Flametongue", 0) then
      WowCyborg_CURRENTATTACK = "Flametongue";
      return SetSpellRequest(flametongue);
    end
  end
  
  if fbBuffTl ~= nil and fbBuffTl < GetGCDMax() * 2 then
    if IsCastableAtEnemyTarget("Frostbrand", 0) then
      WowCyborg_CURRENTATTACK = "Frostbrand";
      return SetSpellRequest(frostbrand);
    end
  end

  if IsMelee() and IsCastableAtEnemyTarget("Crash Lightning", 0) then
    WowCyborg_CURRENTATTACK = "Crash Lightning";
    return SetSpellRequest(crashLightning);
  end

  if IsCastableAtEnemyTarget("Lava Lash", 0) then
    WowCyborg_CURRENTATTACK = "Lava Lash";
    return SetSpellRequest(lavaLash);
  end

  if IsCastableAtEnemyTarget("Flametongue", 0) then
    WowCyborg_CURRENTATTACK = "Flametongue";
    return SetSpellRequest(flametongue);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Enhancement shaman rotation loaded");