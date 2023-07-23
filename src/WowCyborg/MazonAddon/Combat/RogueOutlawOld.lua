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
local ambush = "2";
local betweenTheEyes = "3";
local sinisterStrike = "4";
local dispatch = "5";
local pistolShot = "6";
local bladeFlurry = "7";
local adrenalineRush = "8";
local flagellation = "9";
local bladeRush = "0";

WowCyborg_PAUSE_KEYS = {
  "F",
  "R",
  "LSHIFT",
  "F1",
  "F2",
  "F3",
  "F5",
  "F6",
  "F7",
  "F11",
  "NUMPAD1",
  "NUMPAD5",
  "NUMPAD9",
}
function RenderMultiTargetRotation()
  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if IsCastableAtEnemyTarget("Flagellation", 0) then
    WowCyborg_CURRENTATTACK = "Flagellation";
    return SetSpellRequest(flagellation);
  end

  return RenderSingleTargetRotation(true)
end

function RenderSingleTargetRotation(aoe)
  local stealth = FindBuff("player", "Stealth");

  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if stealth ~= nil then
    if IsCastableAtEnemyTarget("Ambush", 0) then
      WowCyborg_CURRENTATTACK = "Ambush";
      return SetSpellRequest(ambush);
    end

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
      
    if IsCastableAtEnemyTarget("Blade Rush", 0) then
      WowCyborg_CURRENTATTACK = "Blade Rush";
      return SetSpellRequest(bladeRush);
    end

  end

  local points = GetComboPoints("player", "target");
  local sliceBuff, sliceDuration = FindBuff("Player", "Slice and Dice");

  if (points > 4) then
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

  if IsCastableAtEnemyTarget("Sinister Strike", 50) then
    WowCyborg_CURRENTATTACK = "Sinister Strike";
    return SetSpellRequest(sinisterStrike);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Ambush", "target") == 1;
end

print("Rogue Outlaw rotation loaded");