--[[
  Button    Spell
  rampage = "1";
  recklessness = "2";
  execute = "3";
  bloodthirst = "4";
  ragingBlow = "5";
  whirlwind = "6";
  siegeBreaker = "7";
  bladestorm = "8";
  victoryRush = "9";
]]--

local rampage = "1";
local recklessness = "2";
local execute = "3";
local bloodthirst = "4";
local ragingBlow = "5";
local whirlwind = "6";
local siegeBreaker = "7";
local bladestorm = "8";
local victoryRush = "SHIFT+2";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "NUMPAD5",
  "F",
  "LSHIFT"
}

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(aoe)
  local hpPercentage = GetHealthPercentage("player");
  local thornsBuff = FindBuff("target", "Thorns");

  if thornsBuff ~= nil then
    print("THORNS!");
    WowCyborg_CURRENTATTACK = "THORNS!";
    return SetSpellRequest(nil);
  end

  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if aoe then
    local wwBuff = FindBuff("player", "Whirlwind");
    if wwBuff == nil then
      if IsCastableAtEnemyTarget("Whirlwind", 0) then
        WowCyborg_CURRENTATTACK = "Whirlwind";
        return SetSpellRequest(whirlwind);
      end
    end
  end

  local enemyHP = GetHealthPercentage("target");
  local sdBuff = FindBuff("player", "Sudden Death");

  if enemyHP < 35 or enemyHP > 80 or sdBuff == "Sudden Death" then
    if IsCastableAtEnemyTarget("Execute", 0) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end
  end

  local vrBuff = FindBuff("player", "Victorious")
  if hpPercentage < 80 and 
    IsCastableAtEnemyTarget("Victory Rush", 0) and 
    vrBuff == "Victorious" then
    WowCyborg_CURRENTATTACK = "Victory Rush";
    return SetSpellRequest(victoryRush);
  end

  local rage = UnitPower("player");
  local enrageBuff, enrageTime = FindBuff("player", "Enrage");
  if enrageBuff == nil or rage > 80 then
    if IsCastableAtEnemyTarget("Rampage", 80) then
      WowCyborg_CURRENTATTACK = "Rampage";
      return SetSpellRequest(rampage);
    end
  end

  if IsCastableAtEnemyTarget("Recklessness", 0) then
    WowCyborg_CURRENTATTACK = "Recklessness";
    return SetSpellRequest(recklessness);
  end

  if enrageBuff ~= nil and enrageTime > 0 and aoe then
    if IsCastableAtEnemyTarget("Bladestorm", 0) or IsCastableAtEnemyTarget("Dragon Roar", 0) then
      WowCyborg_CURRENTATTACK = "Bladestorm";
      return SetSpellRequest(bladestorm);
    end
  end
  
  if IsCastableAtEnemyTarget("Siegebreaker", 0) then
    WowCyborg_CURRENTATTACK = "Siegebreaker";
    return SetSpellRequest(siegeBreaker);
  end

  if enrageBuff == nil and IsCastableAtEnemyTarget("Bloodthirst", 0) then
    WowCyborg_CURRENTATTACK = "Bloodthirst";
    return SetSpellRequest(bloodthirst);
  end

  local rbCharges = GetSpellCharges("Raging Blow")
  WowCyborg_CURRENTATTACK = "Raging Blow";
  if rbCharges == 2 and IsCastableAtEnemyTarget("Raging Blow", 0) then
    return SetSpellRequest(ragingBlow);
  end

  if IsCastableAtEnemyTarget("Bloodthirst", 0) then
    WowCyborg_CURRENTATTACK = "Bloodthirst";
    return SetSpellRequest(bloodthirst);
  end
  
  if rbCharges > 0 and IsCastableAtEnemyTarget("Raging Blow", 0) then
    WowCyborg_CURRENTATTACK = "Raging Blow";
    return SetSpellRequest(ragingBlow);
  end

  local cd1 = GetSpellCooldown("Rampage");
  local cd2 = GetSpellCooldown("Bloodthirst");
  local cd3 = GetSpellCooldown("Raging Blow");

  if cd1 > 1 and cd2 > 1 and cd3 > 1 then
    if IsCastableAtEnemyTarget("Whirlwind", 0) then
      WowCyborg_CURRENTATTACK = "Whirlwind";
      return SetSpellRequest(whirlwind);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Execute", "target") == 1;
end

print("Fury warrior rotation loaded");