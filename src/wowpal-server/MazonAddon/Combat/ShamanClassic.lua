--[[
  Button    Spell
  1         Flameshock
  2         Lightning Shield
  3         Earthshock
  4         Healing Wave
  5         Lightning Bolt
  6         Attack
]]--

local flameshock = "1";
local lightningShield = "2";
local earthshock = "3";
local healingWave = "4";
local lightningBolt = "5";
local attack = "6";
local eat = "9";
local mhEnchant = "SHIFT+1";

function IsMelee()
  return CheckInteractDistance("target", 5);
end

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

-- Single target
function RenderSingleTargetRotation()
  local mana = (UnitPower("player") / UnitPowerMax("player")) * 100;
  local hp = GetHealthPercentage("player");
  local _, mhEnchantment = GetWeaponEnchantInfo();

  if mhEnchantment == nil then
    WowCyborg_CURRENTATTACK = "Enchant";
    return SetSpellRequest(mhEnchant);
  end

  local lsBuff = FindBuff("player", "Lightning Shield");
  if lsBuff == nil then
    WowCyborg_CURRENTATTACK = "Lightning Shield";
    return SetSpellRequest(lightningShield);
  end

  local targetFaction = UnitFactionGroup("target");
  if targetFaction ~= nil then
    WowCyborg_CURRENTATTACK = "Player targetted";
    return SetSpellRequest(nil);
  end
  
  if WowCyborg_INCOMBAT == false and IsMelee() == false then
    if IsCastableAtEnemyTarget("Flame Shock", 0) and WowCyborg_INCOMBAT == false then
      WowCyborg_CURRENTATTACK = "Flame Shock";
      return SetSpellRequest(flameshock);
    end

    if hp < 80 or mana < 50 then
      WowCyborg_CURRENTATTACK = "eat";
      return SetSpellRequest(eat);
    end
      
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if WowCyborg_INCOMBAT and IsMelee() == false then
    if IsCastableAtEnemyTarget("Earth Shock", 30) then
      WowCyborg_CURRENTATTACK = "Earth Shock";
      return SetSpellRequest(earthshock);
    end
  end

  if WowCyborg_INCOMBAT and IsMelee() then
    if IsCurrentSpell(6603) == false then
      WowCyborg_CURRENTATTACK = "Attack";
      return SetSpellRequest(attack);
    end
    
    if hp < 50 then
      WowCyborg_CURRENTATTACK = "Heal";
      return SetSpellRequest(healingWave);
    end

    WowCyborg_CURRENTATTACK = "Earth Shock";
    return SetSpellRequest(earthshock);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Classic shaman rotation loaded!");