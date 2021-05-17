--[[
  Button    Spell
]]--

local wakeOfAshes = 1;
local bladeOfJustice = 2;
local judgment = 3;
local hammerOfWrath = 4;
local crusaderStrike = 5;
local templarsVeridict = 6;
local divineStorm = 7;
local divineToll = 8;
local seraphim = 9;


WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "F5",
  "F7",
  "0",
  "F",
  "R",
  "LSHIFT",
  "ESCAPE",
  "NUMPAD5"
}

function IsMelee()
  return IsSpellInRange("Crusader Strike") == 1;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(aoe)
  local saveForSeraphim = false;
  local holyPower = UnitPower("player", 9);
  local epowerBuff = FindBuff("player", "Empyrean Power");
  local wrathBuff = FindBuff("player", "Avenging Wrath");
  local awCd = GetSpellCooldown("Avenging Wrath", "spell");

  if wrathBuff ~= nil or awCd > 45 then

    if IsCastable("Seraphim", 0) then
      saveForSeraphim = true
      if holyPower > 2 then
        WowCyborg_CURRENTATTACK = "Seraphim";
        return SetSpellRequest(seraphim);
      end
    end

    local seraphimBuff = FindBuff("player", "Seraphim");
    if seraphimBuff ~= nil and IsCastableAtEnemyTarget("Divine Toll", 0) then
      WowCyborg_CURRENTATTACK = "Divine Toll";
      return SetSpellRequest(divineToll);
    end
  end

  if epowerBuff ~= nil then
    if IsCastableAtEnemyTarget("Divine Storm", 0) then
      WowCyborg_CURRENTATTACK = "Divine Storm";
      return SetSpellRequest(divineStorm);
    end
  end
  
  local hp = GetHealthPercentage("player");
  if hp < 75 then
    if (holyPower > 2) then
      WowCyborg_CURRENTATTACK = "Word of Glory";
      return SetSpellRequest("CTRL+1");
    end
  end

  if holyPower >= 3 and saveForSeraphim == false then
    if aoe == nil then
      if IsCastableAtEnemyTarget("Templar's Verdict", 0) then
        WowCyborg_CURRENTATTACK = "Templar's Verdict";
        return SetSpellRequest(templarsVeridict);
      end
    elseif aoe ~= nil and aoe == true then
      if IsCastableAtEnemyTarget("Divine Storm", 0) then
        WowCyborg_CURRENTATTACK = "Divine Storm";
        return SetSpellRequest(divineStorm);
      end
    end
  end

  if IsMelee() and IsCastableAtEnemyTarget("Wake of Ashes", 0) then
    WowCyborg_CURRENTATTACK = "Wake of Ashes";
    return SetSpellRequest(wakeOfAshes);
  end
  
  if IsCastableAtEnemyTarget("Blade of Justice", 0) then
    WowCyborg_CURRENTATTACK = "Blade of Justice";
    return SetSpellRequest(bladeOfJustice);
  end
  
  if IsCastableAtEnemyTarget("Judgment", 0) then
    WowCyborg_CURRENTATTACK = "Judgment";
    return SetSpellRequest(judgment);
  end
  
  if IsCastableAtEnemyTarget("Hammer of Wrath", 0) then
    WowCyborg_CURRENTATTACK = "Hammer of Wrath";
    return SetSpellRequest(hammerOfWrath);
  end
  
  if IsCastableAtEnemyTarget("Crusader Strike", 0) then
    WowCyborg_CURRENTATTACK = "Crusader Strike";
    return SetSpellRequest(crusaderStrike);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Retri pala rotation loaded");