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
local bloodrage = "7";

local armsStance = "SHIFT+1";
local defensiveStance = "SHIFT+2";
local eat = "9";

function IsMelee()
  return IsSpellInRange("Rend", "target") == 1;
end

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

function isArmsStance()
  local _, boolean = GetShapeshiftFormInfo(1);
  return boolean;
end

function isDefensiveStance()
  local _, boolean = GetShapeshiftFormInfo(2);
  return boolean;
end

-- Single target
function RenderSingleTargetRotation()
  if (WowCyborg_INCOMBAT == false and isDefensiveStance()) then
    WowCyborg_CURRENTATTACK = "Arms";
    return SetSpellRequest(armsStance);
  end
  
  local hp = GetHealthPercentage("player");

  if IsCastableAtEnemyTarget("Charge", 0) then
    WowCyborg_CURRENTATTACK = "Charge";
    return SetSpellRequest(charge);
  end

  if IsMelee() ~= true then
    if hp < 80 then
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
  
  local rendDot = FindDebuff("target", "Rend");
  if rendDot == nil then
    if IsCastableAtEnemyTarget("Rend", 10) then
      WowCyborg_CURRENTATTACK = "Rend";
      return SetSpellRequest(rend);
    end
  end
  
  local tcDebuff = FindDebuff("target", "Thunder Clap");
  if tcDebuff ~= nil then
    if IsCastableAtEnemyTarget("Heroic Strike", 15) then
      WowCyborg_CURRENTATTACK = "Heroic Strike";
      return SetSpellRequest(heroicStrike);
    end
  end

  if IsCastableAtEnemyTarget("Thunder Clap", 15) then
    WowCyborg_CURRENTATTACK = "Thunder Clap";
    return SetSpellRequest(thunderClap);
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