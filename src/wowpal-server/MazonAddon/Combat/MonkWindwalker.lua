--[[
  Button    Spell
  local fistOfTheWhiteTiger = "1";
  local tigerPalm = "2";
  local whirlinDragonPunch = "3";
  local fistsOfFury = "4";
  local risingSunKick = "5";
  local chiBurst = "6";
  local blackoutKick = "7";
  local spinningCraneKick = "8";
  local concentratedFlame = "9";
]]--

local fistOfTheWhiteTiger = "1";
local tigerPalm = "2";
local whirlinDragonPunch = "3";
local fistsOfFury = "4";
local risingSunKick = "5";
local chiBurst = "6";
local blackoutKick = "7";
local spinningCraneKick = "8";
local concentratedFlame = "9";

function IsMelee()
  return IsSpellInRange("Tiger Palm");
end

function RenderMultiTargetRotation()
  if IsMelee() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local chi = UnitPower("player", 12);
  
  if UnitChannelInfo("player") == "Fists of Fury" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if UnitChannelInfo("player") == "Spinning Crane Kick" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local bokBuff = FindBuff("player", "Blackout Kick!");
  
  if bokBuff then
    if IsCastableAtEnemyTarget("Blackout Kick", 0) then
      WowCyborg_CURRENTATTACK = "Blackout Kick";
      return SetSpellRequest(blackoutKick);
    end
  end

  if IsCastableAtEnemyTarget("Whirling Dragon Punch", 0) then
    WowCyborg_CURRENTATTACK = "WDragon Punch";
    return SetSpellRequest(whirlinDragonPunch);
  end
  
  if IsCastableAtEnemyTarget("Fists of Fury", 0) and chi > 2 then
    WowCyborg_CURRENTATTACK = "Fists of Fury";
    return SetSpellRequest(fistsOfFury);
  end
  
  if IsCastableAtEnemyTarget("Rising Sun Kick", 0) and chi > 1 then
    WowCyborg_CURRENTATTACK = "Rising Sun Kick";
    return SetSpellRequest(risingSunKick);
  end
  
  if IsCastableAtEnemyTarget("Chi Burst", 0) and chi < 5 then
    local speed = GetUnitSpeed("player");
    if speed == 0 then
      WowCyborg_CURRENTATTACK = "Chi Burst";
      return SetSpellRequest(chiBurst);
    end
  end

  if IsCastableAtEnemyTarget("Spinning Crane Kick", 0) and chi > 3 then
    WowCyborg_CURRENTATTACK = "Spinning Crane Kick";
    return SetSpellRequest(spinningCraneKick);
  end

  if IsCastableAtEnemyTarget("Rising Sun Kick", 0) and chi > 1 then
    WowCyborg_CURRENTATTACK = "Rising Sun Kick";
    return SetSpellRequest(risingSunKick);
  end
  
  if IsCastableAtEnemyTarget("Blackout Kick", 0) and chi > 1 then
    WowCyborg_CURRENTATTACK = "Blackout Kick";
    return SetSpellRequest(blackoutKick);
  end

  if IsCastableAtEnemyTarget("Fist of the White Tiger", 40) then
    WowCyborg_CURRENTATTACK = "Fotwt";
    return SetSpellRequest(fistOfTheWhiteTiger);
  end

  if IsCastableAtEnemyTarget("Tiger Palm", 50) then
    WowCyborg_CURRENTATTACK = "Tiger Palm";
    return SetSpellRequest(tigerPalm);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  if IsMelee() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if UnitChannelInfo("player") == "Fists of Fury" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local energy = UnitPower("player");
  local chi = UnitPower("player", 12);

  if IsCastableAtEnemyTarget("Concentrated Flame", 0) then
    WowCyborg_CURRENTATTACK = "Concentrated Flame";
    return SetSpellRequest(concentratedFlame);
  end

  if chi < 3 then
    if IsCastableAtEnemyTarget("Fist of the White Tiger", 60) then
      WowCyborg_CURRENTATTACK = "Fotwt";
      return SetSpellRequest(fistOfTheWhiteTiger);
    end
  end

  local bokBuff = FindBuff("player", "Blackout Kick!");

  if chi < 4 then
    if bokBuff then
      if IsCastableAtEnemyTarget("Blackout Kick", 0) then
        WowCyborg_CURRENTATTACK = "Blackout Kick";
        return SetSpellRequest(blackoutKick);
      end
    end

    if IsCastableAtEnemyTarget("Tiger Palm", 60) then
      WowCyborg_CURRENTATTACK = "Tiger Palm";
      return SetSpellRequest(tigerPalm);
    end
  end

  if IsCastableAtEnemyTarget("Whirling Dragon Punch", 0) then
    WowCyborg_CURRENTATTACK = "WDragon Punch";
    return SetSpellRequest(whirlinDragonPunch);
  end
  
  if IsCastableAtEnemyTarget("Fists of Fury", 0) and chi > 2 then
    WowCyborg_CURRENTATTACK = "Fists of Fury";
    return SetSpellRequest(fistsOfFury);
  end

  if IsCastableAtEnemyTarget("Rising Sun Kick", 0) and chi > 1 then
    WowCyborg_CURRENTATTACK = "Rising Sun Kick";
    return SetSpellRequest(risingSunKick);
  end

  if IsCastableAtEnemyTarget("Chi Burst", 0) and chi < 5 then
    local speed = GetUnitSpeed("player");
    if speed == 0 then
      WowCyborg_CURRENTATTACK = "Chi Burst";
      return SetSpellRequest(chiBurst);
    end
  end
  
  if IsCastableAtEnemyTarget("Blackout Kick", 0) and chi > 1 then
    WowCyborg_CURRENTATTACK = "Blackout Kick";
    return SetSpellRequest(blackoutKick);
  end

  if bokBuff then
    if IsCastableAtEnemyTarget("Blackout Kick", 0) then
      WowCyborg_CURRENTATTACK = "Blackout Kick";
      return SetSpellRequest(blackoutKick);
    end
  end

  if IsCastableAtEnemyTarget("Tiger Palm", 50) then
    WowCyborg_CURRENTATTACK = "Tiger Palm";
    return SetSpellRequest(tigerPalm);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Windwalker monk rotation loaded");