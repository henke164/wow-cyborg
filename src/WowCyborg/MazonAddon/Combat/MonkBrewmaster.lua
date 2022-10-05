--[[
  Button    Spell
  1         Blackout Kick
  2         Keg Smash
  3         Breath of Fire
  4         Rushing Jade Wind
  5         Tiger Palm
]]--

local blackoutKick = "1";
local kegSmash = "2";
local breathOfFire = "3";
local rushingJadeWind = "4";
local tigerPalm = "5";
local spinningCraneKick = "6";
local expelHarm = "9";

local celestialBrew = "F+5";
local purifyingBrew = "F+6";
local fortifyingBrew = "F+7";

local incomingDamage = {}
local meleeDamageInLast5Seconds = 0
local rangedDamageInLast5Seconds = 0

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "F4",
  "F10",
  "NUMPAD3",
}

function IsMelee()
  return IsSpellInRange("Blackout Kick");
end

function HandleDefensives()
  local hpPercentage = GetHealthPercentage("player");

  local dangerHpLossLimit = UnitHealthMax("player") * 0.2;
  if meleeDamageInLast5Seconds > dangerHpLossLimit or 
  rangedDamageInLast5Seconds > dangerHpLossLimit or
  hpPercentage < 50 then
    if IsCastable("Fortifying Brew", 0) then
      WowCyborg_CURRENTATTACK = "Fortifying Brew";
      SetSpellRequest(fortifyingBrew);
      return true;
    end
  end

  local pbCharges = GetSpellCharges("Purifying Brew");
  local staggerAmount = UnitStagger("player");
  local stagger2 = FindDebuff("player", "Moderate Stagger");
  if (staggerAmount ~= nil and staggerAmount > dangerHpLossLimit) or stagger2 ~= nil then
    if pbCharges > 0 then
      WowCyborg_CURRENTATTACK = "Purifying Brew";
      SetSpellRequest(purifyingBrew);
      return true;
    end
  end

  if WowCyborg_INCOMBAT and hpPercentage < 95 then
    if IsCastable("Celestial Brew", 0) then
      WowCyborg_CURRENTATTACK = "Celestial Brew";
      SetSpellRequest(celestialBrew);
      return true;
    end
  end

  if hpPercentage < 90 then
    if IsCastableAtEnemyTarget("Expel Harm", 0) then
      WowCyborg_CURRENTATTACK = "Expel Harm";
      SetSpellRequest(expelHarm);
      return true;
    end
  end

  return false;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(aoe)
  if aoe == nil then
    aoe = false
  end

  local defensives = HandleDefensives();
  if defensives == true then
    return;
  end

  if IsMelee() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local kegCd = GetCooldown("Keg Smash");
  local saveEnergy = 0;
  if kegCd < 2 then
    saveEnergy = 25;
  end

  if IsCastableAtEnemyTarget("Keg Smash", 25) then
    WowCyborg_CURRENTATTACK = "Keg Smash";
    return SetSpellRequest(kegSmash);
  end

  if IsCastableAtEnemyTarget("Blackout Kick", 0) then
    WowCyborg_CURRENTATTACK = "Blackout Kick";
    return SetSpellRequest(blackoutKick);
  end

  if IsCastableAtEnemyTarget("Breath of Fire", 0) and IsCastableAtEnemyTarget("Tiger Palm", 0) then
    WowCyborg_CURRENTATTACK = "Breath of Fire";
    return SetSpellRequest(breathOfFire);
  end

  local rjwBuff = FindBuff("player", "Rushing Jade Wind");
  if rjwBuff == nil and IsCastableAtEnemyTarget("Rushing Jade Wind", 0) then
    WowCyborg_CURRENTATTACK = "Rushing Jade Wind";
    return SetSpellRequest(rushingJadeWind);
  end
  
  if aoe then
    if IsCastableAtEnemyTarget("Spinning Crane Kick", 40 + saveEnergy) then
      WowCyborg_CURRENTATTACK = "Spinning Crane Kick";
      return SetSpellRequest(spinningCraneKick);
    end
  else
    if IsCastableAtEnemyTarget("Tiger Palm", 40 + saveEnergy) then
      WowCyborg_CURRENTATTACK = "Tiger Palm";
      return SetSpellRequest(tigerPalm);
    end
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

      local cuwff = timestamp - 5
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

print("Brewmaster monk rotation loaded");
CreateDamageTakenFrame();