--[[p
  Button    Spell
  local rollTheBones = "1";
  local adrenalineRush = "2";
  local betweenTheEyes = "3";
  local sinisterStrike = "4";
  local dispatch = "5";
  local pistolShot = "6";
]]--

local shadowBlades = "1";
local sliceNDice = "2";
local shadowStrike = "4";
local rupture = "3";
local symbolsOfDeath = "5";
local shadowDance = "5";
local backstab = "6";
local coldBlood = "6";
local eviscerate = "7";
local serratedBoneSpike = "8";

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

function GetSdCooldown()
  local sdStart, sdDuration = GetSpellCooldown("Shadow Dance");
  local tl = sdStart + sdDuration - GetTime();
  if tl < 1 then
    return 0;
  end

  return tl;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true)
end

function RenderSingleTargetRotation()
  local stealth = FindBuff("player", "Stealth");
  local energy = (UnitPower("player") / UnitPowerMax("player")) * 100;
  local points = GetComboPoints("player", "target");
  local sliceBuff, sliceDuration = FindBuff("Player", "Slice and Dice");
  local ruptureDebuff, ruptureDuration = FindDebuff("target", "Rupture");

  local assasinsMark = FindBuff("Player", "Master Assassin's Mark");
  local shadowDanceBuff = FindBuff("Player", "Shadow Dance");
  if shadowDanceBuff ~= nil then
    if IsCastable("Shadow Blades", 0) then
      WowCyborg_CURRENTATTACK = "Shadow Blades";
      return SetSpellRequest(shadowBlades);
    end

    if IsCastable("Cold Blood", 0) then
      WowCyborg_CURRENTATTACK = "Cold Blood";
      return SetSpellRequest(coldBlood);
    end
    
    if IsCastable("Symbols of Death", 0) then
      WowCyborg_CURRENTATTACK = "Symbols of Death";
      return SetSpellRequest(symbolsOfDeath);
    end
      
    if (points > 5) then
      if IsCastableAtEnemyTarget("Eviscerate", 35) then
        WowCyborg_CURRENTATTACK = "Eviscerate";
        return SetSpellRequest(eviscerate);
      end
    end

    if IsCastableAtEnemyTarget("Shadowstrike", 0) then
      WowCyborg_CURRENTATTACK = "Shadowstrike";
      return SetSpellRequest(shadowStrike);
    end
    
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if stealth ~= nil then
    if IsCastable("Cold Blood", 0) then
      WowCyborg_CURRENTATTACK = "Cold Blood";
      return SetSpellRequest(coldBlood);
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if InMeleeRange() == false then
    if IsCastableAtEnemyTarget("Serrated Bone Spike", 15) then
      WowCyborg_CURRENTATTACK = "Serrated Bone Spike";
      return SetSpellRequest(serratedBoneSpike);
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if assasinsMark ~= nil then
    if IsCastable("Shadow Blades", 0) then
      WowCyborg_CURRENTATTACK = "Shadow Blades";
      return SetSpellRequest(shadowBlades);
    end
  end

  if (points > 4) then
    if sliceBuff == nil or sliceDuration < 9 then
      if IsCastable("Slice and Dice", 0) then
        WowCyborg_CURRENTATTACK = "Slice and Dice";
        return SetSpellRequest(sliceNDice);
      end
    end

    if ruptureDebuff == nil or ruptureDuration < 9 then
      if IsCastable("Rupture", 0) then
        WowCyborg_CURRENTATTACK = "Rupture";
        return SetSpellRequest(rupture);
      end
    end
  end

  local shadowDanceCd = GetSdCooldown();

  if IsCastable("Symbols of Death", 0) then
    if shadowDanceCd == 0 or shadowDanceCd > 30 then
      if energy >= 50 then
        WowCyborg_CURRENTATTACK = "Shadow Dance";
        return SetSpellRequest(shadowDance);
      end

      WowCyborg_CURRENTATTACK = "-";
      return SetSpellRequest(nil);
    end
  end

  if (points > 5) then
    if IsCastableAtEnemyTarget("Eviscerate", 35) then
      WowCyborg_CURRENTATTACK = "Eviscerate";
      return SetSpellRequest(eviscerate);
    end
  end

  if IsCastableAtEnemyTarget("Backstab", 35) then
    WowCyborg_CURRENTATTACK = "Backstab";
    return SetSpellRequest(backstab);
  end

  if IsCastableAtEnemyTarget("Serrated Bone Spike", 15) then
    WowCyborg_CURRENTATTACK = "Serrated Bone Spike";
    return SetSpellRequest(serratedBoneSpike);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Ambush", "target") == 1;
end

print("Rogue Outlaw rotation loaded");