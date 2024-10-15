--[[
  Button    Spell
  local hamstring = "1";
  local bladestorm = "2";
  local execute = "3";
  local mortalStrike = "4";
  local overpower = "5";
  local ignorePain = "9";
]]--

local nextSwing = 0;

local hamstring = "1";
local bladestorm = "2";
local execute = "3";
local mortalStrike = "4";
local overpower = "5";
local sweepingStrikes = "8";
local ignorePain = "9";

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
  "NUMPAD5",
  "NUMPAD9",
}

function RenderMultiTargetRotation()
  if IsCastableAtEnemyTarget("Execute", 20) then
    WowCyborg_CURRENTATTACK = "Execute";
    return SetSpellRequest(execute);
  end

  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local freedomBuff = FindBuff("target", "Blessing of Freedom");
  local hamstringDebuff, hamstringTimeLeft = FindDebuff("target", "Hamstring");
  if freedomBuff == nil then
    if hamstringDebuff == nil or hamstringTimeLeft < 3 then
      if IsCastableAtEnemyTarget("Hamstring", 10) then
        WowCyborg_CURRENTATTACK = "Hamstring";
        return SetSpellRequest(hamstring);
      end
    end
  end

  return RenderSingleTargetRotation()
end

function RenderNormalRotation()
  if InMeleeRange() == false then
    local sdBuff = FindBuff("player", "Sudden Death");
    if sdBuff ~= nil and IsCastableAtEnemyTarget("Execute", 0) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local hpp = GetHealthPercentage("target")
  if tostring(hpp) ~= "-nan(ind)" and hpp > 0 and hpp < 60 then
    if IsCastable("Sharpen Blade", 0) then
      WowCyborg_CURRENTATTACK = "Sharpen Blade";
      return SetSpellRequest("0");
    end
  end

  local nearbyEnemies = GetNearbyEnemyCount();
  local ssStart, ssDuration = GetSpellCooldown("Sweeping Strikes");
  local ssCdLeft = ssStart + ssDuration - GetTime();
  if nearbyEnemies > 1 and ssCdLeft < 1 then
    WowCyborg_CURRENTATTACK = "Sweeping strikes";
    return SetSpellRequest(sweepingStrikes);
  end

  if IsCastableAtEnemyTarget("Mortal Strike", 30) then
    WowCyborg_CURRENTATTACK = "Mortal Strike";
    return SetSpellRequest(mortalStrike);
  end

  local sdBuff = FindBuff("player", "Sudden Death");
  if sdBuff ~= nil then
    if IsCastableAtEnemyTarget("Execute", 0) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end
  end
  
  local colossusDebuff = FindDebuff("target", "Colossus Smash");
  if colossusDebuff ~= nil and IsCastableAtEnemyTarget("Bladestorm", 0) then
    WowCyborg_CURRENTATTACK = "Bladestorm";
    return SetSpellRequest(bladestorm);
  end
  
  local ignorePainBuff = FindBuff("player", "Ignore Pain");
  local hp = GetHealthPercentage("player");
  if hp < 40 and ignorePainBuff == nil then
    if IsCastable("Ignore Pain", 40) then
      WowCyborg_CURRENTATTACK = "Ignore Pain";
      return SetSpellRequest(ignorePain);
    end
  end

  if IsCastableAtEnemyTarget("Overpower", 0) then
    WowCyborg_CURRENTATTACK = "Overpower";
    return SetSpellRequest(overpower);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderCondemnRotation()
  if InMeleeRange() == false then
    local sdBuff = FindBuff("player", "Sudden Death");
    local condemnCost = 40;
    if sdBuff ~= nil then
      condemnCost = 0;
    end

    if IsCastableAtEnemyTarget("Execute", condemnCost) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local swingTl = nextSwing - GetTime();
  local mw, mwTl = FindDebuff("target", "Mortal Wounds");
  local saveRage = false;
  
  if mw ~= nil then
    saveRage = swingTl > mwTl;
  end

  if mw == nil or mwTl < UnitAttackSpeed("player") then
    local overpowerBuff, opTl, opstacks = FindBuff("player", "Overpower");
    local exploiterDebuff, exTl, exstacks = FindDebuff("target", "Exploiter");

    if overpowerBuff ~= nil and exploiterDebuff ~= nil and opstacks == 2 and exstacks == 2 then
      if IsCastable("Sharpen Blade", 0) then
        WowCyborg_CURRENTATTACK = "Sharpen Blade";
        return SetSpellRequest("0");
      end
    end
  end

  if IsCastableAtEnemyTarget("Mortal Strike", 30) then
    WowCyborg_CURRENTATTACK = "Mortal Strike";
    return SetSpellRequest(mortalStrike);
  end
  
  local sdBuff = FindBuff("player", "Sudden Death");
  if sdBuff ~= nil then
    if IsCastableAtEnemyTarget("Execute", 0) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end
  end
  
  local colossusDebuff = FindDebuff("target", "Colossus Smash");
  if colossusDebuff ~= nil and IsCastableAtEnemyTarget("Bladestorm", 0) then
    WowCyborg_CURRENTATTACK = "Bladestorm";
    return SetSpellRequest(bladestorm);
  end
  
  local ignorePainBuff = FindBuff("player", "Ignore Pain");
  local hp = GetHealthPercentage("player");
  if hp < 40 and ignorePainBuff == nil then
    if IsCastable("Ignore Pain", 40) then
      WowCyborg_CURRENTATTACK = "Ignore Pain";
      return SetSpellRequest(ignorePain);
    end
  end

  if saveRage == false then
    if IsCastableAtEnemyTarget("Execute", 20) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end
  end

  if IsCastableAtEnemyTarget("Overpower", 0) then
    WowCyborg_CURRENTATTACK = "Overpower";
    return SetSpellRequest(overpower);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  local thornsBuff = FindBuff("target", "Thorns");

  if thornsBuff ~= nil then
    print("THORNS!");
    WowCyborg_CURRENTATTACK = "THORNS!";
    return SetSpellRequest(nil);
  end

  local targetHp = GetHealthPercentage("target");
  if (targetHp > 0 and targetHp < 35) or targetHp > 80 then
    return RenderCondemnRotation();
  end

  return RenderNormalRotation();
end

function InMeleeRange()
  return IsSpellInRange("Overpower", "target") == 1;
end

function CreateSwingTimer()
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

  frame:SetScript("OnEvent", function()
    local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, amountDetails = CombatLogGetCurrentEventInfo()

    if sourceGUID ~= UnitGUID("player") then
      return;
    end
    
    if type == "SWING_DAMAGE" then
      local attackSpeed = UnitAttackSpeed("player");
      nextSwing = GetTime() + attackSpeed;
    end
  end)
end

CreateSwingTimer();
print("Condemn rotation loaded");