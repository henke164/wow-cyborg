--[[
  Button    Spell
]]--

local sunfire = 5;
local moonfire = 5;
-- CAT form
local rake = 6;
local shred = 7;
local rip = 8;
local ferociousBite = 9;
local swipe = 0;

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function IsMelee()
  return IsSpellInRange("Shred") == 1;
end

function RenderCatRotation(aoe)
  if IsMelee() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local rakeDot = FindDebuff("target", "Rake");
  if rakeDot == nil then
    WowCyborg_CURRENTATTACK = "Rake";
    return SetSpellRequest(rake);
  end

  local points = GetComboPoints("player", "target");
  local ripDot, ripCd = FindDebuff("target", "Rip");
  if points == 5 then
    if ripDot == nil then
      WowCyborg_CURRENTATTACK = "Rip";
      return SetSpellRequest(rip);
    end
    
    WowCyborg_CURRENTATTACK = "Ferocious Bite";
    return SetSpellRequest(ferociousBite);
  end

  if aoe then
    if IsCastableAtEnemyTarget("Swipe", 0) then
      WowCyborg_CURRENTATTACK = "Swipe";
      return SetSpellRequest(swipe);
    end
  else
    if IsCastableAtEnemyTarget("Shred", 0) then
      WowCyborg_CURRENTATTACK = "Shred";
      return SetSpellRequest(shred);
    end
  end
end

function RenderSingleTargetRotation(disableAutoTarget)
  local cat = FindBuff("player", "Cat Form");
  if cat ~= nil then
    return RenderCatRotation(false);
  end

  if UnitChannelInfo("player") == "Tranquility" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local sfDebuff = FindDebuff("target", "Sunfire");
  if sfDebuff == nil and IsCastableAtEnemyTarget("Sunfire", 0) then
    WowCyborg_CURRENTATTACK = "Sunfire";
    return SetSpellRequest(sunfire);
  end
  
  local mfDebuff = FindDebuff("target", "Moonfire");
  if mfDebuff == nil and IsCastableAtEnemyTarget("Moonfire", 0) then
    WowCyborg_CURRENTATTACK = "Moonfire";
    return SetSpellRequest(moonfire);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Horrific Resto druid rotation loaded");