--[[
  Button    Spell
  1         Blackout Strike
  2         Keg Smash
  3         Breath of Fire
  4         Rushing Jade Wind
  5         Tiger Palm
]]--
WowCyborg_PAUSE_KEYS = {
  "F1",
  "F4",
  "F5",
  "F6",
  "F7",
  "9",
}

local moonfire = "1";
local thrash = "2";
local mangle = "3";
local ironfur = "4";
local swipe = "5";
local frenziedRegeneration = "6";

local incomingDamage = {}
local meleeDamageInLast5Seconds = 0
local rangedDamageInLast5Seconds = 0

function IsMelee()
  return IsSpellInRange("Maul");
end

function RenderMultiTargetRotation()
  if UnitChannelInfo("player") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local hp = GetHealthPercentage("player");
  local targetHp = GetHealthPercentage("target");

  if hp < 70 then
    local regenBuff = FindBuff("player", "Frenzied Regeneration");
    if regenBuff == nil and IsCastableAtEnemyTarget("Frenzied Regeneration", 10) then
      WowCyborg_CURRENTATTACK = "Frenzied Regeneration";
      return SetSpellRequest(frenziedRegeneration);
    end
  end


  local ggBuff = FindBuff("player", "Galactic Guardian");
  local moonfireDot = FindDebuff("target", "Moonfire");

  if IsMelee() == 0 then
    if (moonfireDot == nil and IsCastableAtEnemyTarget("Moonfire", 0)) and ggBuff ~= nil then
      WowCyborg_CURRENTATTACK = "Moonfire";
      return SetSpellRequest(moonfire);
    end
  
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if IsCastableAtEnemyTarget("Thrash", 0) then
    WowCyborg_CURRENTATTACK = "Thrash";
    return SetSpellRequest(thrash);
  end

  if (moonfireDot == nil and IsCastableAtEnemyTarget("Moonfire", 0)) and ggBuff ~= nil then
    WowCyborg_CURRENTATTACK = "Moonfire";
    return SetSpellRequest(moonfire);
  end

  if IsCastable("Ironfur", 40) then
    WowCyborg_CURRENTATTACK = "Ironfur";
    return SetSpellRequest(ironfur);
  end

  if IsCastableAtEnemyTarget("Swipe", 0) then
    WowCyborg_CURRENTATTACK = "Swipe";
    return SetSpellRequest(swipe);
  end
 
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  if UnitChannelInfo("player") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local hp = GetHealthPercentage("player");

  if hp < 70 then
    local regenBuff = FindBuff("player", "Frenzied Regeneration");
    if regenBuff == nil and IsCastableAtEnemyTarget("Frenzied Regeneration", 10) then
      WowCyborg_CURRENTATTACK = "Frenzied Regeneration";
      return SetSpellRequest(frenziedRegeneration);
    end
  end

  local ggBuff = FindBuff("player", "Galactic Guardian");
  local moonfireDot = FindDebuff("target", "Moonfire");

  if (moonfireDot == nil and IsCastableAtEnemyTarget("Moonfire", 0)) or ggBuff ~= nil then
    WowCyborg_CURRENTATTACK = "Moonfire";
    return SetSpellRequest(moonfire);
  end

  if IsMelee() == 0 then
    if IsCastableAtEnemyTarget("Moonfire", 0) then
      WowCyborg_CURRENTATTACK = "Moonfire";
      return SetSpellRequest(moonfire);
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local _, bleedDotTl, bleedDots = FindDebuff("target", "Thrash");
  
  if (bleedDots == nil or bleedDots < 3 or bleedDotTl < 2) and IsCastableAtEnemyTarget("Thrash", 0) then
    WowCyborg_CURRENTATTACK = "Thrash";
    return SetSpellRequest(thrash);
  end
 
  if IsCastableAtEnemyTarget("Mangle", 0) then
    WowCyborg_CURRENTATTACK = "Mangle";
    return SetSpellRequest(mangle);
  end

  if IsCastableAtEnemyTarget("Thrash", 0) then
    WowCyborg_CURRENTATTACK = "Thrash";
    return SetSpellRequest(thrash);
  end
  
  if IsCastable("Ironfur", 40) then
    WowCyborg_CURRENTATTACK = "Ironfur";
    return SetSpellRequest(ironfur);
  end

  if IsCastableAtEnemyTarget("Swipe", 0) then
    WowCyborg_CURRENTATTACK = "Swipe";
    return SetSpellRequest(swipe);
  end

  if IsCastableAtEnemyTarget("Moonfire", 0) then
    WowCyborg_CURRENTATTACK = "Moonfire";
    return SetSpellRequest(moonfire);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end


function CreateDamageTakenFrame()
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

  frame:SetScript("OnEvent", function()
    local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, amountDetails = CombatLogGetCurrentEventInfo()
    if destGUID ~= UnitGUID("player") then
      return;
    end
    
    local DamageDetails
    if type == "SPELL_DAMAGE" or type == "SPELL_PERIODIC_DAMAGE" or type == "RANGE_DAMAGE" then
      _, _, _, damage = amountDetails
      DamageDetails = { damage = damage, melee = false };
    elseif type == "SWING_DAMAGE" then
      damage = amountDetails;
      DamageDetails = { damage = damage, melee = true };
    elseif type == "ENVIRONMENTAL_DAMAGE" then
      _, damage = amountDetails
      DamageDetails = { damage = damage, melee = false };
    end

    if DamageDetails and DamageDetails.damage then
      DamageDetails.timestamp = timestamp;

      tinsert(incomingDamage, 1, DamageDetails);

      local cutoff = timestamp - 5
      meleeDamageInLast5Seconds = 0
      rangedDamageInLast5Seconds = 0;
      for i = #incomingDamage, 1, -1 do
          local damage = incomingDamage[i]
          if damage.timestamp < cutoff then
            incomingDamage[i] = nil
          else
            if damage.melee then
              meleeDamageInLast5Seconds = meleeDamageInLast5Seconds + incomingDamage[i].damage;
            else
              rangedDamageInLast5Seconds = rangedDamageInLast5Seconds + incomingDamage[i].damage;
            end
          end
      end
    end

  end)
end

print("Druid tank rotation loaded");
CreateDamageTakenFrame();