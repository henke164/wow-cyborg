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
local sigilOfFlame = "5";
local demonSpikes = "6";
local glaive = "7";
local fieryBrand = "8";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "F4",
  "F7",
  "0",
  "R",
  "F10",
  "LSHIFT",
  "NUMPAD1",
  "NUMPAD5",
  "NUMPAD8"
}

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true)
end

function RenderSingleTargetRotation(fireSigil)
  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if CheckInteractDistance("target", 5) == false and WowCyborg_INCOMBAT == true then
    if IsCastableAtEnemyTarget("Throw Glaive", 0) then 
      WowCyborg_CURRENTATTACK = "Throw Glaive";
      return SetSpellRequest(glaive);
    end
  end
  
  if UnitChannelInfo("player") == "Fel Devastation" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if IsCastableAtEnemyTarget("Fiery Brand", 0) then 
    WowCyborg_CURRENTATTACK = "Fiery Brand";
    return SetSpellRequest(fieryBrand);
  end

  if IsCastable("Sigil of Flame", 0) and fireSigil then
    WowCyborg_CURRENTATTACK = "Sigil of Flame";
    return SetSpellRequest(sigilOfFlame);
  end

  local demonSpikesBuff = FindBuff("player", "Demon Spikes");
  if WowCyborg_INCOMBAT == true and demonSpikesBuff == nil and IsCastable("Demon Spikes", 0) then
    WowCyborg_CURRENTATTACK = "Demon Spikes";
    return SetSpellRequest(demonSpikes);
  end

  local pain = UnitPower("player");
  local _, _, sbCharges = FindBuff("player", "Soul Fragments");
  if sbCharges ~= nil and sbCharges >= 4 and IsCastableAtEnemyTarget("Spirit Bomb", 30) then
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

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Disrupt", "target") == 1;
end

print("Demon hunter tank rotation loaded");