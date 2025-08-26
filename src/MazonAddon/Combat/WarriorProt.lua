--[[
NAME: Warrior Protection
ICON: ability_warrior_defensivestance
]]--

local demoralizingShout = "F+6";
local shieldWall = "F+7";
local lastStand = "F+8";
local rallyingCry = "F+9";
local shieldSlam = "1";
local thunderClap = "2";
local revenge = "3";
local execute = "4";
local shieldBlock = "5";
local ignorePain = "6";
local victoryRush = "7";
local heroicThrow = "0";

local eightYardCheck = 5246;--"Intimidating Shout";

WowCyborg_PAUSE_KEYS = {
  "F4",
  "R",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "§"
}


function GetClapCooldown()
  local sStart, sDuration = GetSpellCooldown("Thunder Clap");
  local tl = sStart + sDuration - GetTime();
  if tl < 0.3 then
    return 0;
  end

  return tl;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  local maxHp = UnitHealthMax("player");
  local rage = UnitPower("player");
  local hpPercentage = GetHealthPercentage("player");
  local nearbyEnemies = GetNearbyEnemyCount(eightYardCheck);
  local targetHp = GetHealthPercentage("target");
  local bsBuff = FindBuff("player", "Battle Shout");  
  local holActive = C_Spell.GetOverrideSpell(6343) == 435222 and GetClapCooldown() == 0;

  if (IsCastable("Thunder Clap", 0) or holActive) and nearbyEnemies > 0 then
    WowCyborg_CURRENTATTACK = "Thunder Clap";
    return SetSpellRequest(thunderClap);
  end
  
  if hpPercentage < 70 and IsCastableAtEnemyTarget("Impending Victory", 10) then
    WowCyborg_CURRENTATTACK = "Impending Victory";
    return SetSpellRequest(victoryRush);
  end

  if nearbyEnemies > 0 then
    local revBuff = FindBuff("player", "Revenge!");
    if (revBuff ~= nil) then
      if IsCastable("Revenge", 0) then
        WowCyborg_CURRENTATTACK = "Revenge";
        return SetSpellRequest(revenge);
      end
    end
  end

  if InMeleeRange() == false then
    if InCombatLockdown() and IsCastableAtEnemyTarget("Heroic Throw", 0) then
      WowCyborg_CURRENTATTACK = "Heroic Throw";
      return SetSpellRequest(heroicThrow);
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if hpPercentage < 60 then
    if IsCastable("Last Stand", 0) then
      WowCyborg_CURRENTATTACK = "Last Stand";
      return SetSpellRequest(lastStand);
    end

    if IsCastable("Shield Wall", 0) and FindBuff("player", "Shield Wall") == nil then
      WowCyborg_CURRENTATTACK = "Shield Wall";
      return SetSpellRequest(shieldWall);
    end

    if IsCastable("Rallying Cry", 0) then
      WowCyborg_CURRENTATTACK = "Rallying Cry";
      return SetSpellRequest(rallyingCry);
    end
  end

  if InCombatLockdown() then
    if InMeleeRange() then
      local sbBuff = FindBuff("player", "Shield Block")
      if sbBuff == nil and IsCastable("Shield Block", 30) then
        WowCyborg_CURRENTATTACK = "Shield Block";
        return SetSpellRequest(shieldBlock);
      end
    end

    if (ipBuff == nil or ipTl < 3) and IsCastable("Ignore Pain", 35) then
      WowCyborg_CURRENTATTACK = "Ignore Pain";
      return SetSpellRequest(ignorePain);
    end
  end

  if nearbyEnemies > 1 then -- MULTI target
    if IsCastable("Demoralizing Shout", 0) and rage < 70 then
      WowCyborg_CURRENTATTACK = "Demoralizing Shout";
      return SetSpellRequest(demoralizingShout);
    end

    if IsCastable("Revenge", 50) and (ipBuff ~= nil and ipTl > 3) then
      WowCyborg_CURRENTATTACK = "Revenge";
      return SetSpellRequest(revenge);
    end

    if IsCastableAtEnemyTarget("Shield Slam", 0) then
      WowCyborg_CURRENTATTACK = "Shield Slam";
      return SetSpellRequest(shieldSlam);
    end
  elseif nearbyEnemies == 1 then -- SINGLE target
    if IsCastableAtEnemyTarget("Shield Slam", 0) then
      WowCyborg_CURRENTATTACK = "Shield Slam";
      return SetSpellRequest(shieldSlam);
    end

    if IsCastable("Demoralizing Shout", 0) and rage < 70 then
      WowCyborg_CURRENTATTACK = "Demoralizing Shout";
      return SetSpellRequest(demoralizingShout);
    end
    
    if rage > 20 then
      if targetHp < 20 and IsCastableAtEnemyTarget("Execute", 0) then
        WowCyborg_CURRENTATTACK = "Execute";
        return SetSpellRequest(execute);
      end
    end
    
    local revBuff = FindBuff("player", "Revenge!");
    if (revBuff == "Revenge!" or IsCastable("Revenge", 80)) then
      if IsCastable("Revenge", 0) then
        WowCyborg_CURRENTATTACK = "Revenge";
        return SetSpellRequest(revenge);
      end
    end
  end

  -- Ignore pain logic
  local requiredAmount = maxHp * 0.2;
    
  local ipBuff, ipTl, _, __, ___, points = FindBuff("player", "Ignore Pain");
  local ipAmount = 0;
  if points ~= nil then
    ipAmount = points[1]
  end
  
  local needIgnorePain = InCombatLockdown() and (ipBuff == nil or ipTl < 3 or ipAmount < requiredAmount);
  if needIgnorePain and IsCastable("Ignore Pain", 35) then
    WowCyborg_CURRENTATTACK = "Ignore Pain";
    return SetSpellRequest(ignorePain);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Shield Slam", "target") == 1;
end

print("Protection warrior rotation loaded");
