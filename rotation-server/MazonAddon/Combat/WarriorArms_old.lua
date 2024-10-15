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
  "F1",
  "F2",
  "F5",
  "F6",
  "F7",
}

function RenderMultiTargetRotation()
  local hpPercentage = GetHealthPercentage("player");
  local bsBuff = FindBuff("player", "Battle Shout")
  if bsBuff == nil and IsCastable("Battle Shout", 0) then
    WowCyborg_CURRENTATTACK = "Battle Shout";
    return SetSpellRequest(battleShout);
  end

  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local vrBuff = FindBuff("player", "Victorious")
  if hpPercentage < 70 and 
    IsCastableAtEnemyTarget("Victory Rush", 0) and 
    vrBuff == "Victorious" then
    WowCyborg_CURRENTATTACK = "Victory Rush";
    return SetSpellRequest(victoryRush);
  end

  if IsCastableAtEnemyTarget("Avatar", 0) then
    WowCyborg_CURRENTATTACK = "Avatar";
    return SetSpellRequest(avatar);
  end

  if IsCastableAtEnemyTarget("Warbreaker", 0) then
    WowCyborg_CURRENTATTACK = "Warbreaker";
    return SetSpellRequest(warbreaker);
  end

  if IsCastableAtEnemyTarget("Sweeping Strikes", 0) then
    WowCyborg_CURRENTATTACK = "Sweeping Strikes";
    return SetSpellRequest(sweeping);
  end

  if IsCastableAtEnemyTarget("Overpower", 0) then
    WowCyborg_CURRENTATTACK = "Overpower";
    return SetSpellRequest(overpower);
  end

  if IsCastableAtEnemyTarget("Bladestorm", 0) then
    WowCyborg_CURRENTATTACK = "Bladestorm";
    return SetSpellRequest(bladestorm);
  end

  if IsCastableAtEnemyTarget("Execute", 20) then
    WowCyborg_CURRENTATTACK = "Execute";
    return SetSpellRequest(execute);
  end

  if IsCastableAtEnemyTarget("Whirlwind", 30) then
    WowCyborg_CURRENTATTACK = "Whirlwind";
    return SetSpellRequest(whirlwind);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  local hpPercentage = GetHealthPercentage("player");
  local bsBuff = FindBuff("player", "Battle Shout")
  if bsBuff == nil and IsCastable("Battle Shout", 0) then
    WowCyborg_CURRENTATTACK = "Battle Shout";
    return SetSpellRequest(battleShout);
  end

  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local vrBuff = FindBuff("player", "Victorious")
  if hpPercentage < 70 and 
    IsCastableAtEnemyTarget("Victory Rush", 0) and 
    vrBuff == "Victorious" then
    WowCyborg_CURRENTATTACK = "Victory Rush";
    return SetSpellRequest(victoryRush);
  end

  if IsCastableAtEnemyTarget("Avatar", 0) then
    WowCyborg_CURRENTATTACK = "Avatar";
    return SetSpellRequest(avatar);
  end

  if IsCastableAtEnemyTarget("Warbreaker", 0) then
    WowCyborg_CURRENTATTACK = "Warbreaker";
    return SetSpellRequest(warbreaker);
  end

  if IsCastableAtEnemyTarget("Execute", 20) then
    WowCyborg_CURRENTATTACK = "Execute";
    return SetSpellRequest(execute);
  end

  local opBuff, opBuffTl, opBuffStacks = FindBuff("player", "Overpower")
  if opBuff ~= nil and opBuffStacks == 2 and IsCastableAtEnemyTarget("Mortal Strike", 60) then
    WowCyborg_CURRENTATTACK = "Mortal Strike";
    return SetSpellRequest(mortalStrike);
  end

  if IsCastableAtEnemyTarget("Overpower", 0) then
    WowCyborg_CURRENTATTACK = "Overpower";
    return SetSpellRequest(overpower);
  end

  if IsCastableAtEnemyTarget("Mortal Strike", 80) then
    WowCyborg_CURRENTATTACK = "Mortal Strike";
    return SetSpellRequest(mortalStrike);
  end

  local deepWound = FindDebuff("target", "Deep Wounds");
  if deepWound == nil and IsCastableAtEnemyTarget("Mortal Strike", 30) then
    WowCyborg_CURRENTATTACK = "Mortal Strike";
    return SetSpellRequest(mortalStrike);
  end

  if IsCastableAtEnemyTarget("Bladestorm", 0) then
    WowCyborg_CURRENTATTACK = "Bladestorm";
    return SetSpellRequest(bladestorm);
  end

  local rage = UnitPower("player")
  if rage < 80 and IsCastableAtEnemyTarget("Skullsplitter", 0) then
    WowCyborg_CURRENTATTACK = "Skullsplitter";
    return SetSpellRequest(skullsplitter);
  end

  if IsCastableAtEnemyTarget("Slam", 20) then
    WowCyborg_CURRENTATTACK = "Slam";
    return SetSpellRequest(slam);
  end

end

function InMeleeRange()
  return IsSpellInRange("Execute", "target") == 1;
end

print("Arms warrior rotation loaded");