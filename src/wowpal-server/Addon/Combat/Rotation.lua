--[[
  Button    Spell
  1         Charge
  2         Rend
  3         Heroic strike
  4         Battleshout
]]--

local charge = "1";
local rend = "2";
local heroicStrike = "3";
local battleshout = "4";


-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

-- Single target
function RenderSingleTargetRotation()
  if IsCastableAtEnemyTarget("Charge", 0) then
    WowCyborg_CURRENTATTACK = "Charge";
    return SetSpellRequest(charge);
  end

  local rendDot = FindDebuff("target", "Rend");
  if rendDot == nil then
    if IsCastableAtEnemyTarget("Rend", 10) then
      WowCyborg_CURRENTATTACK = "Rend";
      return SetSpellRequest(rend);
    end
  end
  
  local bsBuff = FindBuff("player", "Battle Shout");
  if bsBuff == nil and IsCastable("Battle Shout", 10) then
    WowCyborg_CURRENTATTACK = "Battle Shout";
    return SetSpellRequest(battleshout);
  end

  if IsCastableAtEnemyTarget("Heroic Strike", 15) then
    WowCyborg_CURRENTATTACK = "Heroic Strike";
    return SetSpellRequest(heroicStrike);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Test rotation loaded");