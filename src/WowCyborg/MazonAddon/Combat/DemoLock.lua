--[[
  Button    Spell
]]--

local implosion = "1";
local decimatingBolt = "2";
local callDreadStalkers = "3";
local handOfGulDan = "4";
local demonbolt = "5";
local shadowbolt = "6";
local demonicStrength = "7";
local powerSiphon = "8";
local curseOfExhaustion = "F+6";

WowCyborg_PAUSE_KEYS = {
  "LSHIFT",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "F1",
  "F4",
  "F",
  "§"
}

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  local speed = GetUnitSpeed("player");
  local demonicPowerBuff = FindBuff("player", "Demonic Power");
  local felObeliskBuff = FindBuff("player", "Fel Obelisk");

  if UnitChannelInfo("player") == "Drain Life" then
    WowCyborg_CURRENTATTACK = "Draining life";
    return SetSpellRequest(nil);
  end
  
  if UnitChannelInfo("player") == "Fleshcraft" then
    WowCyborg_CURRENTATTACK = "Fleshcraft";
    return SetSpellRequest(nil);
  end

  if demonicPowerBuff ~= nil then
    if IsCastable("Grimoire:Felguard", 0) then
      WowCyborg_CURRENTATTACK = "Grimoire:Felguard";
      return SetSpellRequest(felguard);
    end
  end

  if felObeliskBuff ~= nil then
    if IsCastable("Blood Fury", 0) then
      WowCyborg_CURRENTATTACK = "Blood Fury";
      return SetSpellRequest("9");
    end
  end

  local shards = UnitPower("player", 7);
  local targetHp = GetHealthPercentage("target");

  if targetHp < 10 and IsCastableAtEnemyTarget("Implosion", 0) then
    WowCyborg_CURRENTATTACK = "Implosion";
    return SetSpellRequest(implosion);
  end
  
  local dcBuff, dcTl, dcStacks = FindBuff("player", "Demonic Core");

  if dcBuff ~= nil and (speed == 1 or shards < 5) then
    if IsCastableAtEnemyTarget("Demonbolt", 0) then
      WowCyborg_CURRENTATTACK = "Demonbolt";
      return SetSpellRequest(demonbolt);
    end
  else
    if IsCastableAtEnemyTarget("Demonbolt", 0) and IsCastable("Power Siphon", 0) then
      WowCyborg_CURRENTATTACK = "Power Siphon";
      return SetSpellRequest(powerSiphon);
    end
  end

  if IsCastableAtEnemyTarget("Demonic Strength", 0) then
    local petHp = GetHealthPercentage("pet");
    local isFelstorming = FindBuff("pet", "Felstorm");
    if petHp ~= nil and isFelstorming == nil then
      WowCyborg_CURRENTATTACK = "Demonic Strength";
      return SetSpellRequest(demonicStrength);
    end
  end
  
  if shards > 1 and IsCastableAtEnemyTarget("Call Dreadstalkers", 0) then
    WowCyborg_CURRENTATTACK = "Call Dreadstalkers";
    return SetSpellRequest(callDreadStalkers);
  end
  
  if speed == 0 and shards >= 4 and IsCastableAtEnemyTarget("Hand of Gul'dan", 0) then
    WowCyborg_CURRENTATTACK = "Hand of Gul'dan";
    return SetSpellRequest(handOfGulDan);
  end

  if dcBuff ~= nil and IsCastableAtEnemyTarget("Demonbolt", 0) then
    WowCyborg_CURRENTATTACK = "Demonbolt";
    return SetSpellRequest(demonbolt);
  end

  if speed == 0 and shards >= 3 and IsCastableAtEnemyTarget("Hand of Gul'dan", 0) then
    WowCyborg_CURRENTATTACK = "Hand of Gul'dan";
    return SetSpellRequest(handOfGulDan);
  end
  
  if speed == 0 and IsCastableAtEnemyTarget("Decimating Bolt", 0) then
    if UnitCastingInfo("player") ~= "Decimating Bolt" then
      WowCyborg_CURRENTATTACK = "Decimating Bolt";
      return SetSpellRequest(decimatingBolt);
    end
  end

  if speed == 0 and IsCastableAtEnemyTarget("Shadow Bolt", 0) then
    if UnitCastingInfo("player") ~= "Shadow Bolt" then
      WowCyborg_CURRENTATTACK = "Shadow Bolt";
      return SetSpellRequest(shadowbolt);
    end
  end

  if speed > 0 then
    local exhaust = FindDebuff("target", "Curse of Exhaustion");
    if exhaust == nil then
      if IsCastableAtEnemyTarget("Curse of Exhaustion", 0) then
        WowCyborg_CURRENTATTACK = "Curse of Exhaustion";
        return SetSpellRequest(curseOfExhaustion);
      end
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Demo lock rotation loaded");