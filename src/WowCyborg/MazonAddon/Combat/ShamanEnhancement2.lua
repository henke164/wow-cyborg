local crash_lightning = "4";
local frostbrand = "7";
local flametongue = "8";
local rockbiter = "1";
local stormstrike = "2";
local lava_lash = "3";

local function priority(aoe)
  -- crash lightning
  if aoe and IsCastableAtEnemyTarget("crash lightning", 20) then
    WowCyborg_CURRENTATTACK = "crash lightning";
    return SetSpellRequest(crash_lightning);
  end
  
  -- frostbrand
  local frBuff, frTimeLeft = FindBuff("player", "Natural Harmony: Frost");
  if (frBuff ~= nil and frTimeLeft <= 2 * GetCurrentSpellGCD("frostbrand")) then
    if IsCastableAtEnemyTarget("frostbrand", 0) then
      WowCyborg_CURRENTATTACK = "frostbrand";
      return SetSpellRequest(frostbrand);
    end
  end
  
  -- flametongue
  local fBuff, fTimeLeft = FindBuff("player", "Natural Harmony: Fire");
  if (fBuff ~= nil and fTimeLeft <= 2 * GetCurrentSpellGCD("Flametongue")) then
    if IsCastableAtEnemyTarget("flametongue", 0) then
      WowCyborg_CURRENTATTACK = "flametongue";
      return SetSpellRequest(flametongue);
    end
  end
  
  -- rockbiter
  local nBuff, nTimeLeft = FindBuff("player", "Natural Harmony: Nature");
  if ((nBuff ~= nil and nTimeLeft <= 2 * GetCurrentSpellGCD("rockbiter")) and maelstrom < 70) then
    if IsCastableAtEnemyTarget("rockbiter", 0) then
      WowCyborg_CURRENTATTACK = "rockbiter";
      return SetSpellRequest(rockbiter);
    end
  end
  
end

local function maintenance()
  -- flametongue
  if (FindBuff("player", "flametongue") == nil) then
    if IsCastableAtEnemyTarget("flametongue", 0) then
      WowCyborg_CURRENTATTACK = "flametongue";
      return SetSpellRequest(flametongue);
    end
  end
  
  -- frostbrand
  if (TalentEnabled("hailstorm") and FindBuff("player", "frostbrand") == nil) then
    if IsCastableAtEnemyTarget("frostbrand", 0) then
      WowCyborg_CURRENTATTACK = "frostbrand";
      return SetSpellRequest(frostbrand);
    end
  end
end

local function default_core(aoe)
  -- stormstrike
  if IsCastableAtEnemyTarget("stormstrike", 0) then
    WowCyborg_CURRENTATTACK = "stormstrike";
    return SetSpellRequest(stormstrike);
  end
  
  -- stormstrike
  if (FindBuff("player", "stormbringer") ~= nil or FindBuff("player", "gathering storms") ~= nil) then
    if IsCastableAtEnemyTarget("stormstrike", 0) then
      WowCyborg_CURRENTATTACK = "stormstrike";
      return SetSpellRequest(stormstrike);
    end
  end
  
  -- crash lightning
  if (aoe) then
    if IsCastableAtEnemyTarget("crash lightning", 20) then
      WowCyborg_CURRENTATTACK = "crash lightning";
      return SetSpellRequest(crash_lightning);
    end
  end
  
  -- stormstrike
  if IsCastableAtEnemyTarget("stormstrike", 0) then
    WowCyborg_CURRENTATTACK = "stormstrike";
    return SetSpellRequest(stormstrike);
  end
end

function OCPool()
  return GetCooldown("Lightning Bolt") >= 3;
end

local function filler()
  local maelstrom = UnitPower("player");

  -- crash lightning
  if IsCastableAtEnemyTarget("crash lightning", 20) then
    WowCyborg_CURRENTATTACK = "crash lightning";
    return SetSpellRequest(crash_lightning);
  end
  
  if maelstrom < 70 then
    if IsCastableAtEnemyTarget("rockbiter", 0) then
      WowCyborg_CURRENTATTACK = "rockbiter";
      return SetSpellRequest(rockbiter);
    end
  end
  
  -- crash lightning
  if OCPool() then
    if IsCastableAtEnemyTarget("crash lightning", 20) then
      WowCyborg_CURRENTATTACK = "crash lightning";
      return SetSpellRequest(crash_lightning);
    end
  end
  
  -- lava lash
  if OCPool() then
    if IsCastableAtEnemyTarget("lava lash", 0) then
      WowCyborg_CURRENTATTACK = "lava lash";
      return SetSpellRequest(lava_lash);
    end
  end
  
  -- rockbiter
  if IsCastableAtEnemyTarget("rockbiter", 0) then
    WowCyborg_CURRENTATTACK = "rockbiter";
    return SetSpellRequest(rockbiter);
  end
  
  -- frostbrand
  if ((GetBuffTimeLeft("player", "frostbrand") < 4.8 + GetCurrentSpellGCD("frostbrand")) and OCPool()) then
    if IsCastableAtEnemyTarget("frostbrand", 0) then
      WowCyborg_CURRENTATTACK = "frostbrand";
      return SetSpellRequest(frostbrand);
    end
  end
  
  -- flametongue
  if IsCastableAtEnemyTarget("flametongue", 0) then
    WowCyborg_CURRENTATTACK = "flametongue";
    return SetSpellRequest(flametongue);
  end
end

function RenderSingleTargetRotation()
  local p = priority(false);
  if (p ~= nil) then
    return p;
  end

  local m = maintenance();
  if (m ~= nil) then
    return m;
  end
  
  local dc = default_core(false);
  if (dc ~= nil) then
    return dc;
  end

  local f = filler();
  if (f ~= nil) then
    return f;
  end
  
  WowCyborg_CURRENTATTACK = "-"
  return SetSpellRequest(nil)
 end
 
 function RenderMultiTargetRotation()
  local p = priority(true);
  if (p ~= nil) then
    return p;
  end
  
  local dc = default_core(true);
  if (dc ~= nil) then
    return dc;
  end

  local m = maintenance();
  if (m ~= nil) then
    return m;
  end
  
  local f = filler();
  if (f ~= nil) then
    return f;
  end
  
  WowCyborg_CURRENTATTACK = "-"
  return SetSpellRequest(nil)
 end
