--[[
NAME: Deathknight Blood
ICON: spell_deathknight_bloodpresence
]]--

local incomingDamage = {}
local damageInLast5Seconds = 0
local dangerHpLossLimit = UnitHealthMax("player") * 0.5;

local deathsCaress = "1";
local marrowrend = "5";
local bloodboil = "6";
local deathstrike = "7";
local heartstrike = "8";
local bonestorm = "9";
local runeTap = "F+6";
local dancingRuneWeapon = "F+7";
local vampiricBlood = "F+8";
local tombstone = "F+9";

WowCyborg_PAUSE_KEYS = {
  "1",
  "2",
  "3",
  "F",
  "F3",
  "F4",
  "F10",
  "LSHIFT",
  "NUMPAD1",
  "NUMPAD3",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8"
}

function RenderMultiTargetRotation()
  if IsCastable("Bonestorm", 50) then
    WowCyborg_CURRENTATTACK = "Bonestorm";
    return SetSpellRequest(bonestorm);
  end

  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  local hpPercentage = GetHealthPercentage("player");
  local bsBuff, bsTs, bsStacks = FindBuff("player", "Bone Shield");
  local runicPower = UnitPower("player");
  local bladeDanceBuff = FindBuff("player", "Dancing Rune Weapon");
  local bbCharges = GetSpellCharges("Blood Boil");
  local runeCount = GetRuneCount();
  local saveForMarrowRend = false;

  if hpPercentage < 90 then
    if IsCastable("Dancing Rune Weapon", 0) then
      WowCyborg_CURRENTATTACK = "Dancing Rune Weapon";
      return SetSpellRequest(dancingRuneWeapon);
    end
  end

  if hpPercentage < 50 then
    if IsCastable("Consumption", 0) and IsSpellInRange("Heart Strike", "target") then
      WowCyborg_CURRENTATTACK = "Consumption";
      return SetSpellRequest(0);
    end
  end

  if hpPercentage < 85 then
    local rtBuff = FindBuff("player", "Rune Tap");
    if rtBuff == nil and runeCount > 0 and IsCastable("Rune Tap", 0) and CheckInteractDistance("target", 3) then
      WowCyborg_CURRENTATTACK = "Rune Tap";
      return SetSpellRequest(runeTap);
    end

    if bsStacks and bsStacks > 4 and IsCastable("Tombstone", 0) then
      WowCyborg_CURRENTATTACK = "Tombstone";
      return SetSpellRequest(tombstone);
    end
  end

  if hpPercentage < 50 then
    if IsCastableAtEnemyTarget("Vampiric blood", 0) and CheckInteractDistance("target", 3) then
      WowCyborg_CURRENTATTACK = "Vampiric blood";
      return SetSpellRequest(vampiricBlood);
    end
  end

  if (bsBuff == nil or bsStacks == nil or bsTs < 6) then
    saveForMarrowRend = true;
    if IsCastableAtEnemyTarget("Marrowrend", 0) then
      WowCyborg_CURRENTATTACK = "Marrowrend";
      return SetSpellRequest(marrowrend);
    end
  end

  local deathStrikeCost = 35;
  if bsStacks ~= nil and bsStacks >= 5 then
    --deathStrikeCost = 40;
  end

  if (damageInLast5Seconds > (UnitHealth("player") * 0.15) and IsCastableAtEnemyTarget("Death Strike", deathStrikeCost)) then
    WowCyborg_CURRENTATTACK = "Death Strike";
    return SetSpellRequest(deathstrike);
  end

  if bbCharges ~= nil and bbCharges > 1 and saveForMarrowRend == false then
    if IsCastable("Blood Boil", 0) and (CheckInteractDistance("target", 3) or IsSpellInRange("Heart Strike", "target")) and UnitCanAttack("player", "target") then
      WowCyborg_CURRENTATTACK = "Blood Boil";
      return SetSpellRequest(bloodboil);
    end
  end

  local bsStackTarget = 7;
  if bladeDanceBuff ~= nil then
    bsStackTarget = 4;
  end

  if (bsStacks == nil or bsStacks <= bsStackTarget) and runeCount > 1 then
    if IsCastableAtEnemyTarget("Marrowrend", 0) then
      WowCyborg_CURRENTATTACK = "Marrowrend";
      return SetSpellRequest(marrowrend);
    end
  end

  local runeLimit = 1;
  if bsBuff == nil or bsStacks <= 7 or bsTs < 6 then
    runeLimit = 3;
  end
  
  if (IsCastableAtEnemyTarget("Death Strike", deathStrikeCost)) then
    WowCyborg_CURRENTATTACK = "Death Strike";
    return SetSpellRequest(deathstrike);
  end

  if runeCount >= runeLimit then
    if IsCastableAtEnemyTarget("Heart Strike", 0) then
      WowCyborg_CURRENTATTACK = "Heart Strike";
      return SetSpellRequest(heartstrike);
    end
  end

  if IsCastable("Blood Boil", 0) and (CheckInteractDistance("target", 3) or IsSpellInRange("Heart Strike", "target")) and UnitCanAttack("player", "target") then
    WowCyborg_CURRENTATTACK = "Blood Boil";
    return SetSpellRequest(bloodboil);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function GetRuneCount()
  local runeAmount = 0
  for i=1,6 do
    local start, duration, runeReady = GetRuneCooldown(i)
    if runeReady == true then
      runeAmount = runeAmount + 0.5
    end
  end
  return runeAmount;
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
      damageInLast5Seconds = 0
      for i = #incomingDamage, 1, -1 do
          local damage = incomingDamage[i]
          if damage.timestamp < cutoff then
            incomingDamage[i] = nil
          else
            damageInLast5Seconds = damageInLast5Seconds + incomingDamage[i].damage;
          end
      end
    end

  end)
end

CreateDamageTakenFrame();

print("DK blood rotation loaded");