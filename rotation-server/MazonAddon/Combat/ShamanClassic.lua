--[[
  Button    Spell
]]--

local lightningBolt = "1";
local earthShock = "2";

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

-- Single target
function RenderSingleTargetRotation()
  local speed = GetUnitSpeed("player");

  if IsCastableAtEnemyTarget("Earth Shock", 15) then
    WowCyborg_CURRENTATTACK = "Earth Shock";
    return SetSpellRequest(earthShock);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Classic shaman rotation loaded!");