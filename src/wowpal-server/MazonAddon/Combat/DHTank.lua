--[[
  Button    Spell
  1         Blade Dance
  2         Chaos Strike
  3         Execute
  4         Eye Beam
  5         Overpower
]]--

local spiritBomb = "1";
local fracture = "2";
local soulCleave = "3";
local immolationAura = "4";
local animaOfDeath = "5";
local demonSpikes = "6";

WowCyborg_PAUSE_KEYS = {
  "F3",
  "F4",
  "0",
  "F10"
}

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation()
end

function RenderSingleTargetRotation()
  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local demonSpikesBuff = FindBuff("player", "Demon Spikes");
  if WowCyborg_INCOMBAT == true and demonSpikesBuff == nil and IsCastable("Demon Spikes", 0) then
    WowCyborg_CURRENTATTACK = "Demon Spikes";
    return SetSpellRequest(demonSpikes);
  end

  local pain = UnitPower("player");
  local _, _, sbCharges = FindBuff("player", "Soul Fragments");
  if sbCharges ~= nil and sbCharges >= 4 then
    WowCyborg_CURRENTATTACK = "Spirit Bomb";
    return SetSpellRequest(spiritBomb);
  end

  if IsCastableAtEnemyTarget("Immolation Aura", 0) then 
    WowCyborg_CURRENTATTACK = "Immolation Aura";
    return SetSpellRequest(immolationAura);
  end

  if pain > 90 and IsCastableAtEnemyTarget("Soul Cleave", 30) then 
    WowCyborg_CURRENTATTACK = "Soul Cleave";
    return SetSpellRequest(soulCleave);
  end

  if IsCastableAtEnemyTarget("Fracture", 0) then
    WowCyborg_CURRENTATTACK = "Fracture";
    return SetSpellRequest(fracture);
  end
  
  if IsCastableAtEnemyTarget("Anima of Death", 0) then
    WowCyborg_CURRENTATTACK = "Anima of Death";
    return SetSpellRequest(animaOfDeath);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return CheckInteractDistance("target", 5);
end

print("Demon hunter tank rotation loaded");