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
local attack = "3";
local eyeBeam = "4";
local immolationAura = "5";
local consumeMagic = "6";
local arcaneTorrent = "7";
local glavies = "8";
local felblade = "9";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "F7",
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

function IsMelee()
  return CheckInteractDistance("target", 5);
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true)
end

function RenderSingleTargetRotation(skipGlavie)
  local hp = GetHealthPercentage("player");
  local fodder = FindBuff("player", "Fodder to the Flame");
  local dispellable = HasDispellableBuff("target");

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

  if skipGlavie ~= true or (fodder == nil and IsMounted("player") == false) then
    if IsCastableAtEnemyTarget("Throw Glaive", 0) then
      WowCyborg_CURRENTATTACK = "Throw Glaive";
      return SetSpellRequest(glavies);
    end
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

  if UnitChannelInfo("player") == "Eye Beam" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if IsMelee() and IsCastable("Immolation Aura", 0) then
    WowCyborg_CURRENTATTACK = "Immolation Aura";
    return SetSpellRequest(immolationAura);
  end

  if IsCastableAtEnemyTarget("Eye Beam", 30) then
    WowCyborg_CURRENTATTACK = "Eye Beam";
    return SetSpellRequest(eyeBeam);
  end

  if IsCastableAtEnemyTarget("Death Sweep", 15) or IsCastableAtEnemyTarget("Blade Dance", 15) then
    WowCyborg_CURRENTATTACK = "Blade Dance";
    return SetSpellRequest(bladeDance);
  end

  if IsCastableAtEnemyTarget("Chaos Strike", 40) or IsCastableAtEnemyTarget("Annihilation", 70) then
    WowCyborg_CURRENTATTACK = "Chaos Strike";
    return SetSpellRequest(chaosStrike);
  end

  if IsCastableAtEnemyTarget("Felblade", 0) then
    WowCyborg_CURRENTATTACK = "Felblade";
    return SetSpellRequest(felblade);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Chaos Strike", "target") == 1;
end

print("Demon hunter havoc rotation loaded");