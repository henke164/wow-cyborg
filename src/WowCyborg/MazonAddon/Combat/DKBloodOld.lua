--[[
  Button    Spell
  1   deathsCaress
  2   marrowrend
  3   bloodboil
  4   deathstrike
  5   heartstrike
  6   bonestorm
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

WowCyborg_PAUSE_KEYS = {
  "1",
  "F3",
  "F4",
  "F10",
  "NUMPAD1"
}

function RenderMultiTargetRotation()
  if IsCastableAtEnemyTarget("Bonestorm", 0) then
    WowCyborg_CURRENTATTACK = "Bonestorm";
    return SetSpellRequest(bonestorm);
  end

  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  local hpPercentage = GetHealthPercentage("player");
  local bsBuff, bsTs, bsStacks = FindBuff("player", "Bone Shield");
  local runeCount = GetRuneCount();
  local runeLimit = 3;
  if bsBuff == nil or bsStacks < 8 then
    runeLimit = 0;
  end

  if hpPercentage < 60 then
    if IsCastableAtEnemyTarget("Dancing Rune Weapon", 0) then
      WowCyborg_CURRENTATTACK = "Dancing Rune Weapon";
      return SetSpellRequest(dancingRuneWeapon);
    end
  end
  
  if hpPercentage < 50 then
    if IsCastableAtEnemyTarget("Vampiric blood", 0) then
      WowCyborg_CURRENTATTACK = "Vampiric blood";
      return SetSpellRequest(vampiricBlood);
    end
  end

  if (bsBuff == nil or bsStacks == nil or bsStacks < 8 or bsTs < 4) and runeCount > 1 then
    if IsCastableAtEnemyTarget("Marrowrend", 0) then
      WowCyborg_CURRENTATTACK = "Marrowrend";
      return SetSpellRequest(marrowrend);
    else
      return SetSpellRequest(nil);
    end
  end

  local bbCharges = GetSpellCharges("Blood Boil");
  if bbCharges ~= nil and bbCharges > 0 then
    if IsCastableAtEnemyTarget("Blood Boil", 0) and CheckInteractDistance("target", 3) then
      WowCyborg_CURRENTATTACK = "Blood Boil";
      return SetSpellRequest(bloodboil);
    end
  end

  if IsCastableAtEnemyTarget("Death Strike", 40) then
    WowCyborg_CURRENTATTACK = "Death Strike";
    return SetSpellRequest(deathstrike);
  end

  if hpPercentage < 70 then
    local rtBuff = FindBuff("player", "Rune Tap");
    if rtBuff == nil and runeCount > 0 and IsCastableAtEnemyTarget("Rune Tap", 0) then
      WowCyborg_CURRENTATTACK = "Rune Tap";
      return SetSpellRequest(runeTap);
    end
  end

  if runeCount >= runeLimit then
    if IsCastableAtEnemyTarget("Heart Strike", 0) then
      WowCyborg_CURRENTATTACK = "Heart Strike";
      return SetSpellRequest(heartstrike);
    end
  end

  if (bsBuff == nil or bsStacks == nil or bsStacks < 10 or bsTs < 4) and runeCount > 1 then
    if IsCastableAtEnemyTarget("Marrowrend", 0) then
      WowCyborg_CURRENTATTACK = "Marrowrend";
      return SetSpellRequest(marrowrend);
    end
  end

  if IsCastableAtEnemyTarget("Blood Boil", 0) and CheckInteractDistance("target", 3) then
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
      runeAmount = runeAmount+1
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