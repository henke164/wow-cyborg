--[[
Button    Spell
local moonfire = "1";
local sunfire = "2";
local starfire = "3";
local wrath = "4";
local starsurge = "7";
]]--

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "F5",
  "F10",
  "NUMPAD5",
  "NUMPAD7",
  "F2",
  "F",
  "R"
}

local moonfire = "1";
local sunfire = "2";
local starfire = "3";
local wrath = "4";
local starfall = "6";
local starsurge = "7";
local loneEmpowerment = "8";

-- Bear form
local mangle = 2;
local frenziedRegen = 3;
local ironFur = 4;

local shootStarsurge = false;

function RenderBearRotation()
  local hp = GetHealthPercentage("player");
  if hp < 70 then
    if IsCastable("Frenzied Regeneration", 10) then
      WowCyborg_CURRENTATTACK = "Frenzied Regeneration";
      return SetSpellRequest(frenziedRegen);
    end
    
    if IsCastable("Ironfur", 40) then
      WowCyborg_CURRENTATTACK = "Ironfur";
      return SetSpellRequest(ironFur);
    end    
  end
  
  if IsCastableAtEnemyTarget("Mangle", 0) then
    WowCyborg_CURRENTATTACK = "Mangle";
    return SetSpellRequest(mangle);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(aoe)
  
  local form = FindBuff("player", "Moonkin Form");
  if form == nil then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local bear = FindBuff("player", "Bear Form");
  if bear ~= nil then
    return RenderBearRotation();
  end

  local channelInfo = UnitChannelInfo("player");
  local castingInfo = UnitCastingInfo("player");

  if channelInfo == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "BURSTING";
    return SetSpellRequest(nil);
  end

  -- Handle dots
  local dot, dotTl = FindDebuff("target", "Moonfire");
  if (dot == nil or dotTl < 4) and IsCastableAtEnemyTarget("Moonfire", 0) then
    WowCyborg_CURRENTATTACK = "Moonfire";
    return SetSpellRequest(moonfire);
  end
  
  local dot2, dot2Tl = FindDebuff("target", "Sunfire");
  if (dot2 == nil or dot2Tl < 4) and IsCastableAtEnemyTarget("Sunfire", 0) then
    WowCyborg_CURRENTATTACK = "Sunfire";
    return SetSpellRequest(sunfire);
  end

  local starfallBuff, starfallBuffTl = FindBuff("player", "Starfall");

  local burstCd = GetSpellCooldown("Celestial Alignment", "spell");

  if burstCd > 60 then
    if IsCastableAtEnemyTarget("Starsurge", 0) and (IsCastable("Lone Empowerment", 0) or IsCastable("Empower Bond", 0)) then
      WowCyborg_CURRENTATTACK = "Lone Empowerment";
      return SetSpellRequest(loneEmpowerment);
    end
  end

  local frenzy = FindBuff("player", "Moonkin Frenzy");
  if frenzy ~= nil then
    if IsCastableAtEnemyTarget("Starsurge", 0) then
      WowCyborg_CURRENTATTACK = "Starsurge";
      return SetSpellRequest(starsurge);
    end
  end

  if aoe then
    if (starfallBuff == nil or starfallBuffTl < 3) and IsCastableAtEnemyTarget("Starfall", 50) then
      WowCyborg_CURRENTATTACK = "Starfall";
      return SetSpellRequest(starfall);
    end
  end

  local speed = GetUnitSpeed("player");
  if aoe == nil and speed > 0 then
    if IsCastableAtEnemyTarget("Starsurge", 30) then
      WowCyborg_CURRENTATTACK = "Starsurge";
      return SetSpellRequest(starsurge);
    end
  end

  if shootStarsurge and IsCastableAtEnemyTarget("Starsurge", 30) then
    WowCyborg_CURRENTATTACK = "Starsurge";
    return SetSpellRequest(starsurge);
  end

  local astralPower = UnitPower("player");
  if astralPower >= 60 then
    shootStarsurge = true;
  end

  if astralPower < 30 then
    shootStarsurge = false;
  end
  
  local solar = FindBuff("player", "Eclipse (Solar)");
  if solar ~= nil then
    if speed > 0 then
      if IsCastableAtEnemyTarget("Sunfire", 0) then
        WowCyborg_CURRENTATTACK = "Sunfire";
        return SetSpellRequest(sunfire);
      end
    end

    if IsCastableAtEnemyTarget("Wrath", 0) then
      WowCyborg_CURRENTATTACK = "Wrath";
      return SetSpellRequest(wrath);
    end
  end
  
  local lunar = FindBuff("player", "Eclipse (Lunar)");
  if lunar ~= nil then
    if speed > 0 then
      if IsCastableAtEnemyTarget("Moonfire", 0) then
        WowCyborg_CURRENTATTACK = "Moonfire";
        return SetSpellRequest(moonfire);
      end
    end

    if IsCastableAtEnemyTarget("Starfire", 0) then
      WowCyborg_CURRENTATTACK = "Starfire";
      return SetSpellRequest(starfire);
    end
  end

  local starfireCount = GetSpellCount("Starfire");
  local wrathCount = GetSpellCount("Wrath");

  if starfireCount > 0 then
    if castingInfo == "Starfire" and starfireCount == 1 then
      if IsCastableAtEnemyTarget("Wrath", 0) then
        WowCyborg_CURRENTATTACK = "Wrath";
        return SetSpellRequest(wrath);
      end
    end

    if speed > 0 then
      if IsCastableAtEnemyTarget("Moonfire", 0) then
        WowCyborg_CURRENTATTACK = "Moonfire";
        return SetSpellRequest(moonfire);
      end
    end

    if IsCastableAtEnemyTarget("Starfire", 0) then
      WowCyborg_CURRENTATTACK = "Starfire";
      return SetSpellRequest(starfire);
    end
  end

  if wrathCount > 0 then
    if castingInfo == "Wrath" and wrathCount == 1 then
      if IsCastableAtEnemyTarget("Starfire", 0) then
        WowCyborg_CURRENTATTACK = "Starfire";
        return SetSpellRequest(starfire);
      end
    end

    if speed > 0 then
      if IsCastableAtEnemyTarget("Sunfire", 0) then
        WowCyborg_CURRENTATTACK = "Sunfire";
        return SetSpellRequest(sunfire);
      end
    end

    if IsCastableAtEnemyTarget("Wrath", 0) then
      WowCyborg_CURRENTATTACK = "Wrath";
      return SetSpellRequest(wrath);
    end
  end

  if speed > 0 then
    if IsCastableAtEnemyTarget("Moonfire", 0) then
      WowCyborg_CURRENTATTACK = "Moonfire";
      return SetSpellRequest(moonfire);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Boomkin rotation loaded");