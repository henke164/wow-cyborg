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

local touchOfDeath = "1";
local tigerPalm = "2";
local fistOfTheWhiteTiger = "3";
local fistsOfFury = "4";
local risingSunKick = "5";
local expelHarm = "6";
local blackoutKick = "7";
local spinningCraneKick = "8";
local whirlinDragonPunch = "9";
local disable = "0";
local ancestralCall = "F+5";
local invokexuen = "F+6";
local stormEarthFire = "F+7";
local usedKeefersAt = 0;

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "F4",
  "F10",
  "NUMPAD3",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "§"
};

function IsMelee()
  return IsSpellInRange("Tiger Palm");
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function keeferReady()
  return GetTime() - usedKeefersAt > 54;
end

function RenderSingleTargetRotation(skipSnare)
  local energy = UnitPower("player");
  local chi = UnitPower("player", 12);
  local bokBuff = FindBuff("player", "Blackout Kick!");
  local freeSpin = FindBuff("player", "Dance of Chi-Ji");
  local stormCharges = GetSpellCharges("Storm, Earth, and Fire");
  local disabled, disabledTl = FindDebuff("target", "Disable");

  if IsCastableAtEnemyTarget("Touch of Death", 0) then
    WowCyborg_CURRENTATTACK = "Touch of Death";
    return SetSpellRequest(touchOfDeath);
  end

  if CheckInteractDistance("target", 3) == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if UnitChannelInfo("player") ~= nil then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local brewStart, brewDuration = GetSpellCooldown("Bonedust Brew");
  local brewCd = brewStart + brewDuration - GetTime();
  local brewed = FindDebuff("target", "Bonedust Brew");
  local keefers = FindDebuff("target", "Keefer's Skyreach");
  local saveChi = brewCd < 1;

  if keefers then
    usedKeefersAt = GetTime();
  end

  if brewed then
    if IsCastable("Ancestral Call", 0) then
      WowCyborg_CURRENTATTACK = "Ancestral Call";
      return SetSpellRequest(ancestralCall);
    end

    if IsCastableAtEnemyTarget("Invoke Xuen, the White Tiger", 0) then
      WowCyborg_CURRENTATTACK = "Invoke Xuen";
      return SetSpellRequest(invokexuen);
    end

    local stormBuff = FindBuff("player", "Storm, Earth, and Fire");
    if stormBuff == nil and IsCastableAtEnemyTarget("Storm, Earth, and Fire", 0) then
      WowCyborg_CURRENTATTACK = "Storm, Earth, and Fire";
      return SetSpellRequest(stormEarthFire);
    end

    if IsCastableAtEnemyTarget("Invoke Xuen, the White Tiger", 0) then
      WowCyborg_CURRENTATTACK = "Invoke Xuen";
      return SetSpellRequest(invokexuen);
    end
    
    if keeferReady() then
      if IsCastableAtEnemyTarget("Tiger Palm", 50) then
        WowCyborg_CURRENTATTACK = "Tiger Palm";
        return SetSpellRequest(tigerPalm);
      end
    end

    if keefers then
      if IsCastableAtEnemyTarget("Rising Sun Kick", 0) and chi > 1 then
        WowCyborg_CURRENTATTACK = "Rising Sun Kick";
        return SetSpellRequest(risingSunKick);
      end
    end
  end

  if chi < 3 then
    if IsCastableAtEnemyTarget("Fist of the White Tiger", 40) then
      WowCyborg_CURRENTATTACK = "Fist of the White Tiger";
      return SetSpellRequest(fistOfTheWhiteTiger);
    end
  end

  local freedomBuff = FindBuff("target", "Blessing of Freedom");
  local bsBuff = FindBuff("target", "Bladestorm");
  if skipSnare ~= true then
    if freedomBuff == nil and bsBuff == nil and (disabled == nil or disabledTl < 2) then
      if IsCastableAtEnemyTarget("Disable", 0) then
        WowCyborg_CURRENTATTACK = "Disable";
        return SetSpellRequest(disable);
      end
    end
  end

  if IsCastableAtEnemyTarget("Whirling Dragon Punch", 0) then
    WowCyborg_CURRENTATTACK = "Whirling Dragon Punch";
    return SetSpellRequest(whirlinDragonPunch);
  end

  if saveChi == false and IsCastableAtEnemyTarget("Fists of Fury", 0) and chi > 2 then
    WowCyborg_CURRENTATTACK = "Fists of Fury";
    return SetSpellRequest(fistsOfFury);
  end
  
  if saveChi == false and IsCastableAtEnemyTarget("Rising Sun Kick", 0) and chi > 1 then
    WowCyborg_CURRENTATTACK = "Rising Sun Kick";
    return SetSpellRequest(risingSunKick);
  end

  if IsCastableAtEnemyTarget("Spinning Crane Kick", 0) and ((saveChi == false and chi > 1) or freeSpin) then
    WowCyborg_CURRENTATTACK = "Spinning Crane Kick";
    return SetSpellRequest(spinningCraneKick);
  end

  if (saveChi == false and chi > 0) or bokBuff ~= nil then
    if IsCastableAtEnemyTarget("Blackout Kick", 0) then
      WowCyborg_CURRENTATTACK = "Blackout Kick";
      return SetSpellRequest(blackoutKick);
    end
  end
  
  if IsCastableAtEnemyTarget("Expel Harm", 15) then
    WowCyborg_CURRENTATTACK = "Expel Harm";
    return SetSpellRequest(expelHarm);
  end

  if keeferReady() == false and IsCastableAtEnemyTarget("Tiger Palm", 50) then
    WowCyborg_CURRENTATTACK = "Tiger Palm";
    return SetSpellRequest(tigerPalm);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Windwalker monk pvp rotation loaded");