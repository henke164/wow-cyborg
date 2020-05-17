--[[
  Button    Spell
]]--

local immolate = "1";
local chaosBolt = "2";
local cataclysm = "3";
local conflagrate = "4";
local incinerate = "5";

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  local immolateDebuff = FindDebuff("target", "Immolate"); 
  if immolateDebuff == nil then
    if IsCastableAtEnemyTarget("Immolate", 0) then
      WowCyborg_CURRENTATTACK = "Immolate";
      return SetSpellRequest(immolate);
    end
  end

  local shards = UnitPower("player", 7)
  if shards >= 4 then
    if IsCastableAtEnemyTarget("Chaos Bolt", 0) then
      WowCyborg_CURRENTATTACK = "Chaos Bolt";
      return SetSpellRequest(chaosBolt);
    end
  end

  if IsCastableAtEnemyTarget("Immolate", 0) and IsCastableAtEnemyTarget("Cataclysm", 0) then
    WowCyborg_CURRENTATTACK = "Cataclysm";
    return SetSpellRequest(cataclysm);
  end

  if IsCastableAtEnemyTarget("Conflagrate", 0) then
    WowCyborg_CURRENTATTACK = "Conflagrate";
    return SetSpellRequest(conflagrate);
  end

  if IsCastableAtEnemyTarget("Incinerate", 0) then
    WowCyborg_CURRENTATTACK = "Incinerate";
    return SetSpellRequest(incinerate);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Destro lock rotation loaded");