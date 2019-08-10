--[[
  Button    Spell
  1         Charge
  2         Rend
  3         Heroic strike
  4         Thunder Clap
  5         Battleshout
  6         Attack
]]--

local charge = "1";
local rend = "2";
local heroicStrike = "3";
local thunderClap = "4";
local battleshout = "5";
local attack = "6";


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

  local bsBuff = FindBuff("player", "Battle Shout");
  if bsBuff == nil and IsCastable("Battle Shout", 10) then
    WowCyborg_CURRENTATTACK = "Battle Shout";
    return SetSpellRequest(battleshout);
  end

  local rendDot = FindDebuff("target", "Rend");
  if rendDot == nil then
    if IsCastableAtEnemyTarget("Rend", 10) then
      WowCyborg_CURRENTATTACK = "Rend";
      return SetSpellRequest(rend);
    end
  end
  
  if IsCastableAtEnemyTarget("Thunder Clap", 15) then
    WowCyborg_CURRENTATTACK = "Thunder Clap";
    return SetSpellRequest(thunderClap);
  end

  if IsCastableAtEnemyTarget("Heroic Strike", 15) then
    WowCyborg_CURRENTATTACK = "Heroic Strike";
    return SetSpellRequest(heroicStrike);
  end
  
  if IsCastableAtEnemyTarget("Heroic Strike", 0) then
    if IsCurrentSpell(6603) == false then
      WowCyborg_CURRENTATTACK = "Attack";
      return SetSpellRequest(attack);
    end
    
    if IsCastableAtEnemyTarget("Heroic Strike", 0) then
      WowCyborg_CURRENTATTACK = "Thunder Clap";
      return SetSpellRequest(thunderClap);
    end  
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Classic warrior rotation loaded!");