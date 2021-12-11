--[[
  Button    Spell
  local tigerPalm = "2";
  local whirlinDragonPunch = "3";
  local fistsOfFury = "4";
  local risingSunKick = "5";
  local chiBurst = "6";
  local blackoutKick = "7";
  local spinningCraneKick = "8";
]]--

local tigerPalm = "2";
local chiBurst = "3";
local fistsOfFury = "4";
local risingSunKick = "5";
local expelHarm = "6";
local blackoutKick = "7";
local spinningCraneKick = "8";
local whirlinDragonPunch = "9";
local fistOfTheWhiteTiger = "0";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "F4",
  "F10",
  "NUMPAD3",
  "NUMPAD8"
};

function IsMelee()
  return IsSpellInRange("Tiger Palm");
end

function RenderMultiTargetRotation()
  local energy = UnitPower("player");
  local chi = UnitPower("player", 12);
  local bokBuff = FindBuff("player", "Blackout Kick!");

  if CheckInteractDistance("target", 3) == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if UnitChannelInfo("player") == "Fists of Fury" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if IsCastableAtEnemyTarget("Whirling Dragon Punch", 0) then
    WowCyborg_CURRENTATTACK = "Whirling Dragon Punch";
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

  if IsCastableAtEnemyTarget("Chi Burst", 0) and chi < 6 then
    local speed = GetUnitSpeed("player");
    if speed == 0 then
      WowCyborg_CURRENTATTACK = "Chi Burst";
      return SetSpellRequest(chiBurst);
    end
  end

  if IsCastableAtEnemyTarget("Spinning Crane Kick", 0) and chi > 1 then
    WowCyborg_CURRENTATTACK = "Spinning Crane Kick";
    return SetSpellRequest(spinningCraneKick);
  end

  if chi > 0 or bokBuff then
    if IsCastableAtEnemyTarget("Blackout Kick", 0) then
      WowCyborg_CURRENTATTACK = "Blackout Kick";
      return SetSpellRequest(blackoutKick);
    end
  end
  
  if IsCastableAtEnemyTarget("Expel Harm", 15) then
    WowCyborg_CURRENTATTACK = "Expel Harm";
    return SetSpellRequest(expelHarm);
  end

  if IsCastableAtEnemyTarget("Tiger Palm", 50) then
    WowCyborg_CURRENTATTACK = "Tiger Palm";
    return SetSpellRequest(tigerPalm);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  local energy = UnitPower("player");
  local chi = UnitPower("player", 12);
  local bokBuff = FindBuff("player", "Blackout Kick!");
  
  if IsMelee() == 0 then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if UnitChannelInfo("player") == "Fists of Fury" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if chi < 3 then
    if IsCastableAtEnemyTarget("Fist of the White Tiger", 80) then
      WowCyborg_CURRENTATTACK = "Fist of the White Tiger";
      return SetSpellRequest(fistOfTheWhiteTiger);
    end
  end

  if chi < 5 then
    if IsCastableAtEnemyTarget("Expel Harm", 80) then
      WowCyborg_CURRENTATTACK = "Expel Harm";
      return SetSpellRequest(expelHarm);
    end
  end

  if chi < 4 then
    if IsCastableAtEnemyTarget("Tiger Palm", 80) then
      WowCyborg_CURRENTATTACK = "Tiger Palm";
      return SetSpellRequest(tigerPalm);
    end
  end

  if IsCastableAtEnemyTarget("Whirling Dragon Punch", 0) then
    WowCyborg_CURRENTATTACK = "Whirling Dragon Punch";
    return SetSpellRequest(whirlinDragonPunch);
  end

  local spinProc = FindBuff("player", "Dance of Chi-Ji");
  if IsCastableAtEnemyTarget("Spinning Crane Kick", 0) and spinProc ~= nil then
    WowCyborg_CURRENTATTACK = "Spinning Crane Kick";
    return SetSpellRequest(spinningCraneKick);
  end

  if IsCastableAtEnemyTarget("Rising Sun Kick", 0) then
    WowCyborg_CURRENTATTACK = "Rising Sun Kick";
    return SetSpellRequest(risingSunKick);
  end

  if bokBuff then
    if IsCastableAtEnemyTarget("Blackout Kick", 0) then
      WowCyborg_CURRENTATTACK = "Blackout Kick";
      return SetSpellRequest(blackoutKick);
    end
  end

  if IsCastableAtEnemyTarget("Fists of Fury", 0) then
    if chi < 3 then
      if IsCastableAtEnemyTarget("Expel Harm", 15) then
        WowCyborg_CURRENTATTACK = "Expel Harm";
        return SetSpellRequest(expelHarm);
      end
        
      if IsCastableAtEnemyTarget("Tiger Palm", 50) then
        WowCyborg_CURRENTATTACK = "Tiger Palm";
        return SetSpellRequest(tigerPalm);
      end
    end

    WowCyborg_CURRENTATTACK = "Fists of Fury";
    return SetSpellRequest(fistsOfFury);
  end

  if IsCastableAtEnemyTarget("Fist of the White Tiger", 0) then
    WowCyborg_CURRENTATTACK = "Fist of the White Tiger";
    return SetSpellRequest(fistOfTheWhiteTiger);
  end

  if IsCastableAtEnemyTarget("Chi Burst", 0) and chi < 6 then
    local speed = GetUnitSpeed("player");
    if speed == 0 then
      WowCyborg_CURRENTATTACK = "Chi Burst";
      return SetSpellRequest(chiBurst);
    end
  end

  if chi > 0 or bokBuff then
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