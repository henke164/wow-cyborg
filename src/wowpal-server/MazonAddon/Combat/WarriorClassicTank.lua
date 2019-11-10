--[[
  Button    Spell
  1         Charge
  2         Rend
  3         Heroic strike
  4         Overpower
  5         Battleshout
  6         Attack
]]--

local revenge = "1";
local bloodthirst = "2";
local heroicStrike = "3";
local cleave = "4";
local sunderArmor = "5";
local shieldBlock = "6";
local attack = "7";
local demoShout = "8";
local battleshout = "0";
local bloodRage = "SHIFT+2";

function IsMelee()
  return IsSpellInRange("Rend", "target") == 1;
end

-- Multi target
function RenderMultiTargetRotation()
  if IsMelee() and  IsCurrentSpell(6603) == false then
    WowCyborg_CURRENTATTACK = "Attack";
    return SetSpellRequest(attack);
  end

  local bsBuff = FindBuff("player", "Battle Shout");
  if bsBuff == nil and IsCastable("Battle Shout", 10) then
    WowCyborg_CURRENTATTACK = "Battle Shout";
    return SetSpellRequest(battleshout);
  end

  if IsMelee() then
    local demoDebuff = FindDebuff("target", "Demoralizing Shout");
    if demoDebuff == nil then
      if IsCastable("Demoralizing Shout", 0) then
        WowCyborg_CURRENTATTACK = "Demoralizing Shout";
        return SetSpellRequest(demoShout);
      end
    end  
  end

  if IsCastableAtEnemyTarget("Bloodthirst", 30) then
    WowCyborg_CURRENTATTACK = "Bloodthirst";
    return SetSpellRequest(bloodthirst);
  end

  if IsCastableAtEnemyTarget("Revenge", 5) then
    WowCyborg_CURRENTATTACK = "Revenge";
    return SetSpellRequest(revenge);
  end

  if IsCastableAtEnemyTarget("Shield Block", 40) then
    WowCyborg_CURRENTATTACK = "Shield Block";
    return SetSpellRequest(shieldBlock);
  end
  
  if IsCastableAtEnemyTarget("Cleave", 20) then
    WowCyborg_CURRENTATTACK = "Cleave";
    return SetSpellRequest(cleave);
  end
  
  if IsMelee() and IsCastable("Bloodrage", 0) then
    WowCyborg_CURRENTATTACK = "Bloodrage";
    return SetSpellRequest(bloodRage);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

-- Single target
function RenderSingleTargetRotation()
  if IsMelee() and  IsCurrentSpell(6603) == false then
    WowCyborg_CURRENTATTACK = "Attack";
    return SetSpellRequest(attack);
  end

  local bsBuff = FindBuff("player", "Battle Shout");
  if bsBuff == nil and IsCastable("Battle Shout", 10) then
    WowCyborg_CURRENTATTACK = "Battle Shout";
    return SetSpellRequest(battleshout);
  end

  if IsMelee() then
    local demoDebuff = FindDebuff("target", "Demoralizing Shout");
    if demoDebuff == nil then
      if IsCastable("Demoralizing Shout", 0) then
        WowCyborg_CURRENTATTACK = "Demoralizing Shout";
        return SetSpellRequest(demoShout);
      end
    end  
  end

  if IsCastableAtEnemyTarget("Bloodthirst", 30) then
    WowCyborg_CURRENTATTACK = "Bloodthirst";
    return SetSpellRequest(bloodthirst);
  end
  
  if IsCastableAtEnemyTarget("Revenge", 5) then
    WowCyborg_CURRENTATTACK = "Revenge";
    return SetSpellRequest(revenge);
  end

  if IsCastableAtEnemyTarget("Shield Block", 40) then
    WowCyborg_CURRENTATTACK = "Shield Block";
    return SetSpellRequest(shieldBlock);
  end
  
  local sunderDebuff, __, sunders = FindDebuff("target", "Sunder Armor");
  if (sunderDebuff == nil or sunders < 5) and IsCastableAtEnemyTarget("Sunder Armor", 15) then
    WowCyborg_CURRENTATTACK = "Sunder Armor";
    return SetSpellRequest(sunderArmor);
  end
  
  if IsCastableAtEnemyTarget("Heroic Strike", 15) then
    WowCyborg_CURRENTATTACK = "Heroic Strike";
    return SetSpellRequest(heroicStrike);
  end
  
  if IsMelee() and IsCastable("Bloodrage", 0) then
    WowCyborg_CURRENTATTACK = "Bloodrage";
    return SetSpellRequest(bloodRage);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Classic tank rotation loaded!");