--[[
  Button    Spell
  1         Hamstring
  2         Slam
  3         Execute
  4         Mortal Strike
  5         Overpower
]]--

local hamstring = "1";
local bladestorm = "2";
local execute = "3";
local mortalStrike = "4";
local overpower = "5";
local slam = "6";
local rend = "7";
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

function RenderRangedRotation()
  local sdBuff = FindBuff("player", "Sudden Death");
  if sdBuff ~= nil then
    if IsCastableAtEnemyTarget("Execute", 0) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end
  end

  if IsCastableAtEnemyTarget("Execute", 70) then
    WowCyborg_CURRENTATTACK = "Execute";
    return SetSpellRequest(execute);
  end
  
  if IsCastableAtEnemyTarget("Heroic Throw", 0) then
    WowCyborg_CURRENTATTACK = "Heroic Throw";
    return SetSpellRequest(rend);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderMultiTargetRotation()
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

function RenderSingleTargetRotation()
  local thornsBuff = FindBuff("target", "Thorns");

  if thornsBuff ~= nil then
    print("THORNS!");
    WowCyborg_CURRENTATTACK = "THORNS!";
    return SetSpellRequest(nil);
  end

  if InMeleeRange() == false then
    return RenderRangedRotation();
  end

  if IsCastableAtEnemyTarget("Mortal Strike", 0) then
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

  if IsCastableAtEnemyTarget("Execute", 70) then
    WowCyborg_CURRENTATTACK = "Execute";
    return SetSpellRequest(execute);
  end

  local hpp = GetHealthPercentage("target");

  if tostring(hpp) ~= "-nan(ind)" and hpp > 0 and hpp < 50 then
    if IsCastable("Sharpen Blade", 0) then
      WowCyborg_CURRENTATTACK = "Sharpen Blade";
      return SetSpellRequest("0");
    end
  end

  local ignorePainBuff = FindBuff("player", "Ignore Pain");
  local hp = GetHealthPercentage("player");
  if hp < 40 and ignorePainBuff == nil then
    if IsCastable("Ignore Pain", 70) then
      WowCyborg_CURRENTATTACK = "Ignore Pain";
      return SetSpellRequest(ignorePain);
    end
  end

  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local rendDot = FindDebuff("target", "Rend");
  if rendDot == nil then
    if IsCastableAtEnemyTarget("Rend", 30) then
      WowCyborg_CURRENTATTACK = "Rend";
      return SetSpellRequest(rend);
    end
  end

  local colossusDebuff = FindDebuff("target", "Colossus Smash");
  if colossusDebuff ~= nil and IsCastableAtEnemyTarget("Bladestorm", 0) then
    WowCyborg_CURRENTATTACK = "Bladestorm";
    return SetSpellRequest(bladestorm);
  end
  
  local caBuff = FindBuff("player", "Crushing Assault");
  if caBuff ~= nil then
    if IsCastableAtEnemyTarget("Slam", 20) then
      WowCyborg_CURRENTATTACK = "Slam";
      return SetSpellRequest(slam);
    end
  end
  
  if IsCastableAtEnemyTarget("Mortal Strike", 30) then
    WowCyborg_CURRENTATTACK = "Mortal Strike";
    return SetSpellRequest(mortalStrike);
  end

  if IsCastableAtEnemyTarget("Overpower", 0) then
    WowCyborg_CURRENTATTACK = "Overpower";
    return SetSpellRequest(overpower);
  end

  local rage = UnitPower("player");
  if rage > 80 then
    if IsCastableAtEnemyTarget("Slam", 20) then
      WowCyborg_CURRENTATTACK = "Slam";
      return SetSpellRequest(slam);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Overpower", "target") == 1;
end

print("Arms warrior rotation loaded");