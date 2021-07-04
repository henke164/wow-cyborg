--[[p
  Button    Spell
  local garrote = "1";
  local sliceNDice = "2";
  local rupture = "3";
  local vendetta = "4";
  local bonespike = "5";
  local envenom = "6";
  local mutilate = "7";
  local fanOfKnives = "8";
  local shiv = "9";
]]--

local garrote = "1";
local sliceNDice = "2";
local ambush = "2";
local rupture = "3";
local vendetta = "4";
local bonespike = "5";
local envenom = "6";
local mutilate = "7";
local fanOfKnives = "8";
local shiv = "9";
local mfd = "0";

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
  local stealth = FindBuff("player", "Stealth");
  local points = GetComboPoints("player", "target");

  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if FindBuff("player", "Subterfuge") ~= nil or stealth ~= nil then
    local garroteDebuff = FindDebuff("target", "Garrote");
    if garroteDebuff == nil and IsCastableAtEnemyTarget("Garrote", 0) then
      WowCyborg_CURRENTATTACK = "Garrote";
      return SetSpellRequest(garrote);
    end
    
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if (points > 4) then
    local ruptureDebuff, ruptureDuration = FindDebuff("target", "Rupture");
    if ruptureDebuff == nil or ruptureDuration < 5 then
      if IsCastableAtEnemyTarget("Rupture", 0) then
        WowCyborg_CURRENTATTACK = "Rupture";
        return SetSpellRequest(rupture);
      end
    end

    local sliceBuff, sliceDuration = FindBuff("Player", "Slice and Dice");
    if sliceBuff == nil then
      if IsCastable("Slice and Dice", 0) then
        WowCyborg_CURRENTATTACK = "Slice and Dice";
        return SetSpellRequest(sliceNDice);
      end
    end
    
    if IsCastableAtEnemyTarget("Envenom", 20) then
      WowCyborg_CURRENTATTACK = "Envenom";
      return SetSpellRequest(envenom);
    end
  end

  if points == 0 then
    if IsCastableAtEnemyTarget("Marked for Death", 0) then
      WowCyborg_CURRENTATTACK = "Marked for Death";
      return SetSpellRequest(mfd);
    end
  end

  local boneSpikeDebuff = FindDebuff("target", "Serrated Bone Spike");
  if boneSpikeDebuff == nil and IsCastableAtEnemyTarget("Serrated Bone Spike", 15) then
    WowCyborg_CURRENTATTACK = "Serrated Bone Spike";
    return SetSpellRequest(bonespike);
  end

  if IsCastableAtEnemyTarget("Fan of Knives", 35) then
    WowCyborg_CURRENTATTACK = "Fan of Knives";
    return SetSpellRequest(fanOfKnives);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  local stealth = FindBuff("player", "Stealth");
  local points = GetComboPoints("player", "target");

  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if FindBuff("player", "Subterfuge") ~= nil or stealth ~= nil then
    if IsCastableAtEnemyTarget("Ambush", 0) then
      WowCyborg_CURRENTATTACK = "Ambush";
      return SetSpellRequest(ambush);
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local sliceBuff, sliceDuration = FindBuff("Player", "Slice and Dice");

  if (points > 4) then
    if sliceBuff == nil then
      if IsCastable("Slice and Dice", 0) then
        WowCyborg_CURRENTATTACK = "Slice and Dice";
        return SetSpellRequest(sliceNDice);
      end
    end

    local ruptureDebuff, ruptureDuration = FindDebuff("target", "Rupture");
    if ruptureDebuff == nil or ruptureDuration < 5 then
      if IsCastableAtEnemyTarget("Rupture", 0) then
        WowCyborg_CURRENTATTACK = "Rupture";
        return SetSpellRequest(rupture);
      end
    end
    
    if sliceBuff == nil or sliceDuration < 9 then
      if IsCastable("Slice and Dice", 0) then
        WowCyborg_CURRENTATTACK = "Slice and Dice";
        return SetSpellRequest(sliceNDice);
      end
    end
  end
  
  if sliceBuff == nil and points > 0 then
    if IsCastable("Slice and Dice", 0) then
      WowCyborg_CURRENTATTACK = "Slice and Dice";
      return SetSpellRequest(sliceNDice);
    end
  end

  local garroteDebuff = FindDebuff("target", "Garrote");
  if garroteDebuff == nil and IsCastableAtEnemyTarget("Garrote", 45) then
    WowCyborg_CURRENTATTACK = "Garrote";
    return SetSpellRequest(garrote);
  end
  
  if IsCastableAtEnemyTarget("Vendetta", 0) then
    WowCyborg_CURRENTATTACK = "Vendetta";
    return SetSpellRequest(vendetta);
  end
  
  if IsCastableAtEnemyTarget("Serrated Bone Spike", 15) then
    WowCyborg_CURRENTATTACK = "Serrated Bone Spike";
    return SetSpellRequest(bonespike);
  end
  
  if IsCastableAtEnemyTarget("Shiv", 20) then
    WowCyborg_CURRENTATTACK = "Shiv";
    return SetSpellRequest(shiv);
  end
  
  if (points > 3) then
    if IsCastableAtEnemyTarget("Envenom", 20) then
      WowCyborg_CURRENTATTACK = "Envenom";
      return SetSpellRequest(envenom);
    end
  end

  if points < 5 and IsCastableAtEnemyTarget("Mutilate", 50) then
    WowCyborg_CURRENTATTACK = "Mutilate";
    return SetSpellRequest(mutilate);
  end

  if points == 0 then
    if IsCastableAtEnemyTarget("Marked for Death", 0) then
      WowCyborg_CURRENTATTACK = "Marked for Death";
      return SetSpellRequest(mfd);
    end
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Garrote", 0);
end

print("Rogue Assasination rotation loaded");