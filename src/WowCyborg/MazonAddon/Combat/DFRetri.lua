--[[
  Button    Spell
]]--
local consecration = 1;
local bladeOfjustice = 2;
local judgment = 3;
local hammerOfwrath = 4;
local crusaderStrike = 5;
local templarsVerdict = 6;
local divineStorm = 7;
local wakeOfashes = 8;
local seraphim = 9;
local wog = "F+5";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "F4",
  "F5",
  "F7",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD5",
  "NUMPAD9",
  "0",
  "F",
  "R",
  "LSHIFT",
  "ESCAPE"
}

function IsMelee()
  return IsSpellInRange("Crusader Strike") == 1;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(aoe)
  local holyPower = UnitPower("player", 9);
  local hp = GetHealthPercentage("player");

  if hp < 50 and IsCastable("Word of Glory", 0) and holyPower > 2 then
    WowCyborg_CURRENTATTACK = "Word of Glory";
    return SetSpellRequest(wog);
  end

  if (IsMelee() and holyPower >= 5) then
    if (aoe == true) then
      if IsCastableAtEnemyTarget("Divine Storm", 0) then
        WowCyborg_CURRENTATTACK = "Divine Storm";
        return SetSpellRequest(divineStorm);
      end
    else
      if IsCastableAtEnemyTarget("Templar's Verdict", 0) then
        WowCyborg_CURRENTATTACK = "Templar's Verdict";
        return SetSpellRequest(templarsVerdict);
      end
    end
  end
  
  if (IsMelee() and holyPower <= 2 and IsCastableAtEnemyTarget("Wake of Ashes", 0)) then
    WowCyborg_CURRENTATTACK = "Wake of Ashes";
    return SetSpellRequest(wakeOfashes);
  end
  
  if (IsCastableAtEnemyTarget("Judgment", 0)) then
    WowCyborg_CURRENTATTACK = "Judgment";
    return SetSpellRequest(judgment);
  end
  
  if (IsCastableAtEnemyTarget("Hammer of Wrath", 0)) then
    WowCyborg_CURRENTATTACK = "Hammer of Wrath";
    return SetSpellRequest(hammerOfwrath);
  end
  
  if (holyPower <= 3 and IsCastableAtEnemyTarget("Blade of Justice", 0)) then
    WowCyborg_CURRENTATTACK = "Blade of Justice";
    return SetSpellRequest(bladeOfjustice);
  end

  local csCharges = GetSpellCharges("Crusader Strike");

  if (csCharges == 2 and IsCastableAtEnemyTarget("Crusader Strike", 0)) then
    WowCyborg_CURRENTATTACK = "Crusader Strike";
    return SetSpellRequest(crusaderStrike);
  end
 
  
  if (IsMelee() and holyPower >= 3) then
    if (aoe == true) then
      if IsCastableAtEnemyTarget("Divine Storm", 0) then
        WowCyborg_CURRENTATTACK = "Divine Storm";
        return SetSpellRequest(divineStorm);
      end
    else
      if IsCastableAtEnemyTarget("Templar's Verdict", 0) then
        WowCyborg_CURRENTATTACK = "Templar's Verdict";
        return SetSpellRequest(templarsVerdict);
      end
    end
  end
  
  if (IsMelee() and IsCastableAtEnemyTarget("Consecration", 0)) then
    WowCyborg_CURRENTATTACK = "Consecration";
    return SetSpellRequest(consecration);
  end

  if (IsCastableAtEnemyTarget("Crusader Strike", 0)) then
    WowCyborg_CURRENTATTACK = "Crusader Strike";
    return SetSpellRequest(crusaderStrike);
  end
  
  return SetSpellRequest(nil);
end

function IsMelee()
  return IsSpellInRange("Rebuke", "target") ~= 0;
end

print("Retri pala rotation loaded");