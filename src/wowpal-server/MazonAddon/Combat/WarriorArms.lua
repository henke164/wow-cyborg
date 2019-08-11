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

function RenderMultiTargetRotation(texture)
  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation(texture)
  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local hamstringDebuff, hamstringTimeLeft = FindDebuff("target", "Hamstring");
  --if hamstringDebuff == nil or hamstringTimeLeft < 3 then
  --  if IsCastableAtEnemyTarget("Hamstring", 10) then
  --    WowCyborg_CURRENTATTACK = "Hamstring";
  --    return SetSpellRequest(hamstring);
  --  end
  --end

  local caBuff = FindBuff("player", "Crushing Assault");
  if caBuff ~= nil then
    if IsCastableAtEnemyTarget("Slam", 20) then
      WowCyborg_CURRENTATTACK = "Slam";
      return SetSpellRequest(slam);
    end
  end
  
  local sdBuff = FindBuff("player", "Sudden Death");
  if sdBuff ~= nil then
    if IsCastableAtEnemyTarget("Execute", 20) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
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

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Execute", "target") == 1;
end

print("Arms warrior rotation loaded");