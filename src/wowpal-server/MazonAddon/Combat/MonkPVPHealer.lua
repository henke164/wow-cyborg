--[[
  Button    Spell
  local risingSunKick = "7";
  local blackoutKick = "8";
  local tigerPalm = "9";
]]--

local risingSunKick = "7";
local blackoutKick = "8";
local tigerPalm = "9";

function IsMelee()
  return IsSpellInRange("Tiger Palm");
end

function RenderMultiTargetRotation()
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  if IsMelee() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local cranebuff = FindBuff("player", "Way of the Crane");
  if cranebuff == nil then
    WowCyborg_CURRENTATTACK = "Not bursting";
    return SetSpellRequest(nil);
  end

  local energy = UnitPower("player");

  if IsCastableAtEnemyTarget("Rising Sun Kick", 0) then
    WowCyborg_CURRENTATTACK = "Rising Sun Kick";
    return SetSpellRequest(risingSunKick);
  end

  if IsCastableAtEnemyTarget("Blackout Kick", 0) then
    WowCyborg_CURRENTATTACK = "Blackout Kick";
    return SetSpellRequest(blackoutKick);
  end

  if IsCastableAtEnemyTarget("Tiger Palm", 60) then
    WowCyborg_CURRENTATTACK = "Tiger Palm";
    return SetSpellRequest(tigerPalm);
  end


  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("PVP monk rotation loaded");