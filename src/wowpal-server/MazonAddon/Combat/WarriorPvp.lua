--[[
  Button    Spell
  1         Hamstring
  2         Slam
  3         Execute
  4         Mortal Strike
  5         Overpower
]]--

local hamstring = "1";
local slam = "2";
local execute = "3";
local mortalStrike = "4";
local overpower = "5";
local bladestorm = "6";
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

function RenderMultiTargetRotation()
  if IsCastable("Sharpen Blade", 0) then
    WowCyborg_CURRENTATTACK = "Sharpen Blade";
    return SetSpellRequest("0");
  end
  
  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local hamstringDebuff, hamstringTimeLeft = FindDebuff("target", "Hamstring");
  if hamstringDebuff == nil or hamstringTimeLeft < 3 then
    if IsCastableAtEnemyTarget("Hamstring", 10) then
      WowCyborg_CURRENTATTACK = "Hamstring";
      return SetSpellRequest(hamstring);
    end
  end

  return RenderSingleTargetRotation()
end

function RenderSingleTargetRotation()
  local deadlyCalm = FindBuff("player", "Deadly Calm");
  if deadlyCalm ~= nil then
    if IsCastableAtEnemyTarget("Execute", 0) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end
  end

  if IsCastableAtEnemyTarget("Execute", 20) then
    WowCyborg_CURRENTATTACK = "Execute";
    return SetSpellRequest(execute);
  end

  if IsCastable("Sharpen Blade", 0) then
    WowCyborg_CURRENTATTACK = "Sharpen Blade";
    return SetSpellRequest("0");
  end

  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local hp = GetHealthPercentage("player");
  if hp < 50 then
    if IsCastable("Ignore Pain", 40) then
      WowCyborg_CURRENTATTACK = "Ignore Pain";
      return SetSpellRequest(ignorePain);
    end
  end

  local rendDot = FindDebuff("target", "Rend");
  if rendDot == nil then
    if IsCastableAtEnemyTarget("Rend", 30) then
      WowCyborg_CURRENTATTACK = "Rend";
      return SetSpellRequest(rend);
    end
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
  if rage > 40 then
    if IsCastableAtEnemyTarget("Slam", 20) then
      WowCyborg_CURRENTATTACK = "Slam";
      return SetSpellRequest(slam);
    end
  end

  if IsCastableAtEnemyTarget("Execute", 20) then
    WowCyborg_CURRENTATTACK = "Execute";
    return SetSpellRequest(execute);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Execute", "target") == 1;
end

print("Arms warrior rotation loaded");