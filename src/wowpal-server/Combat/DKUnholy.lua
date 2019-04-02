--[[
  Button    Spell
  1   Chains of Ice
  2   Outbreak
  3   Festering Strike
  4   Unholy Frenzy
  5   Apocalypse
  6   Death Coil
  7   Necrotic Strike
  7   Soul Reaper
]]--

local incomingDamage = {}
local meleeDamageInLast5Seconds = 0
local rangedDamageInLast5Seconds = 0

local chainsOfIce = "1";
local outbreak = "2";
local festeringStrike = "3";
local unholyFrenzy = "4";
local apocalypse = "5";
local deathCoil = "6";
local necroticStrike = "7";
local soulReaper = "8";

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  local runeCount = GetRuneCount();

  local fwDebuff, fwTimeLeft, fwStacks = FindDebuff("target", "Festering Wound");
    
  local coiDebuff = FindDebuff("target", "Virulent Plague");
  if coiDebuff == nil then
    if IsCastableAtEnemyTarget("Outbreak", 0) and runeCount > 0 then
      WowCyborg_CURRENTATTACK = "Outbreak";
      return SetSpellRequest(outbreak);
    end
  end

  if fwDebuff ~= nil and fwStacks == 1 then
    if IsCastableAtEnemyTarget("Festering Strike", 0) and runeCount > 1 then
      WowCyborg_CURRENTATTACK = "Festering Strike";
      return SetSpellRequest(festeringStrike);
    end
  end

  if fwDebuff ~= nil and IsCastableAtEnemyTarget("Scourge Strike", 0) then
    if fwStacks > 3 and IsCastableAtEnemyTarget("Apocalypse", 0) then
      WowCyborg_CURRENTATTACK = "Apocalypse";
      return SetSpellRequest(apocalypse);
    elseif IsCastableAtEnemyTarget("Unholy Frenzy", 0) and fwStacks > 1 then
      WowCyborg_CURRENTATTACK = "Unholy Frenzy";
      return SetSpellRequest(unholyFrenzy);
    end
  end
  
  local sdBuff = FindBuff("player", "Sudden Doom");
  
  if sdBuff ~= nil and IsCastableAtEnemyTarget("Death Coil", 0) then
    WowCyborg_CURRENTATTACK = "Death Coil";
    return SetSpellRequest(deathCoil);
  end

  if IsCastableAtEnemyTarget("Death Coil", 80) then
    WowCyborg_CURRENTATTACK = "Death Coil";
    return SetSpellRequest(deathCoil);
  end

  if fwDebuff ~= nil then
    if IsCastableAtEnemyTarget("Scourge Strike", 0) and runeCount > 0 and fwStacks > 0 then
      WowCyborg_CURRENTATTACK = "Scourge Strike";
      return SetSpellRequest(necroticStrike);
    end
  end

  if IsCastableAtEnemyTarget("Soul Reaper", 0) and runeCount < 4 then
    WowCyborg_CURRENTATTACK = "Soul Reaper";
    return SetSpellRequest(soulReaper);
  end

  if fwDebuff == nil or (fwTimeLeft < 5 or fwStacks < 6) then
    if IsCastableAtEnemyTarget("Festering Strike", 0) and runeCount > 1 then
      WowCyborg_CURRENTATTACK = "Festering Strike";
      return SetSpellRequest(festeringStrike);
    end
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
print("DK Unholy PVP rotation loaded");
CreateDamageTakenFrame();