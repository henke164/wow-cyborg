--[[p
  Button    Spell
  local rollTheBones = "1";
  local adrenalineRush = "2";
  local betweenTheEyes = "3";
  local sinisterStrike = "4";
  local dispatch = "5";
  local pistolShot = "6";
]]--

local rollTheBones = "1";
local sliceNDice = "2";
local betweenTheEyes = "3";
local sinisterStrike = "4";
local dispatch = "5";
local pistolShot = "6";
local bladeFlurry = "7";
local adrenalineRush = "8";

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true)
end

function RenderSingleTargetRotation(aoe)
  local stealth = FindBuff("player", "Stealth");

  if InMeleeRange() == false or stealth ~= nil then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if IsCastable("Adrenaline Rush", 0) then
    WowCyborg_CURRENTATTACK = "Adrenaline Rush";
    return SetSpellRequest(adrenalineRush);
  end

  if IsCastable("Roll the Bones", 25) then
    WowCyborg_CURRENTATTACK = "Roll the Bones";
    return SetSpellRequest(rollTheBones);
  end

  if aoe then
    if IsCastable("Blade Flurry", 15) then
      WowCyborg_CURRENTATTACK = "Blade Flurry";
      return SetSpellRequest(bladeFlurry);
    end
  end

  local points = GetComboPoints("player", "target");

  local sliceBuff, sliceDuration = FindBuff("Player", "Slice and Dice");

  if (points > 4) then
    local sliceBuff, sliceDuration = FindBuff("Player", "Slice and Dice");
    if sliceBuff == nil or sliceDuration < 9 then
      if IsCastable("Slice and Dice", 0) then
        WowCyborg_CURRENTATTACK = "Slice and Dice";
        return SetSpellRequest(sliceNDice);
      end
    end
    
    if IsCastableAtEnemyTarget("Between the Eyes", 0) then
      WowCyborg_CURRENTATTACK = "Between the Eyes";
      return SetSpellRequest(betweenTheEyes);
    end
    
    if IsCastableAtEnemyTarget("Dispatch", 0) then
      WowCyborg_CURRENTATTACK = "Dispatch";
      return SetSpellRequest(dispatch);
    end
  end

  if sliceBuff == nil and points > 0 then
    if IsCastable("Slice and Dice", 0) then
      WowCyborg_CURRENTATTACK = "Slice and Dice";
      return SetSpellRequest(sliceNDice);
    end
  end

  local oppBuff = FindBuff("Player", "Opportunity");
  if oppBuff ~= nil and IsCastableAtEnemyTarget("Pistol Shot", 0) then
    WowCyborg_CURRENTATTACK = "Pistol Shot";
    return SetSpellRequest(pistolShot);
  end

  if IsCastableAtEnemyTarget("Sinister Strike", 45) then
    WowCyborg_CURRENTATTACK = "Sinister Strike";
    return SetSpellRequest(sinisterStrike);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsCastableAtEnemyTarget("Dispatch", 0);
end

print("Rogue Outlaw rotation loaded");