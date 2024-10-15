--[[
  Button    Spell
  1   Chains of Ice
  2   Outbreak
  3   Festering Strike
  4   Unholy Assault
  5   Apocalypse
  6   Death Coil
  7   Necrotic Strike
  7   Soul Reaper
]]--

local outbreak = "2";
local festeringStrike = "3";
local unholyAssault = "4";
local apocalypse = "5";
local deathCoil = "6";
local necroticStrike = "7";
local unholyBlight = "8";
local epidemic = "9";
local reapingFlames = "SHIFT+3";
local deathStrike = "SHIFT+4";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F5",
  "F6",
  "F7",
}
function RenderMultiTargetRotation()
  local runeCount = GetRuneCount();
  local coiDebuff = FindDebuff("target", "Virulent Plague");
  if coiDebuff == nil then
    if IsCastableAtEnemyTarget("Outbreak", 0) and runeCount > 0 then
      WowCyborg_CURRENTATTACK = "Outbreak";
      return SetSpellRequest(outbreak);
    end
  end

  if IsCastableAtEnemyTarget("Unholy Blight", 0) and runeCount > 0 then
    WowCyborg_CURRENTATTACK = "Unholy Blight";
    return SetSpellRequest(unholyBlight);
  end

  if IsCastableAtEnemyTarget("Epidemic", 30) then
    WowCyborg_CURRENTATTACK = "Epidemic";
    return SetSpellRequest(epidemic);
  end
  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  local runeCount = GetRuneCount();
  local hp = GetHealthPercentage("player");
  local targetHp = GetHealthPercentage("target");
  
  if false then
    WowCyborg_CURRENTATTACK = "Death Strike";
    return SetSpellRequest(deathStrike);
  end
  
  if (targetHp > 80 or targetHp < 20) and IsCastableAtEnemyTarget("Reaping Flames", 0) then
    WowCyborg_CURRENTATTACK = "Reaping Flames";
    return SetSpellRequest(reapingFlames);
  end

  local dsuBuff = FindBuff("player", "Dark Succor");
  if hp < 95 and dsuBuff ~= nil and IsCastableAtEnemyTarget("Death Strike", 0) then
    WowCyborg_CURRENTATTACK = "Death Strike";
    return SetSpellRequest(deathStrike);
  end

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
    elseif IsCastableAtEnemyTarget("Unholy Assault", 0) and fwStacks > 1 then
      WowCyborg_CURRENTATTACK = "Unholy Assault";
      return SetSpellRequest(unholyAssault);
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

print("DK Unholy PVP rotation loaded");