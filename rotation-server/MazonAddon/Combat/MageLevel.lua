--[[
]]--

local blast = 1;
local barrage = 2;
local explosion = 3;
local fire = 4;
local missiles = 5;

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
  local charges = UnitPower("player", 16);
  local speed = GetUnitSpeed("player");
  local clearCast = FindBuff("player", "Clearcasting");

  if UnitChannelInfo("player") ~= nil then
    WowCyborg_CURRENTATTACK = "Channelling";
    return SetSpellRequest(nil);
  end

  if clearCast ~= nil and speed == 0 then
    if IsCastableAtEnemyTarget("Arcane Missiles", 0) then
      WowCyborg_CURRENTATTACK = "Arcane Missiles";
      return SetSpellRequest(missiles);
    end
  end

  if charges > 3 and IsCastableAtEnemyTarget("Arcane Barrage", 0) then
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

  if speed == 0 and IsCastableAtEnemyTarget("Arcane Blast", 0) then
    WowCyborg_CURRENTATTACK = "Arcane Blast";
    return SetSpellRequest(blast);
  end

  if IsCastableAtEnemyTarget("Arcane Barrage", 0) then
    WowCyborg_CURRENTATTACK = "Arcane Barrage";
    return SetSpellRequest(barrage);
  end
    
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Leveling mage rotation loaded");