--[[
  Button    Spell
  1         Hamstring
  2         Slam
  3         Execute
  4         Mortal Strike
  5         Overpower
]]--

local rollTheBones = "1";
local adrenalineRush = "2";
local betweenTheEyes = "3";
local sinisterStrike = "4";
local dispatch = "5";
local pistolShot = "6";

function RenderMultiTargetRotation()
  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  return RenderSingleTargetRotation()
end

function RenderSingleTargetRotation()
  local stealth = FindBuff("player", "Stealth");

  if InMeleeRange() == false or stealth ~= nil then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local points = GetComboPoints("player", "target");
  if points >= 4 then
    WowCyborg_CURRENTATTACK = "Roll the Bones";
    return SetSpellRequest(rollTheBones);
  end

  if IsCastable("Adrenaline Rush", 0) then
    WowCyborg_CURRENTATTACK = "Adrenaline Rush";
    return SetSpellRequest(adrenalineRush);
  end

  local b1 = FindBuff("player", "Ruthless Precision");
  local b2 = FindBuff("player", "Ace Up Your Sleeve");
  local b3 = FindBuff("player", "Deadshot");
  if b1 ~= nil or b2 ~= nil or b3 ~= nil then
    if points >= 4 and IsCastableAtEnemyTarget("Between the Eyes", 0) then
      WowCyborg_CURRENTATTACK = "Between the Eyes";
      return SetSpellRequest(betweenTheEyes);
    end
  end
  
  if points >= 4 and IsCastableAtEnemyTarget("Dispatch", 0) then
    WowCyborg_CURRENTATTACK = "Dispatch";
    return SetSpellRequest(dispatch);
  end

  local opBuff = FindBuff("player", "Opportunity");
  if opBuff and points <= 3 and IsCastableAtEnemyTarget("Pistol Shot", 0) then
    WowCyborg_CURRENTATTACK = "Pistol Shot";
    return SetSpellRequest(pistolShot);
  end

  WowCyborg_CURRENTATTACK = "Sinister Strike";
  return SetSpellRequest(sinisterStrike);
end

function InMeleeRange()
  return IsSpellInRange("Execute", "target") == 1;
end

print("Arms warrior rotation loaded");