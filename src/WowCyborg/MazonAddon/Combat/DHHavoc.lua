--[[
  Button    Spell
  bladeDance = "1";
  chaosStrike = "2";
  attack = "3";
  eyeBeam = "4";
  concentratedFlame = "6";
  glavies = "8";
]]--

local bladeDance = "1";
local chaosStrike = "2";
local essenceBreak = "3";
local eyeBeam = "4";
local immolationAura = "5";
local consumeMagic = "6";
local arcaneTorrent = "7";
local glavies = "8";
local felblade = "9";
local glaviesHeal = "F+4";
local sigilOfFlame = "F+5";
local attack = "F+6";
local glaiveTempest = "F+7";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "0",
  "R",
  "F",
  "F10",
  "LSHIFT",
  "NUMPAD1",
  "NUMPAD3",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "MOUSE3"
}

function HasDispellableBuff(target)
  for i=1,40 do
    local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff(target, i);
    if name ~= nil then
      if shouldConsolidate and (debuffType == 12 or debuffType == 10) then
        return true;
      end
    end    
  end
  return false;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true)
end

function RenderSingleTargetRotation(skipGlavie)
  local hp = GetHealthPercentage("player");
  local fodder = FindBuff("player", "Fodder to the Flame");
  local ctBuff = FindBuff("player", "Chaos Theory");
  local eBreakDebuff = FindBuff("target", "Essence Break");
  local dispellable = HasDispellableBuff("target");

  if UnitChannelInfo("player") then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if hp < 50 then
    if IsCastable("Blur", 0) then
      WowCyborg_CURRENTATTACK = "Blur";
      return SetSpellRequest("F+2");
    end
  end

  local imprisonDebuff = FindDebuff("target", "Imprison");
  local cycloneDebuff = FindDebuff("target", "Cyclone");
  if imprisonDebuff ~= nil or cycloneDebuff ~= nil then
    WowCyborg_CURRENTATTACK = "Imprison";
    return SetSpellRequest(nil);
  end

  local glaiveCharges = GetSpellCharges("Throw Glaive");
  if glaiveCharges == 2 and eBreakDebuff == nil then
    if IsCastableAtEnemyTarget("Throw Glaive", 25) then
      WowCyborg_CURRENTATTACK = "Throw Glaive";
      return SetSpellRequest(glavies);
    end
  end

  if fodder ~= nil and hp < 70 then
    if IsCastableAtEnemyTarget("Throw Glaive", 25) then
      WowCyborg_CURRENTATTACK = "Throw Glaive";
      return SetSpellRequest(glaviesHeal);
    end
  end

  if InMeleeRange() and IsCastableAtEnemyTarget("Glaive Tempest", 30) then
    WowCyborg_CURRENTATTACK = "Glaive Tempest";
    return SetSpellRequest(glaiveTempest);
  end

  if dispellable then
    if IsCastableAtEnemyTarget("Consume Magic", 0) then
      WowCyborg_CURRENTATTACK = "Consume Magic";
      return SetSpellRequest(consumeMagic);
    end

    if InMeleeRange() and IsCastable("Arcane Torrent", 0) then
      WowCyborg_CURRENTATTACK = "Arcane Torrent";
      return SetSpellRequest(arcaneTorrent);
    end
  end

  if CheckInteractDistance("target", 3) and IsCastableAtEnemyTarget("Immolation Aura", 0) then
    WowCyborg_CURRENTATTACK = "Immolation Aura";
    return SetSpellRequest(immolationAura);
  end

  if InMeleeRange() == false then
    if IsCastableAtEnemyTarget("Felblade", 0) then
      WowCyborg_CURRENTATTACK = "Felblade";
      return SetSpellRequest(felblade);
    end
    
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local thorns = FindBuff("target", "Thorns");
  if thorns ~= nil then
    WowCyborg_CURRENTATTACK = "Thorns";
    return SetSpellRequest(nil);
  end
  
  if IsCurrentSpell(6603) == false then
    WowCyborg_CURRENTATTACK = "Attack";
    return SetSpellRequest(attack);
  end

  if ctBuff then
    if IsCastableAtEnemyTarget("Chaos Strike", 40) or IsCastableAtEnemyTarget("Annihilation", 70) then
      WowCyborg_CURRENTATTACK = "Chaos Strike";
      return SetSpellRequest(chaosStrike);
    end  
  end
  
  if IsCastableAtEnemyTarget("Eye Beam", 30) then
    WowCyborg_CURRENTATTACK = "Eye Beam";
    return SetSpellRequest(eyeBeam);
  end

  if CheckInteractDistance("target", 3) and IsCastable("Essence Break", 0) then
    WowCyborg_CURRENTATTACK = "Essence Break";
    return SetSpellRequest(essenceBreak);
  end

  if IsCastableAtEnemyTarget("Death Sweep", 15) or IsCastableAtEnemyTarget("Blade Dance", 15) then
    WowCyborg_CURRENTATTACK = "Blade Dance";
    return SetSpellRequest(bladeDance);
  end

  if IsCastableAtEnemyTarget("Chaos Strike", 40) or IsCastableAtEnemyTarget("Annihilation", 70) then
    WowCyborg_CURRENTATTACK = "Chaos Strike";
    return SetSpellRequest(chaosStrike);
  end

  if IsCastableAtEnemyTarget("Sigil of Flame", 0) then
    WowCyborg_CURRENTATTACK = "Sigil of Flame";
    return SetSpellRequest(sigilOfFlame);
  end

  if IsCastableAtEnemyTarget("Felblade", 0) then
    WowCyborg_CURRENTATTACK = "Felblade";
    return SetSpellRequest(felblade);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Disrupt", "target") == 1;
end

print("Demon hunter havoc rotation loaded");