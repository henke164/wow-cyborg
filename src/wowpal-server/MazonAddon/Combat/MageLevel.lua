--[[
]]--

local blast = 1;
local barrage = 2;
local explosion = 3;
local fire = 4;

function IsMelee()
  return CheckInteractDistance("target", 3);
end

-- Multi target
function RenderMultiTargetRotation()
  if IsMelee() then
    if IsCastableAtEnemyTarget("Arcane Explosion", 0) then
      WowCyborg_CURRENTATTACK = "Arcane Explosion";
      return SetSpellRequest(explosion);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

-- Single target
function RenderSingleTargetRotation(aoe)
  local speed = GetUnitSpeed("player");

  if IsCastableAtEnemyTarget("Arcane Barrage", 0) then
    WowCyborg_CURRENTATTACK = "Arcane Barrage";
    return SetSpellRequest(barrage);
  end
    
  if IsCastableAtEnemyTarget("Fire Blast", 0) then
    WowCyborg_CURRENTATTACK = "Fire Blast";
    return SetSpellRequest(fire);
  end
    
  if IsMelee() then
    if IsCastableAtEnemyTarget("Arcane Explosion", 0) then
      WowCyborg_CURRENTATTACK = "Arcane Explosion";
      return SetSpellRequest(explosion);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Leveling mage rotation loaded");