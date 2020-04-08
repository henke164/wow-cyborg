--[[
  Button    Spell
  runeOfPower = 1;
  meteor = 2;
  combustion = 3;
  pyroblast = 4;
  dragonsBreath = 5;
  fireBlast = 6;
  scorch = 7;
  fireball = 8;
  flamestrike = 9;
  livingBomb = 0;
]]--

local runeOfPower = 1;
local meteor = 2;
local combustion = 3;
local pyroblast = 4;
local dragonsBreath = 5;
local fireBlast = 6;
local scorch = 7;
local fireball = 8;
local flamestrike = 9;
local livingBomb = 0;

function IsInCombatRange()
  return IsCastableAtEnemyTarget("Fireball", 0);
end

-- Multi target
function RenderMultiTargetRotation()
  
  local quaking = FindDebuff("player", "Quake");
  if quaking ~= nil then
    WowCyborg_CURRENTATTACK = "Quake!";
    return SetSpellRequest(nil);
  end
  
  local castingSpell = UnitCastingInfo("player");
  local combustionCd = GetSpellCooldown("Combustion", "spell");
  local combustionBuff = FindBuff("player", "Combustion");

  if IsInCombatRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if IsMoving() == false then
    if combustionCd == 0 and IsCastable("Rune of Power", 0) and FindBuff("player", "Rune of Power") == nil then
      WowCyborg_CURRENTATTACK = "Rune of Power";
      return SetSpellRequest(runeOfPower);
    end
  end

  if (combustionCd > 44 or combustionCd == 0 or combustionBuff ~= nil) and IsCastable("Meteor", 0) then
    WowCyborg_CURRENTATTACK = "Meteor";
    return SetSpellRequest(meteor);
  end

  if IsCastable("Combustion", 0) then
    WowCyborg_CURRENTATTACK = "Combustion";
    return SetSpellRequest(combustion);
  end

  local ropCharges = GetSpellCharges("Rune of Power");
  if IsMoving() == false and ropCharges == 2 and FindBuff("player", "Rune of Power") == nil then
    WowCyborg_CURRENTATTACK = "Rune of Power";
    return SetSpellRequest(runeOfPower);
  end

  if IsCastable("Flamestrike", 0) and FindBuff("player", "Hot Streak!") ~= nil then
    WowCyborg_CURRENTATTACK = "Flamestrike";
    return SetSpellRequest(flamestrike);
  end
  
  if IsCastableAtEnemyTarget("Living Bomb", 0) then
    WowCyborg_CURRENTATTACK = "Living Bomb";
    return SetSpellRequest(livingBomb);
  end

  if IsCastable("Dragon's Breath", 0) and CheckInteractDistance("target", 5) then
    WowCyborg_CURRENTATTACK = "Dragon's Breath";
    return SetSpellRequest(dragonsBreath);
  end
  
  if FindBuff("player", "Heating Up") ~= nil and IsCastableAtEnemyTarget("Fire Blast", 0) then
    WowCyborg_CURRENTATTACK = "Fire Blast";
    return SetSpellRequest(fireBlast);
  end

  local enemyHP = GetHealthPercentage("target");

  if enemyHP < 30 or IsMoving() then
    if IsCastableAtEnemyTarget("Scorch", 0) then
      WowCyborg_CURRENTATTACK = "Scorch";
      return SetSpellRequest(scorch);
    end
  end 
  
  if IsCastableAtEnemyTarget("Fireball", 0) then
    WowCyborg_CURRENTATTACK = "Fireball";
    return SetSpellRequest(fireball);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

-- Single target
function RenderSingleTargetRotation()
  local quaking = FindDebuff("player", "Quake");
  if quaking ~= nil then
    WowCyborg_CURRENTATTACK = "Quake!";
    return SetSpellRequest(nil);
  end

  local castingSpell = UnitCastingInfo("player");
  local combustionCd = GetSpellCooldown("Combustion", "spell");
  local combustionBuff, combustionBuffTTL = FindBuff("player", "Combustion");

  if IsInCombatRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if IsMoving() == false then
    if combustionCd == 0 and IsCastable("Rune of Power", 0) and FindBuff("player", "Rune of Power") == nil then
      WowCyborg_CURRENTATTACK = "Rune of Power";
      return SetSpellRequest(runeOfPower);
    end
  end

  if (combustionCd > 44 or combustionCd == 0 or combustionBuff ~= nil) and IsCastable("Meteor", 0) then
    WowCyborg_CURRENTATTACK = "Meteor";
    return SetSpellRequest(meteor);
  end

  if IsCastable("Combustion", 0) then
    WowCyborg_CURRENTATTACK = "Combustion";
    return SetSpellRequest(combustion);
  end

  local ropCharges = GetSpellCharges("Rune of Power");
  if IsMoving() == false and ropCharges == 2 and FindBuff("player", "Rune of Power") == nil then
    WowCyborg_CURRENTATTACK = "Rune of Power";
    return SetSpellRequest(runeOfPower);
  end

  if FindBuff("player", "Hot Streak!") ~= nil then
    if IsCastableAtEnemyTarget("Pyroblast", 0) then
      WowCyborg_CURRENTATTACK = "Pyroblast";
      return SetSpellRequest(pyroblast);
    end
  end

  if combustionBuff and combustionBuffTTL < 1 and IsCastable("Dragon's Breath", 0) and CheckInteractDistance("target", 5) then
    WowCyborg_CURRENTATTACK = "Dragon's Breath";
    return SetSpellRequest(dragonsBreath);
  end
  
  if FindBuff("player", "Heating Up") ~= nil and IsCastableAtEnemyTarget("Fire Blast", 0) then
    WowCyborg_CURRENTATTACK = "Fire Blast";
    return SetSpellRequest(fireBlast);
  end

  local enemyHP = GetHealthPercentage("target");

  if enemyHP < 30 or IsMoving() then
    if IsCastableAtEnemyTarget("Scorch", 0) then
      WowCyborg_CURRENTATTACK = "Scorch";
      return SetSpellRequest(scorch);
    end
  end 
  
  if IsCastableAtEnemyTarget("Fireball", 0) then
    WowCyborg_CURRENTATTACK = "Fireball";
    return SetSpellRequest(fireball);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Fire mage rotation loaded");