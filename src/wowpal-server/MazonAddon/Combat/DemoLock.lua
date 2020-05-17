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

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()  
  if IsCastableAtEnemyTarget("Implosion", 0) then
    WowCyborg_CURRENTATTACK = "Implosion";
    return SetSpellRequest(implosion);
  end
  
  if IsCastableAtEnemyTarget("Demonic Strength", 0) then
    WowCyborg_CURRENTATTACK = "Demonic Strength";
    return SetSpellRequest(demonicStrength);
  end
  
  if IsCastableAtEnemyTarget("Soul Strike", 0) then
    WowCyborg_CURRENTATTACK = "Soul Strike";
    return SetSpellRequest(soulStrike);
  end
  
  if IsCastableAtEnemyTarget("Call Dreadstalkers", 0) then
    WowCyborg_CURRENTATTACK = "Call Dreadstalkers";
    return SetSpellRequest(callDreadStalkers);
  end
  
  local shards = UnitPower("player", 7)
  if shards >= 4 and IsCastableAtEnemyTarget("Hand of Gul'dan", 0) then
    WowCyborg_CURRENTATTACK = "Hand of Gul'dan";
    return SetSpellRequest(handOfGulDan);
  end

  local buff, _, _, charges = FindBuff("player", "Demonic Core")

  if charges == nil then
    charges = 0;
  end

  if charges >= 2 then
    if IsCastableAtEnemyTarget("Demonbolt", 0) then
      WowCyborg_CURRENTATTACK = "Demonbolt";
      return SetSpellRequest(demonbolt);
    end
  end

  if shards == 3 and IsCastableAtEnemyTarget("Hand of Gul'dan", 0) then
    WowCyborg_CURRENTATTACK = "Hand of Gul'dan";
    return SetSpellRequest(handOfGulDan);
  end
  
  if IsSpellInRange("Shadow Bolt", "target") and 
    UnitCanAttack("player", "target") and
    TargetIsAlive() then
      WowCyborg_CURRENTATTACK = "Shadow Bolt";
      return SetSpellRequest(shadowbolt);
  end

  WowCyborg_CURRENTATTACK = "- Nothing";
  return SetSpellRequest(nil);
end

print("Demo lock rotation loaded");