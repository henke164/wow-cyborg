--[[
  Button    Spell
  local bloodthirst = "1";
  local whirlwind = "2";
  local heroicStrike = "3";
  local execute = "4";
  local attack = "7";
  local battleshout = "0";
]]--

local bloodthirst = "1";
local overpower = "1";
local whirlwind = "2";
local heroicStrike = "3";
local execute = "4";
local attack = "7";
local cleave = "8";
local hamstring = "9";
local battleshout = "0";

function IsMelee()
  return CheckInteractDistance("target", 5);
end

-- Multi target
function RenderMultiTargetRotation()
  if WowCyborg_INCOMBAT == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if IsCurrentSpell(6603) == false then
    WowCyborg_CURRENTATTACK = "Attack";
    return SetSpellRequest(attack);
  end

  local bsBuff = FindBuff("player", "Battle Shout");
  if bsBuff == nil and IsCastable("Battle Shout", 10) then
    WowCyborg_CURRENTATTACK = "Battle Shout";
    return SetSpellRequest(battleshout);
  end
  
  local opBuff = IsUsableSpell("Overpower");
  if opBuff == true then
    if IsCastableAtEnemyTarget("Overpower", 5) then
      WowCyborg_CURRENTATTACK = "Overpower";
      return SetSpellRequest(overpower);
    end
  end

  if IsMelee() and IsCastableAtEnemyTarget("Whirlwind", 0) then
    WowCyborg_CURRENTATTACK = "Whirlwind";
    return SetSpellRequest(whirlwind);
  end

  if IsCastableAtEnemyTarget("Bloodthirst", 0) then
    WowCyborg_CURRENTATTACK = "Bloodthirst";
    return SetSpellRequest(bloodthirst);
  end

  if IsCastableAtEnemyTarget("Cleave", 45) then
    WowCyborg_CURRENTATTACK = "Cleave";
    return SetSpellRequest(cleave);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

-- Single target
function RenderSingleTargetRotation()

  if WowCyborg_INCOMBAT == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if IsCurrentSpell(6603) == false then
    WowCyborg_CURRENTATTACK = "Attack";
    return SetSpellRequest(attack);
  end

  local bsBuff = FindBuff("player", "Battle Shout");
  if bsBuff == nil and IsCastable("Battle Shout", 10) then
    WowCyborg_CURRENTATTACK = "Battle Shout";
    return SetSpellRequest(battleshout);
  end
  
  local opBuff = IsUsableSpell("Overpower");
  if opBuff == true then
    if IsCastableAtEnemyTarget("Overpower", 5) then
      WowCyborg_CURRENTATTACK = "Overpower";
      return SetSpellRequest(overpower);
    end
  end

  local targetHp = GetHealthPercentage("target");
  if targetHp < 20 then
    if IsCastableAtEnemyTarget("Execute", 0) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end
  end

  if IsCastableAtEnemyTarget("Bloodthirst", 0) then
    WowCyborg_CURRENTATTACK = "Bloodthirst";
    return SetSpellRequest(bloodthirst);
  end

  if IsCastableAtEnemyTarget("Whirlwind", 0) then
    WowCyborg_CURRENTATTACK = "Whirlwind";
    return SetSpellRequest(whirlwind);
  end

  local _, enchant = GetWeaponEnchantInfo();
  
  if (enchant == nil) == false and IsCastableAtEnemyTarget("Hamstring", 0) then
    WowCyborg_CURRENTATTACK = "Hamstring";
    return SetSpellRequest(hamstring);
  end
  
  if IsCastableAtEnemyTarget("Heroic Strike", 60) then
    WowCyborg_CURRENTATTACK = "Heroic Strike";
    return SetSpellRequest(heroicStrike);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Classic fury warrior rotation loaded!");