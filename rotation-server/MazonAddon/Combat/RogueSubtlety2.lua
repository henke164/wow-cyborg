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
local eviscerate = "7";
local flagellation = "8";
local blackPowder = "9";
local shurikenStorm = "0";
local shurikenTornado = "F+6";

WowCyborg_PAUSE_KEYS = {
  "F",
  "R",
  "LSHIFT",
  "F1",
  "F2",
  "F3",
  "F5",
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

function RenderShadowDance(aoe)
  local sliceBuff, sliceDuration = FindBuff("Player", "Slice and Dice");
  local points = GetComboPoints("player", "target");

  if (points > 4) then
    if sliceBuff == nil or sliceDuration < 9 then
      if IsCastable("Slice and Dice", 0) then
        WowCyborg_CURRENTATTACK = "Slice and Dice";
        return SetSpellRequest(sliceNDice);
      end
    end
  end

  if IsCastableAtEnemyTarget("Flagellation", 0) then
    WowCyborg_CURRENTATTACK = "Flagellation";
    return SetSpellRequest(flagellation);
  end

  if IsCastable("Symbols of Death", 0) then
    WowCyborg_CURRENTATTACK = "Symbols of Death";
    return SetSpellRequest(symbolsOfDeath);
  end

  if IsCastable("Shadow Blades", 0) then
    WowCyborg_CURRENTATTACK = "Shadow Blades";
    return SetSpellRequest(shadowBlades);
  end

  if aoe == true and IsAoeRange() then
    if IsCastableAtEnemyTarget("Shuriken Tornado", 0) then
      WowCyborg_CURRENTATTACK = "Shuriken Tornado";
      return SetSpellRequest(shurikenTornado);
    end
  end

  if (points > 5) then
    if aoe == true and IsAoeRange() then
      if IsCastableAtEnemyTarget("Black Powder", 0) then
        WowCyborg_CURRENTATTACK = "Black Powder";
        return SetSpellRequest(blackPowder);
      end
    end

    if IsCastableAtEnemyTarget("Eviscerate", 0) then
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

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true)
end

function RenderSingleTargetRotation(aoe)
  local energy = (UnitPower("player") / UnitPowerMax("player")) * 100;
  local points = GetComboPoints("player", "target");
  local sliceBuff, sliceDuration = FindBuff("Player", "Slice and Dice");
  local ruptureDebuff, ruptureDuration = FindDebuff("target", "Rupture");
  local shadowDanceBuff = FindBuff("Player", "Shadow Dance");

  if shadowDanceBuff ~= nil and IsAoeRange() then
    return RenderShadowDance(aoe);
  end

  if (points > 4) then
    if sliceBuff == nil or sliceDuration < 9 then
      if IsCastable("Slice and Dice", 0) then
        WowCyborg_CURRENTATTACK = "Slice and Dice";
        return SetSpellRequest(sliceNDice);
      end
    end

    if aoe ~= true then
      if ruptureDebuff == nil or ruptureDuration < 9 then
        if IsCastable("Rupture", 0) then
          WowCyborg_CURRENTATTACK = "Rupture";
          return SetSpellRequest(rupture);
        end
      end
    end
  end

  local shadowDanceCd = GetSdCooldown();
  local sdStacks = GetSpellCharges("Shadow Dance");

  if InMeleeRange() and IsCastable("Symbols of Death", 0) then
    if sdStacks == 2 or shadowDanceCd == 0 or shadowDanceCd > 30 then
      if energy >= 50 then
        WowCyborg_CURRENTATTACK = "Shadow Dance";
        return SetSpellRequest(shadowDance);
      end

      WowCyborg_CURRENTATTACK = "-";
      return SetSpellRequest(nil);
    end
  end

  if (points > 5) then
    if aoe == true and IsAoeRange() then
      if IsCastableAtEnemyTarget("Black Powder", 35) then
        WowCyborg_CURRENTATTACK = "Black Powder";
        return SetSpellRequest(blackPowder);
      end
    else
      if IsCastableAtEnemyTarget("Eviscerate", 35) then
        WowCyborg_CURRENTATTACK = "Eviscerate";
        return SetSpellRequest(eviscerate);
      end
    end
  end

  if aoe == true and IsAoeRange() then
    if IsCastableAtEnemyTarget("Shuriken Storm", 0) then
      WowCyborg_CURRENTATTACK = "Shuriken Storm";
      return SetSpellRequest(shurikenStorm);
    end
  else
    if IsCastableAtEnemyTarget("Backstab", 35) then
      WowCyborg_CURRENTATTACK = "Backstab";
      return SetSpellRequest(backstab);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Backstab", "target") == 1;
end

function IsAoeRange()
  return CheckInteractDistance("target", 5);
end

print("Rogue Outlaw rotation loaded");