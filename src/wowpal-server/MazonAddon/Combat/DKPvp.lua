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
local outbreak = "2";
local festeringStrike = "3";
local unholyFrenzy = "4";
local apocalypse = "5";
local deathCoil = "6";
local necroticStrike = "7";
local breathOfTheDying = "8";
local unholyBlight = "9";
local deathStrike = "SHIFT+3";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F5",
  "F6",
  "F7",
}

function IsMelee()
  return CheckInteractDistance("target", 5);
end

function RenderMultiTargetRotation()
  local runeCount = GetRuneCount();

  local fwDebuff, fwTimeLeft, fwStacks = FindDebuff("target", "Festering Wound");
  
  local targetHp = GetHealthPercentage("target");
  if targetHp < 20 or targetHp > 80 then
    if IsCastableAtEnemyTarget("Reaping Flames", 0) then
      WowCyborg_CURRENTATTACK = "Reaping Flames";
      return SetSpellRequest(breathOfTheDying);
    end
  end

  if fwDebuff ~= nil and fwStacks == 1 then
    if IsMelee() and IsCastableAtEnemyTarget("Festering Strike", 0) and runeCount > 1 then
      WowCyborg_CURRENTATTACK = "Festering Strike";
      return SetSpellRequest(festeringStrike);
    end
  end

  if fwDebuff ~= nil and IsCastableAtEnemyTarget("Scourge Strike", 0) then
    if fwStacks > 3 and IsCastableAtEnemyTarget("Apocalypse", 0) then
      WowCyborg_CURRENTATTACK = "Apocalypse";
      return SetSpellRequest(apocalypse);
    elseif IsCastableAtEnemyTarget("Unholy Assault", 0) and fwStacks > 1 then
      WowCyborg_CURRENTATTACK = "Unholy Assault";
      return SetSpellRequest(unholyFrenzy);
    end
  end
  
  local sdBuff = FindBuff("player", "Sudden Doom");
  
  if sdBuff ~= nil and IsCastableAtEnemyTarget("Death Coil", 0) then
    WowCyborg_CURRENTATTACK = "Death Coil";
    return SetSpellRequest(deathCoil);
  end

  if fwDebuff ~= nil then
    if IsMelee() and IsCastableAtEnemyTarget("Scourge Strike", 0) and runeCount > 0 and fwStacks > 0 then
      WowCyborg_CURRENTATTACK = "Scourge Strike";
      return SetSpellRequest(necroticStrike);
    end
  end

  local dsuBuff = FindBuff("player", "Dark Succor");
  if dsuBuff ~= nil and IsCastableAtEnemyTarget("Death Strike", 0) then
    WowCyborg_CURRENTATTACK = "Death Strike";
    return SetSpellRequest(deathStrike);
  end

  if IsCastableAtEnemyTarget("Soul Reaper", 0) and runeCount < 4 then
    WowCyborg_CURRENTATTACK = "Soul Reaper";
    return SetSpellRequest(soulReaper);
  end

  if fwDebuff == nil or (fwTimeLeft < 5 or fwStacks < 6) then
    if IsMelee() and IsCastableAtEnemyTarget("Festering Strike", 0) and runeCount > 1 then
      WowCyborg_CURRENTATTACK = "Festering Strike";
      return SetSpellRequest(festeringStrike);
    end
  end

  if IsCastableAtEnemyTarget("Death Coil", 80) then
    WowCyborg_CURRENTATTACK = "Death Coil";
    return SetSpellRequest(deathCoil);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  local runeCount = GetRuneCount();
  local bof = FindBuff("target", "Blessing of Freedom");
  local targetHp = GetHealthPercentage("target");

  local fwDebuff, fwTimeLeft, fwStacks = FindDebuff("target", "Festering Wound");
  
  local targetHp = GetHealthPercentage("target");
  if targetHp < 20 or targetHp > 80 then
    if IsCastableAtEnemyTarget("Reaping Flames", 0) then
      WowCyborg_CURRENTATTACK = "Reaping Flames";
      return SetSpellRequest(breathOfTheDying);
    end
  end

  local hp = GetHealthPercentage("player");
  if hp < 50 and IsCastableAtEnemyTarget("Death Strike", 35) then
    WowCyborg_CURRENTATTACK = "Death Strike";
    return SetSpellRequest(deathStrike);
  end
  

  local vpDebuff = FindDebuff("target", "Virulent Plague");
  if vpDebuff == nil then
    if IsCastableAtEnemyTarget("Outbreak", 0) and runeCount > 0 then
      WowCyborg_CURRENTATTACK = "Outbreak";
      return SetSpellRequest(outbreak);
    end
  end

  local coiDebuff = FindDebuff("target", "Chains of Ice");
  if coiDebuff == nil and bof == nil then
    if IsCastableAtEnemyTarget("Chains of Ice", 0) and runeCount > 0 then
      WowCyborg_CURRENTATTACK = "Chains of Ice";
      return SetSpellRequest(chainsOfIce);
    end
  end
  
  if IsMelee() and IsSpellInRange("Festering Strike") and IsCastableAtEnemyTarget("Unholy Blight", 0) then
    WowCyborg_CURRENTATTACK = "Unholy Blight";
    return SetSpellRequest(unholyBlight);
  end

  if fwDebuff ~= nil and fwStacks == 1 then
    if IsMelee() and IsCastableAtEnemyTarget("Festering Strike", 0) and runeCount > 1 then
      WowCyborg_CURRENTATTACK = "Festering Strike";
      return SetSpellRequest(festeringStrike);
    end
  end

  if fwDebuff ~= nil and IsCastableAtEnemyTarget("Scourge Strike", 0) then
    if fwStacks > 3 and IsCastableAtEnemyTarget("Apocalypse", 0) then
      WowCyborg_CURRENTATTACK = "Apocalypse";
      return SetSpellRequest(apocalypse);
    elseif IsCastableAtEnemyTarget("Unholy Assault", 0) and fwStacks > 1 then
      WowCyborg_CURRENTATTACK = "Unholy Assault";
      return SetSpellRequest(unholyFrenzy);
    end
  end
  
  local sdBuff = FindBuff("player", "Sudden Doom");
  
  if sdBuff ~= nil and IsCastableAtEnemyTarget("Death Coil", 0) then
    WowCyborg_CURRENTATTACK = "Death Coil";
    return SetSpellRequest(deathCoil);
  end

  if fwDebuff ~= nil then
    if IsMelee() and IsCastableAtEnemyTarget("Scourge Strike", 0) and runeCount > 0 and fwStacks > 0 then
      WowCyborg_CURRENTATTACK = "Scourge Strike";
      return SetSpellRequest(necroticStrike);
    end
  end

  local dsuBuff = FindBuff("player", "Dark Succor");
  if dsuBuff ~= nil and IsCastableAtEnemyTarget("Death Strike", 0) then
    WowCyborg_CURRENTATTACK = "Death Strike";
    return SetSpellRequest(deathStrike);
  end

  if IsCastableAtEnemyTarget("Soul Reaper", 0) and runeCount < 4 then
    WowCyborg_CURRENTATTACK = "Soul Reaper";
    return SetSpellRequest(soulReaper);
  end

  if fwDebuff == nil or (fwTimeLeft < 5 or fwStacks < 6) then
    if IsMelee() and IsCastableAtEnemyTarget("Festering Strike", 0) and runeCount > 1 then
      WowCyborg_CURRENTATTACK = "Festering Strike";
      return SetSpellRequest(festeringStrike);
    end
  end

  if IsCastableAtEnemyTarget("Death Coil", 80) then
    WowCyborg_CURRENTATTACK = "Death Coil";
    return SetSpellRequest(deathCoil);
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