--[[
  Button    Spell
]]--

local unstableAffliction = "1";
local agony = "2";
local corruption = "3";
local maleficRapture = "5";
local soulRot = "5";
local phantom = "6";
local haunt = "7";
local drainLife = "8";
local rapidContagion = "9";
local shadowbolt = "F+7";
local deathbolt = "F+6";
local darkglare = "F+8";

local interruptArena1 = "CTRL+1";
local interruptArena2 = "CTRL+2";
local interruptArena3 = "CTRL+3";

WowCyborg_PAUSE_KEYS = {
  "F",
  "F2",
  "F3",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD3",
  "LSHIFT",
  "NUMPAD8",
  "NUMPAD5"
}

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(skipslow)
  local hp = GetHealthPercentage("player");
  local bfStarted, bfTotalCd = GetSpellCooldown("Blood Fury");
  local bfCd = bfStarted + bfTotalCd - GetTime();

  local isBursting = FindBuff("player", "Blood Fury") ~= nil or bfCd > 30;
  local inevitBuff, inevitTl, inevitStacks = FindBuff("player", "Inevitable Demise");

  local shards = UnitPower("player", 7);
  local speed = GetUnitSpeed("player");
  
  if UnitChannelInfo("player") then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if UnitChannelInfo("arena1") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "Interrupt 1";
    return SetSpellRequest(interruptArena1);
  end
  
  if UnitChannelInfo("arena2") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "Interrupt 2";
    return SetSpellRequest(interruptArena2);
  end

  if UnitChannelInfo("arena3") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "Interrupt 3";
    return SetSpellRequest(interruptArena3);
  end

  if UnitChannelInfo("player") == "Drain Life" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local coe = FindDebuff("target", "Curse of Exhaustion");
  local bof = FindBuff("target", "Blessing of Freedom");
  local bstorm = FindBuff("target", "Bladestorm");
  local corruptionDebuff = FindDebuff("target", "Corruption");

  if skipslow == nil then
    if (coe == nil and bof == nil and bstorm == nil and speed ~= 0) then
      if IsCastableAtEnemyTarget("Curse of Exhaustion", 0) then
        WowCyborg_CURRENTATTACK = "Curse of Exhaustion";
        return SetSpellRequest("0");
      end
    end
  end
  
  local nf = FindBuff("player", "Nightfall");
  if nf and IsCastableAtEnemyTarget("Shadow Bolt", 0) then
    WowCyborg_CURRENTATTACK = "Shadow Bolt";
    return SetSpellRequest(shadowbolt);
  end

  local agonyDebuff, agonyTl, agonyStacks = FindDebuff("target", "Agony");

  if agonyDebuff == nil or agonyTl < 8 then
    if IsCastableAtEnemyTarget("Agony", 0) then
      WowCyborg_CURRENTATTACK = "Agony";
      return SetSpellRequest(agony);
    end
  end

  if speed == 0 then
    if hp < 70 and (inevitBuff ~= nil and inevitStacks > 20) then 
      if IsCastableAtEnemyTarget("Drain Life", 0) then
        WowCyborg_CURRENTATTACK = "Drain Life";
        return SetSpellRequest(drainLife);
      end
    end
    
    local uaDebuff, uaTl = FindDebuff("target", "Unstable Affliction");
    if uaDebuff == nil or uaTl < 5 then
      local castingInfo = UnitCastingInfo("player");
      if castingInfo == "Unstable Affliction" then
        WowCyborg_CURRENTATTACK = "-";
        return SetSpellRequest(nil);
      end
  
      if IsCastableAtEnemyTarget("Unstable Affliction", 0) then
        WowCyborg_CURRENTATTACK = "Unstable Affliction";
        return SetSpellRequest(unstableAffliction);
      end
    end  
  end

  if corruptionDebuff == nil then
    if IsCastableAtEnemyTarget("Corruption", 0) then
      WowCyborg_CURRENTATTACK = "Corruption";
      return SetSpellRequest(corruption);
    end
  end

  if isBursting and IsCastableAtEnemyTarget("Agony", 0) and agonyDebuff ~= nil then
    if IsCastable("Rapid Contagion", 0) and shards > 2 then
      WowCyborg_CURRENTATTACK = "Rapid Contagion";
      return SetSpellRequest(rapidContagion);
    end

    if IsCastableAtEnemyTarget("Phantom Singularity", 0) then
      WowCyborg_CURRENTATTACK = "Phantom Singularity";
      return SetSpellRequest(phantom);
    end

    if IsCastable("Summon Darkglare", 0) then
      WowCyborg_CURRENTATTACK = "Summon Darkglare";
      return SetSpellRequest(darkglare);
    end
  end

  if IsCastableAtEnemyTarget("Haunt", 0) then
    WowCyborg_CURRENTATTACK = "Haunt";
    return SetSpellRequest(haunt);
  end

  local torment = FindBuff("player", "Tormented Crescendo") ~= nil;
  if torment and IsCastableAtEnemyTarget("Malefic Rapture", 0) then
    WowCyborg_CURRENTATTACK = "Malefic Rapture";
    return SetSpellRequest(maleficRapture);
  end

  if speed == 0 and shards > 0 then
    local saveForContagion = false;
    if IsCastable("Rapid Contagion", 0) then
      local rcStarted, rcTotalCd = GetSpellCooldown("Rapid Contagion");
      local rcCd = rcStarted + rcTotalCd - GetTime();
      if isBursting and agonyDebuff ~= nil and rcCd < 2 then
        saveForContagion = true;
      end
    end

    if saveForContagion == false and shards > 2 then
      if IsCastableAtEnemyTarget("Deathbolt", 0) then
        WowCyborg_CURRENTATTACK = "Deathbolt";
        return SetSpellRequest(deathbolt);
      end
      
      if IsCastableAtEnemyTarget("Agony", 0) and IsCastableAtEnemyTarget("Malefic Rapture", 0) then
        WowCyborg_CURRENTATTACK = "Malefic Rapture";
        return SetSpellRequest(maleficRapture);
      end
    end
  end

  if speed == 0 then
    if hp < 70 and (inevitBuff ~= nil and inevitStacks > 20) then 
      if IsCastableAtEnemyTarget("Drain Life", 0) then
        WowCyborg_CURRENTATTACK = "Drain Life";
        return SetSpellRequest(drainLife);
      end
    end
    
    if inevitBuff ~= nil and inevitStacks == 50 then 
      if IsCastableAtEnemyTarget("Drain Life", 0) then
        WowCyborg_CURRENTATTACK = "Drain Life";
        return SetSpellRequest(drainLife);
      end
    end
  else
    if IsCastableAtEnemyTarget("Agony", 0) and agonyStacks < 10 then
      WowCyborg_CURRENTATTACK = "Agony";
      return SetSpellRequest(agony);
    end
  end

  if IsCastableAtEnemyTarget("Shadow Bolt", 0) then
    WowCyborg_CURRENTATTACK = "Shadow Bolt";
    return SetSpellRequest(shadowbolt);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Affli lock rotation loaded");