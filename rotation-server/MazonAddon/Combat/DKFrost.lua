--[[
  Button    Spell
  1   Chains of Ice
  2   Outbreak
  3   Festering Strike
  4   Unholy Frenzy
  5   Apocalypse
  6   Death Coil
  7   Necrotic Strike
  8   Soul Reaper
]]--

local incomingDamage = {}
local meleeDamageInLast5Seconds = 0
local rangedDamageInLast5Seconds = 0

local chainsOfIce = "1";
local remorseLessWinter = "2";
local howlingBlast = "3";
local obliterate = "4";
local frostStrike = "5";
local deathCoil = "6";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F5",
  "F6",
  "F7",
}

function RenderMultiTargetRotation()
  local runeCount = GetRuneCount();

  local rime = FindBuff("player", "Rime");
  if rime ~= nil and IsCastableAtEnemyTarget("Howling Blast", 0) then
    WowCyborg_CURRENTATTACK = "Howling Blast";
    return SetSpellRequest(howlingBlast);
  end
  
  if IsCastableAtEnemyTarget("Frost Strike", 90) then
    WowCyborg_CURRENTATTACK = "Frost Strike";
    return SetSpellRequest(frostStrike);
  end
  
  local kmBuff = FindBuff("player", "Killing Machine");
  if kmBuff and runeCount >= 1 and IsCastableAtEnemyTarget("Frostscythe", 0) then
    WowCyborg_CURRENTATTACK = "Frostscythe";
    return SetSpellRequest(obliterate);
  end
  
  if IsCastableAtEnemyTarget("Remorseless Winter", 0) and runeCount > 0 then
    WowCyborg_CURRENTATTACK = "Remorseless Winter";
    return SetSpellRequest(remorseLessWinter);
  end

  if runeCount >= 1 and IsCastableAtEnemyTarget("Frostscythe", 0) then
    WowCyborg_CURRENTATTACK = "Frostscythe";
    return SetSpellRequest(obliterate);
  end

  if IsCastableAtEnemyTarget("Frost Strike", 70) then
    WowCyborg_CURRENTATTACK = "Frost Strike";
    return SetSpellRequest(frostStrike);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  local chBuff, chStacks = FindBuff("player", "Cold Heart");

  local runeCount = GetRuneCount();

  if chStacks == 20 then
    if IsCastableAtEnemyTarget("Chains of Ice", 0) and runeCount > 0 then
      WowCyborg_CURRENTATTACK = "Chains of Ice";
      return SetSpellRequest(chainsOfIce);
    end
  end

  if IsCastableAtEnemyTarget("Remorseless Winter", 0) and runeCount > 0 then
    WowCyborg_CURRENTATTACK = "Remorseless Winter";
    return SetSpellRequest(remorseLessWinter);
  end
  
  local rime = FindBuff("player", "Rime");
  if rime ~= nil and IsCastableAtEnemyTarget("Howling Blast", 0) then
    WowCyborg_CURRENTATTACK = "Howling Blast";
    return SetSpellRequest(howlingBlast);
  end

  if runeCount >= 4 and IsCastableAtEnemyTarget("Obliterate", 0) then
    WowCyborg_CURRENTATTACK = "Obliterate";
    return SetSpellRequest(obliterate);
  end
  
  if IsCastableAtEnemyTarget("Frost Strike", 90) then
    WowCyborg_CURRENTATTACK = "Frost Strike";
    return SetSpellRequest(frostStrike);
  end
  
  local kmBuff = FindBuff("player", "Killing Machine");
  if kmBuff and runeCount >= 2 and IsCastableAtEnemyTarget("Obliterate", 0) then
    WowCyborg_CURRENTATTACK = "Obliterate";
    return SetSpellRequest(obliterate);
  end
  
  if IsCastableAtEnemyTarget("Frost Strike", 70) then
    WowCyborg_CURRENTATTACK = "Frost Strike";
    return SetSpellRequest(frostStrike);
  end

  if runeCount >= 1 and IsCastableAtEnemyTarget("Obliterate", 0) then
    WowCyborg_CURRENTATTACK = "Obliterate";
    return SetSpellRequest(obliterate);
  end
  
  if IsCastableAtEnemyTarget("Frost Strike", 25) then
    WowCyborg_CURRENTATTACK = "Frost Strike";
    return SetSpellRequest(frostStrike);
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
print("DK Frost rotation loaded");
CreateDamageTakenFrame();