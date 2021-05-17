--[[
  Button    Spell
]]--

local implosion = "1";
local soulrot = "1";
local callDreadStalkers = "3";
local handOfGulDan = "4";
local demonbolt = "5";
local shadowbolt = "6";
local summonVileFiend = "7";
local felguard = "8";

WowCyborg_PAUSE_KEYS = {
  "F1",
}

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(aoe)

  local demonicPowerBuff = FindBuff("player", "Demonic Power");

  if demonicPowerBuff ~= nil then
    if IsCastable("Grimoire:Felguard", 0) then
      WowCyborg_CURRENTATTACK = "Grimoire:Felguard";
      return SetSpellRequest(felguard);
    end
  end

  local shards = UnitPower("player", 7);
  if aoe and IsCastableAtEnemyTarget("Implosion", 0) then
    WowCyborg_CURRENTATTACK = "Implosion";
    return SetSpellRequest("1");
  end
  
  local dcBuff, dcTl = FindBuff("player", "Demonic Core")

  if dcBuff ~= nil and dcTl < 5 then
    if IsCastableAtEnemyTarget("Demonbolt", 0) then
      WowCyborg_CURRENTATTACK = "Demonbolt";
      return SetSpellRequest("5");
    end
  end

  if IsCastableAtEnemyTarget("Soul Rot", 0) then
    WowCyborg_CURRENTATTACK = "Soul Rot";
    return SetSpellRequest("2");
  end
  
  if shards > 1 and IsCastableAtEnemyTarget("Call Dreadstalkers", 0) then
    WowCyborg_CURRENTATTACK = "Call Dreadstalkers";
    return SetSpellRequest("3");
  end
  
  if shards >= 4 and IsCastableAtEnemyTarget("Hand of Gul'dan", 0) then
    WowCyborg_CURRENTATTACK = "Hand of Gul'dan";
    return SetSpellRequest("4");
  end

  if dcBuff ~= nil and IsCastableAtEnemyTarget("Demonbolt", 0) then
    WowCyborg_CURRENTATTACK = "Demonbolt";
    return SetSpellRequest("5");
  end

  if shards >= 3 and IsCastableAtEnemyTarget("Hand of Gul'dan", 0) then
    WowCyborg_CURRENTATTACK = "Hand of Gul'dan";
    return SetSpellRequest("4");
  end
  
  if shards >= 1 and IsCastableAtEnemyTarget("Summon Vilefiend", 0) then
    WowCyborg_CURRENTATTACK = "Summon Vilefiend";
    return SetSpellRequest(summonVileFiend);
  end

  if IsCastableAtEnemyTarget("Shadow Bolt", 0) then
    if UnitCastingInfo("player") ~= "Shadow Bolt" then
      WowCyborg_CURRENTATTACK = "Shadow Bolt";
      return SetSpellRequest(shadowbolt);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Demo lock rotation loaded");