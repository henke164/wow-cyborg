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
local stormStrike = "3";
local healingWave = "4";
local lightningBolt = "5";
local attack = "6";
local stopcasting = "7";
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

  local targetFaction = UnitFactionGroup("target");
  if targetFaction ~= nil then
    WowCyborg_CURRENTATTACK = "Player targetted";
    return SetSpellRequest(nil);
  end
  
  if WowCyborg_INCOMBAT == false then
    if hp < 80 or mana < 50 then
      if hp < mana then
        WowCyborg_CURRENTATTACK = "Heal";
        return SetSpellRequest(healingWave);
      end
      WowCyborg_CURRENTATTACK = "eat";
      return SetSpellRequest(eat);
    end
      
    if IsCastableAtEnemyTarget("Flame Shock", 0) then
      WowCyborg_CURRENTATTACK = "Flame Shock";
      return SetSpellRequest(flameshock);
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local _, mhEnchantment = GetWeaponEnchantInfo();
  if mhEnchantment == nil then
    WowCyborg_CURRENTATTACK = "Enchant";
    return SetSpellRequest(mhEnchant);
  end

  if WowCyborg_INCOMBAT and IsMelee() then
    if IsCurrentSpell(6603) == false then
      WowCyborg_CURRENTATTACK = "Attack";
      return SetSpellRequest(attack);
    end

    local lsBuff = FindBuff("player", "Lightning Shield");
    if lsBuff == nil then
      WowCyborg_CURRENTATTACK = "Lightning Shield";
      return SetSpellRequest(lightningShield);
    end
  
    local flameDebuff = FindDebuff("target", "Flame Shock");
    if flameDebuff == nil and IsCastableAtEnemyTarget("Flame Shock", 0) then
      WowCyborg_CURRENTATTACK = "Flame Shock";
      return SetSpellRequest(flameshock);
    end

    if hp < 50 then
      WowCyborg_CURRENTATTACK = "Heal";
      return SetSpellRequest(healingWave);
    end

    WowCyborg_CURRENTATTACK = "Stormstrike";
    return SetSpellRequest(stormStrike);
  end

  local lsBuff = FindBuff("player", "Lightning Shield");
  if lsBuff == nil then
    WowCyborg_CURRENTATTACK = "Lightning Shield";
    return SetSpellRequest(lightningShield);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Classic shaman rotation loaded!");