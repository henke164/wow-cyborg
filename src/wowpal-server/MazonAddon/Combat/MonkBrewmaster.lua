--[[
  Button    Spell
  1         Blackout Strike
  2         Keg Smash
  3         Breath of Fire
  4         Rushing Jade Wind
  5         Tiger Palm
]]--

local blackoutStrike = "1";
local kegSmash = "2";
local breathOfFire = "3";
local rushingJadeWind = "4";
local tigerPalm = "5";
local expelHarm = "9";

local ironskinBrew = "SHIFT+1";
local purifyingBrew = "SHIFT+2";
local fortifyingBrew = "SHIFT+3";

local incomingDamage = {}
local meleeDamageInLast5Seconds = 0
local rangedDamageInLast5Seconds = 0

function IsMelee()
  return IsSpellInRange("Blackout Strike");
end

function HandleDefensives()
  local hpPercentage = GetHealthPercentage("player");

  local dangerHpLossLimit = UnitHealthMax("player") * 0.5;
  if WowCyborg_INCOMBAT and hpPercentage < 100 then
      local isBuff = FindBuff("player", "Ironskin Brew");
      if isBuff == nil then
        local isCharges = GetSpellCharges("Ironskin Brew");
        if isCharges > 0 then
          WowCyborg_CURRENTATTACK = "Ironskin Brew";
          SetSpellRequest(ironskinBrew);
          return true;
        end
    end
  end

  dangerHpLossLimit = UnitHealthMax("player") * 0.2;
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
  local stagger = FindDebuff("player", "Moderate Stagger");
  local stagger2 = FindDebuff("player", "Heavy Stagger");
  if (staggerAmount > 20000 and pbCharges >= 3) or (stagger ~= nil or stagger2 ~= nil) then
    if pbCharges > 0 then
      WowCyborg_CURRENTATTACK = "Purifying Brew";
      SetSpellRequest(purifyingBrew);
      return true;
    end
  end

  
  local spheres = GetSpellCount("Expel Harm");
  if hpPercentage < 80 and spheres > 0 then
    WowCyborg_CURRENTATTACK = "Expel Harm";
    SetSpellRequest(expelHarm);
    return true;
  end

  return false;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  local defensives = HandleDefensives();
  if defensives == true then
    return;
  end

  if IsMelee() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if IsCastableAtEnemyTarget("Blackout Strike", 0) then
    WowCyborg_CURRENTATTACK = "Blackout Strike";
    return SetSpellRequest(blackoutStrike);
  end

  if IsCastableAtEnemyTarget("Keg Smash", 40) then
    WowCyborg_CURRENTATTACK = "Keg Smash";
    return SetSpellRequest(kegSmash);
  end

  if IsCastableAtEnemyTarget("Breath of Fire", 0) and IsCastableAtEnemyTarget("Tiger Palm", 0) then
    WowCyborg_CURRENTATTACK = "Breath of Fire";
    return SetSpellRequest(breathOfFire);
  end

  if IsCastableAtEnemyTarget("Rushing Jade Wind", 0) then
    WowCyborg_CURRENTATTACK = "Rushing Jade Wind";
    return SetSpellRequest(rushingJadeWind);
  end
  
  if IsCastableAtEnemyTarget("Tiger Palm", 25) then
    WowCyborg_CURRENTATTACK = "Tiger Palm";
    return SetSpellRequest(tigerPalm);
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

print("Brewmaster monk rotation loaded");
CreateDamageTakenFrame();