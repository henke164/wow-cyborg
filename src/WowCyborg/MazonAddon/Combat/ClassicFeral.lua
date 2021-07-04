--[[
  Button    Spell
  1         Claw
  6         Attack
]]--

local faerieFire = "1";
local regrowth = "2";

local rake = "2";
local claw = "3";
local rip = "4";
local tigersFury = "5";
local attack = "6";

local toggleBear = "SHIFT+1";
local toggleCat = "SHIFT+3";
local thorns = "7";
local motw = "8";
local eat = "9";

function IsMelee()
  return CheckInteractDistance("target", 5);
end

function IsCat()
  local _, active = GetShapeshiftFormInfo(2)
  return active;
end

function IsBear()
  local _, active = GetShapeshiftFormInfo(1)
  return active;
end

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

-- Single target
function RenderSingleTargetRotation()
  local targetFaction = UnitFactionGroup("target");
  if targetFaction ~= nil then
    WowCyborg_CURRENTATTACK = "Player targetted";
    return SetSpellRequest(nil);
  end
  
  local mana = (UnitPower("player") / UnitPowerMax("player")) * 100;
  local hp = GetHealthPercentage("player");
  local shape = "CASTER";

  if hp > 1 then
    if IsCat() then
      shape = "CAT";
    elseif IsBear() then
      shape = "BEAR";
    end
  else
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if WowCyborg_INCOMBAT == false then
    if shape == "CAT" or shape == "BEAR" then
      WowCyborg_CURRENTATTACK = "Casterform";
      return SetSpellRequest(toggleCat);
    end
      
    local motwBuff = FindBuff("player", "Mark of the Wild");
    if motwBuff == nil then
      if IsCastable("Mark of the Wild", 20) then
        WowCyborg_CURRENTATTACK = "Mark of the Wild";
        return SetSpellRequest(motw);
      end
    end

    local thornsBuff = FindBuff("player", "Thorns");
    if thornsBuff == nil then
      if IsCastable("Thorns", 60) then
        WowCyborg_CURRENTATTACK = "Thorns";
        return SetSpellRequest(thorns);
      end
    end
  
    if IsCastableAtEnemyTarget("Moonfire", 55) then
      WowCyborg_CURRENTATTACK = "Faerie Fire";
      return SetSpellRequest(faerieFire);
    end

    if hp < 80 or mana < 50 then
      WowCyborg_CURRENTATTACK = "Rest";
      return SetSpellRequest(eat);
    end
    
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  else
    if shape == "CASTER" then
      WowCyborg_CURRENTATTACK = "Catform";
      --return SetSpellRequest(toggleCat);
    end

    
    if hp < 50 then
      WowCyborg_CURRENTATTACK = "Regrowth";
      return SetSpellRequest(regrowth);
    end
    

    if IsCastableAtEnemyTarget("Attack", 0) and IsCurrentSpell(6603) == false then
      WowCyborg_CURRENTATTACK = "Attack";
      return SetSpellRequest(attack);
    end

    if IsMelee() and IsCastableAtEnemyTarget("Attack", 0) and IsCurrentSpell(6603) == false then
      WowCyborg_CURRENTATTACK = "Attack";
      return SetSpellRequest(attack);
    end
  
    local points = GetComboPoints("player", "target");

    local tigerBuff = FindBuff("player", "Tiger's Fury");
    if tigerBuff == nil then
      WowCyborg_CURRENTATTACK = "Tiger's Fury";
      return SetSpellRequest(tigersFury);
    end

    if points > 1 then
      if IsCastableAtEnemyTarget("Rip", 0) then
        WowCyborg_CURRENTATTACK = "Rip";
        return SetSpellRequest(rip);
      end
    end

    local rakeDebuff = FindDebuff("target", "Rake");
    if rakeDebuff == nil then
      if IsCastableAtEnemyTarget("Rake", 0) then
        WowCyborg_CURRENTATTACK = "Rake";
        return SetSpellRequest(rake);
      end
    end

<<<<<<< HEAD
    if IsMelee() then
      WowCyborg_CURRENTATTACK = "Claw";
      return SetSpellRequest(claw);
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
=======
    --if IsCastableAtEnemyTarget("Claw", 0) then
      WowCyborg_CURRENTATTACK = "Claw";
      return SetSpellRequest(claw);
    --end
>>>>>>> b7b6ecd464949b37c4a941f4bb784c6febfb99d8
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Classic feral rotation loaded!");