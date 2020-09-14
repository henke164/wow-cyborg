--[[
  Button    Spell
]]--

local implosion = "1";
local demonicStrength = "2";
local callDreadStalkers = "3";
local handOfGulDan = "4";
local demonbolt = "5";
local shadowbolt = "6";
local soulStrike = "7";
local healthFunnel = "8";
local switchCounter = 0;

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  local petHp = GetHealthPercentage("pet")
  if petHp ~= nil and petHp > 2 and petHp < 50 then
    if UnitChannelInfo("player") == "Health Funnel" then
      WowCyborg_CURRENTATTACK = "-";
      return SetSpellRequest(nil);
    end

    WowCyborg_CURRENTATTACK = "Heal"
    return SetSpellRequest(healthFunnel)
  end

  local shards = UnitPower("player", 7);
  if IsCastableAtEnemyTarget("Implosion", 0) then
    WowCyborg_CURRENTATTACK = "Implosion";
    return SetSpellRequest("1");
  end
  
  if IsCastableAtEnemyTarget("Demonic Strength", 0) then
    WowCyborg_CURRENTATTACK = "Demonic Strength";
    return SetSpellRequest("2");
  end
  
  if IsCastableAtEnemyTarget("Soul Strike", 0) then
    WowCyborg_CURRENTATTACK = "Soul Strike";
    return SetSpellRequest("7");
  end
  
  if shards > 1 and IsCastableAtEnemyTarget("Call Dreadstalkers", 0) then
    WowCyborg_CURRENTATTACK = "Call Dreadstalkers";
    return SetSpellRequest("3");
  end
  
  if shards >= 4 and IsCastableAtEnemyTarget("Hand of Gul'dan", 0) then
    WowCyborg_CURRENTATTACK = "Hand of Gul'dan";
    return SetSpellRequest("4");
  end

  local dcBuff = FindBuff("player", "Demonic Core")

  if dcBuff ~= nil and IsCastableAtEnemyTarget("Demonbolt", 0) then
    WowCyborg_CURRENTATTACK = "Demonbolt";
    return SetSpellRequest("5");
  end

  if shards == 3 and IsCastableAtEnemyTarget("Hand of Gul'dan", 0) then
    WowCyborg_CURRENTATTACK = "Hand of Gul'dan";
    return SetSpellRequest("4");
  end
  
  if IsCastableAtEnemyTarget("Shadow Bolt", 0) then
    WowCyborg_CURRENTATTACK = "Shadow Bolt";
    return SetSpellRequest(shadowbolt);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Demo lock rotation loaded");