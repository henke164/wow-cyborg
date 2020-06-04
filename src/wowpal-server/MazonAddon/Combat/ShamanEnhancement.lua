--[[
  furyOfAir = "1"
  flametongue = "2"
  frostbrand = "4"
  stormstrike = "5"
  rockbiter = "6"
  lavaLash = "7"
  crashLightning = "8"
  lightningShield = "9"
]]--

local furyOfAir = "5";
local flametongue = "8";
local frostbrand = "7";
local stormstrike = "2";
local rockbiter = "1";
local lavaLash = "3";
local crashLightning = "4";
local lightningShield = "9";

WowCyborg_PAUSE_KEYS = {
  "5",
  "X",
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
  
  if IsCurrentSpell(6603) == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if WowCyborg_INCOMBAT == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local maelstrom = UnitPower("player");
  local lsBuff = FindBuff("player", "Lightning Shield");
  if lsBuff == nil then
    WowCyborg_CURRENTATTACK = "Lightning Shield";
    return SetSpellRequest(lightningShield);
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
  
  -- rockbiter
  local nBuff, nTimeLeft = FindBuff("player", "Natural Harmony: Nature");
  if ((nBuff ~= nil and nTimeLeft <= 3) and maelstrom < 70) then
    if IsCastableAtEnemyTarget("rockbiter", 0) then
      WowCyborg_CURRENTATTACK = "rockbiter";
      return SetSpellRequest(rockbiter);
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

  if maelstrom < 70 then
    if IsCastableAtEnemyTarget("Rockbiter", 0) and GetFullRechargeTime("Rockbiter") < 4 then
      WowCyborg_CURRENTATTACK = "Rockbiter";
      return SetSpellRequest(rockbiter);
    end
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

  if IsCastableAtEnemyTarget("Lava Lash", 80) then
    WowCyborg_CURRENTATTACK = "Lava Lash";
    return SetSpellRequest(lavaLash);
  end

  if IsCastableAtEnemyTarget("Rockbiter", 0) then
    WowCyborg_CURRENTATTACK = "Rockbiter";
    return SetSpellRequest(rockbiter);
  end

  if IsCastableAtEnemyTarget("Flametongue", 0) then
    WowCyborg_CURRENTATTACK = "Flametongue";
    return SetSpellRequest(flametongue);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Enhancement shaman rotation loaded");