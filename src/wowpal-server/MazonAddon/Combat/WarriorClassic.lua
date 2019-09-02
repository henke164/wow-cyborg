--[[
  Button    Spell
  1         Charge
  2         Rend
  3         Heroic strike
  4         Overpower
  5         Battleshout
  6         Attack
]]--

local charge = "1";
local rend = "2";
local heroicStrike = "3";
local overpower = "4";
local battleshout = "5";
local attack = "6";
local bloodrage = "7";
local execute = "8";
local eat = "9";

function IsMelee()
  return IsSpellInRange("Rend", "target") == 1;
end

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

-- Single target
function RenderSingleTargetRotation()
  local hp = GetHealthPercentage("player");

  if IsCastableAtEnemyTarget("Charge", 0) then
    WowCyborg_CURRENTATTACK = "Charge";
    return SetSpellRequest(charge);
  end

  if IsMelee() ~= true then
    if hp < 80 and hp > 1 then
      WowCyborg_CURRENTATTACK = "eat";
      return SetSpellRequest(eat);
    end
    
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local bsBuff = FindBuff("player", "Battle Shout");
  if bsBuff == nil and IsCastable("Battle Shout", 10) then
    WowCyborg_CURRENTATTACK = "Battle Shout";
    return SetSpellRequest(battleshout);
  end

  if hp > 50 then
    if IsCastable("Bloodrage", 0) then
      WowCyborg_CURRENTATTACK = "Bloodrage";
      return SetSpellRequest(bloodrage);
    end
  end

  local opBuff = IsUsableSpell("Execute");
  if opBuff == true then
    if IsCastableAtEnemyTarget("Execute", 15) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end
  end

  local opBuff = IsUsableSpell("Overpower");
  if opBuff == true then
    if IsCastableAtEnemyTarget("Overpower", 5) then
      WowCyborg_CURRENTATTACK = "Overpower";
      return SetSpellRequest(overpower);
    end
  end

  local rendDot = FindDebuff("target", "Rend");
  if rendDot == nil then
    if IsCastableAtEnemyTarget("Rend", 10) then
      WowCyborg_CURRENTATTACK = "Rend";
      return SetSpellRequest(rend);
    end
  end

  if IsCastableAtEnemyTarget("Heroic Strike", 15) then
    WowCyborg_CURRENTATTACK = "Heroic Strike";
    return SetSpellRequest(heroicStrike);
  end

  if IsCurrentSpell(6603) == false then
    WowCyborg_CURRENTATTACK = "Attack";
    return SetSpellRequest(attack);
  end
  
  if IsMelee() then
    WowCyborg_CURRENTATTACK = "Heroic Strike";
    return SetSpellRequest(heroicStrike);
  end
end

print("Classic warrior rotation loaded!");