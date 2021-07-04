--[[
  Button    Spell
  1         Frostbolt
  7         Frost Armor
]]--

local frostbolt = "1";
local fireBlast = "2";
local attack = "6";
local eat = "9";
local frostArmor = "SHIFT+1";
local arcaneIntellect = "SHIFT+2";

function IsMelee()
  return CheckInteractDistance("target", 5) and IsCastableAtEnemyTarget("Fireball", 0);
end

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

-- Single target
function RenderSingleTargetRotation()
  local hp = GetHealthPercentage("player");
  if WowCyborg_INCOMBAT == false then
    if hp < 80 and hp > 1 then
      WowCyborg_CURRENTATTACK = "eat";
      return SetSpellRequest(eat);
    end
  end

  local targetFaction = UnitFactionGroup("target");
  if targetFaction ~= nil then
    WowCyborg_CURRENTATTACK = "Player targetted";
    return SetSpellRequest(nil);
  end

  local armorBuff = FindBuff("player", "Frost Armor");
  if armorBuff == nil then
    if IsCastable("Frost Armor", 0) then
      WowCyborg_CURRENTATTACK = "Frost Armor";
      return SetSpellRequest(frostArmor);
    end  
  end
  
  local armorBuff = FindBuff("player", "Arcane Intellect");
  if armorBuff == nil then
    if IsCastable("Arcane Intellect", 0) then
      WowCyborg_CURRENTATTACK = "Arcane Intellect";
      return SetSpellRequest(arcaneIntellect);
    end  
  end

  if IsMelee() and WowCyborg_INCOMBAT then
    if IsCastableAtEnemyTarget("Fire Blast", 0) then
      WowCyborg_CURRENTATTACK = "Fire Blast";
      return SetSpellRequest(fireBlast);
    end
    
    if IsCurrentSpell(6603) == false then
      WowCyborg_CURRENTATTACK = "Attack";
      return SetSpellRequest(attack);
    end
  end

  if IsCastableAtEnemyTarget("Frostbolt", 0) then
    WowCyborg_CURRENTATTACK = "Frostbolt";
    return SetSpellRequest(frostbolt);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Classic mage rotation loaded!");