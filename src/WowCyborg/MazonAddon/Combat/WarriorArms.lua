--[[
  Button    Spell
  1         Hamstring
  2         Slam
  3         Execute
  4         Mortal Strike
  5         Overpower
]]--

local execute = "1";
local skullsplitter = "2";
local mortalStrike = "3";
local overpower = "4";
local bladestorm = "5";
local whirlwind = "6";
local warbreaker = "7";
local avatar = "9";
local slam = "0";
local battleShout = "CTRL+3";
local sweeping = "SHIFT+2";
local victoryRush = "SHIFT+3";

WowCyborg_PAUSE_KEYS = {
  "F",
  "LSHIFT",
  "F2",
  "F5",
  "F6",
  "F7",
}

function InMeleeRange()
  return IsSpellInRange("Execute", "target") == 1;
end

function RenderPreBuff()
  local bsBuff = FindBuff("player", "Battle Shout")
  if bsBuff == nil and IsCastable("Battle Shout", 0) then
    WowCyborg_CURRENTATTACK = "Battle Shout";
    return SetSpellRequest(battleShout);
  end

  if IsCastableAtEnemyTarget("Sweeping Strikes", 0) then
    WowCyborg_CURRENTATTACK = "Sweeping Strikes";
    return SetSpellRequest(sweeping);
  end

  local hpPercentage = GetHealthPercentage("player");
  local vrBuff = FindBuff("player", "Victorious")
  if hpPercentage < 80 and 
    IsCastableAtEnemyTarget("Victory Rush", 0) and 
    vrBuff == "Victorious" then
    WowCyborg_CURRENTATTACK = "Victory Rush";
    return SetSpellRequest(victoryRush);
  end

  return nil;
end

function RenderExecuteRotation()
  local rage = UnitPower("player");
  if rage < 60 and IsCastableAtEnemyTarget("Skullsplitter", 0) then
    WowCyborg_CURRENTATTACK = "Skullsplitter";
    return SetSpellRequest(skullsplitter);
  end

  local wbCd = GetCooldown("Warbreaker");
  if IsCastableAtEnemyTarget("Avatar", 0) and wbCd < 1 then
    WowCyborg_CURRENTATTACK = "Avatar";
    return SetSpellRequest(avatar);
  end

  --if IsCastableAtEnemyTarget("Warbreaker", 0) then
  --  WowCyborg_CURRENTATTACK = "Warbreaker";
  --  return SetSpellRequest(warbreaker);
  --end

  local opCharges = GetSpellCharges("Overpower");
  if opCharges == 2 and IsCastableAtEnemyTarget("Overpower", 0) then
    WowCyborg_CURRENTATTACK = "Overpower";
    return SetSpellRequest(overpower);
  end

  local deepWound, deepWoundTl = FindDebuff("target", "Deep Wounds");
  if deepWound == nil or deepWoundTl < 1.5 then
    if IsCastableAtEnemyTarget("Mortal Strike", 30) then
      WowCyborg_CURRENTATTACK = "Mortal Strike";
      return SetSpellRequest(mortalStrike);
    end
  end

  if rage < 40 and IsCastableAtEnemyTarget("Skullsplitter", 0) then
    WowCyborg_CURRENTATTACK = "Skullsplitter";
    return SetSpellRequest(skullsplitter);
  end

  if IsCastableAtEnemyTarget("Overpower", 0) then
    WowCyborg_CURRENTATTACK = "Overpower";
    return SetSpellRequest(overpower);
  end
  
  if IsCastableAtEnemyTarget("Execute", 20) then
    WowCyborg_CURRENTATTACK = "Execute";
    return SetSpellRequest(execute);
  end

  local colossusDebuff = FindDebuff("target", "Colossus Smash");
  if rage < 80 and colossusDebuff ~= nil and IsCastableAtEnemyTarget("Bladestorm", 0) then
    WowCyborg_CURRENTATTACK = "Bladestorm";
    return SetSpellRequest(bladestorm);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

-- MULTI
function RenderMultiTargetRotation()
  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local pre = RenderPreBuff();
  if pre ~= nil then
    return pre;
  end
  
  local targetHp = GetHealthPercentage("target");
  if targetHp < 20 then
    return RenderExecuteRotation();
  end

  local wbCd = GetCooldown("Warbreaker");
  if IsCastableAtEnemyTarget("Avatar", 0) and wbCd < 1 then
    WowCyborg_CURRENTATTACK = "Avatar";
    return SetSpellRequest(avatar);
  end
  
  --if IsCastableAtEnemyTarget("Warbreaker", 0) then
  --  WowCyborg_CURRENTATTACK = "Warbreaker";
  --  return SetSpellRequest(warbreaker);
  --end
  
  local colossusDebuff = FindDebuff("target", "Colossus Smash");
  if colossusDebuff ~= nil and IsCastableAtEnemyTarget("Bladestorm", 0) then
    WowCyborg_CURRENTATTACK = "Bladestorm";
    return SetSpellRequest(bladestorm);
  end

  local sweeping = FindBuff("player", "Sweeping Strikes");
  local deepWound, deepWoundTl = FindDebuff("target", "Deep Wounds");
  if sweeping ~= nil then
    if (deepWound == nil or deepWoundTl < 1.5) and IsCastableAtEnemyTarget("Mortal Strike", 30) then
      WowCyborg_CURRENTATTACK = "Mortal Strike";
      return SetSpellRequest(mortalStrike);
    end

    if IsCastableAtEnemyTarget("Execute", 20) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end
  end

  if IsCastableAtEnemyTarget("Overpower", 0) then
    WowCyborg_CURRENTATTACK = "Overpower";
    return SetSpellRequest(overpower);
  end
  
  if IsCastableAtEnemyTarget("Whirlwind", 30) then
    WowCyborg_CURRENTATTACK = "Whirlwind";
    return SetSpellRequest(whirlwind);
  end

  if IsCastableAtEnemyTarget("Skullsplitter", 0) then
    WowCyborg_CURRENTATTACK = "Skullsplitter";
    return SetSpellRequest(skullsplitter);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

-- Single
function RenderSingleTargetRotation()
  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local pre = RenderPreBuff();
  if pre ~= nil then
    return pre;
  end
  
  local targetHp = GetHealthPercentage("target");
  if targetHp < 20 then
    return RenderExecuteRotation();
  end

  local wbCd = GetCooldown("Warbreaker");
  if IsCastableAtEnemyTarget("Avatar", 0) and wbCd < 1 then
    WowCyborg_CURRENTATTACK = "Avatar";
    return SetSpellRequest(avatar);
  end
  
  --if IsCastableAtEnemyTarget("Warbreaker", 0) then
  --  WowCyborg_CURRENTATTACK = "Warbreaker";
  --  return SetSpellRequest(warbreaker);
  --end
  
  local colossusDebuff = FindDebuff("target", "Colossus Smash");
  if colossusDebuff ~= nil and IsCastableAtEnemyTarget("Bladestorm", 0) then
    WowCyborg_CURRENTATTACK = "Bladestorm";
    return SetSpellRequest(bladestorm);
  end

  local opCharges = GetSpellCharges("Overpower");
  if opCharges == 2 and IsCastableAtEnemyTarget("Overpower", 0) then
    WowCyborg_CURRENTATTACK = "Overpower";
    return SetSpellRequest(overpower);
  end

  local opBuff, opBuffCharges = FindBuff("Overpower");
  if opBuff ~= nil and opBuffCharges == 2 then
    if IsCastableAtEnemyTarget("Mortal Strike", 30) then
      WowCyborg_CURRENTATTACK = "Mortal Strike";
      return SetSpellRequest(mortalStrike);
    end
  end

  local rage = UnitPower("player");
  if rage < 60 and IsCastableAtEnemyTarget("Skullsplitter", 0) then
    WowCyborg_CURRENTATTACK = "Skullsplitter";
    return SetSpellRequest(skullsplitter);
  end

  if IsCastableAtEnemyTarget("Overpower", 0) then
    WowCyborg_CURRENTATTACK = "Overpower";
    return SetSpellRequest(overpower);
  end

  if IsCastableAtEnemyTarget("Mortal Strike", 30) then
    WowCyborg_CURRENTATTACK = "Mortal Strike";
    return SetSpellRequest(mortalStrike);
  end
  
  if IsCastableAtEnemyTarget("Whirlwind", 60) then
    WowCyborg_CURRENTATTACK = "Whirlwind";
    return SetSpellRequest(whirlwind);
  end

  if IsCastableAtEnemyTarget("Slam", 50) then
    WowCyborg_CURRENTATTACK = "Slam";
    return SetSpellRequest(slam);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Execute", "target") == 1;
end

print("Arms warrior rotation loaded");