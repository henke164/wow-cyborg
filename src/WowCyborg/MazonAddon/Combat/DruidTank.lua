--[[
  Button    Spell
]]--
WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "F5",
  "F6",
  "F7",
  "9",
  "R",
  "F",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "§"
}

local moonfire = "1";
local thrash = "2";
local mangle = "3";
local ironfur = "4";
local swipe = "5";
local frenziedRegeneration = "6";
local maul = "7";
local adaptiveSwarm = "8";
local sunfire = "2";
local starfire = "3";
local wrath = "4";
local starsurge = "5";

local incomingDamage = {}
local meleeDamageInLast5Seconds = 0
local rangedDamageInLast5Seconds = 0

function IsMelee()
  return IsSpellInRange("Maul");
end

function IsCastableAtEnemyName(spellName, target)
  if IsSpellInRange(spellName, target) == 0 then
    return false;
  end
  
  if UnitCanAttack("player", target) == false then
    return false;
  end

  if TargetIsAlive() == false then
    return false;
  end;

  return IsCastable(spellName, 0);
end

function GetTowerResult()
  local castingInfo = UnitCastingInfo("Focus");
  if castingInfo == "Twisted Reflection" then
    if IsCastableAtEnemyName("Skull Bash", "Focus") then
      WowCyborg_CURRENTATTACK = "Interrupt Twisted Reflection";
      return SetSpellRequest("F+5");
    end
  end
  
  if castingInfo == "Drain Life" then
    if IsCastableAtEnemyName("Skull Bash", "Focus") then
      WowCyborg_CURRENTATTACK = "Interrupt Drain Life";
      return SetSpellRequest("F+5");
    end
  end

  for i = 1, 40 do
    if UnitExists('nameplate' .. i) and CheckInteractDistance("nameplate"..i, 1) == true and UnitCanAttack("player", 'nameplate' .. i) then
      local castingInfo, _, __, ___, castingEndTime = UnitCastingInfo("nameplate"..i);
      if castingInfo == "Nether Storm" then
        local finish = castingEndTime / 1000 - GetTime();
        if finish < 1.7 then
          if IsCastable("Incapacitating Roar", 0) then
            WowCyborg_CURRENTATTACK = "Incapacitating Roar";
            return SetSpellRequest("F+2");
          end
        end

        if IsCastable("Thrash", 0) then
          WowCyborg_CURRENTATTACK = "Thrash";
          return SetSpellRequest(thrash);
        end

        if IsCastable("Swipe", 0) then
          WowCyborg_CURRENTATTACK = "Swipe";
          return SetSpellRequest(swipe);
        end
      end

          
      if UnitChannelInfo("nameplate"..i) == "Nether Storm" then
        if IsCastable("Incapacitating Roar", 0) then
          WowCyborg_CURRENTATTACK = "Incapacitating Roar";
          return SetSpellRequest("F+2");
        end
      end

    end
  end
end

function RenderBoomkinRotation()
  local ggBuff = FindBuff("player", "Galactic Guardian");
  local dot, dotTl = FindDebuff("target", "Moonfire");
  if (dot == nil or dotTl < 2) and IsCastableAtEnemyTarget("Moonfire", 0) then
    WowCyborg_CURRENTATTACK = "Moonfire";
    return SetSpellRequest(moonfire);
  end
  
  local dot2, dot2Tl = FindDebuff("target", "Sunfire");
  if (dot2 == nil or dot2Tl < 2) and IsCastableAtEnemyTarget("Sunfire", 0) then
    WowCyborg_CURRENTATTACK = "Sunfire";
    return SetSpellRequest(sunfire);
  end

  local speed = GetUnitSpeed("player");
  local hotw = FindBuff("player", "Heart of the Wild");

  if (speed == 0 or hotw ~= nil) and IsCastableAtEnemyTarget("Starsurge", 30) then
    WowCyborg_CURRENTATTACK = "Starsurge";
    return SetSpellRequest(starsurge);
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
  else
    if IsCastableAtEnemyTarget("Moonfire", 0) then
      WowCyborg_CURRENTATTACK = "Moonfire";
      return SetSpellRequest(moonfire);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderMultiTargetRotation()
  local towerResult = GetTowerResult();
  if towerResult then
    return towerResult;
  end

  if UnitChannelInfo("player") == "Fleshcraft" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if UnitChannelInfo("player") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local moonkin = FindBuff("player", "Moonkin Form");
  if moonkin ~= nil then
    return RenderBoomkinRotation();
  end
  
  local bear = FindBuff("player", "Bear Form");
  if bear == nil then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local hp = GetHealthPercentage("player");
  local targetHp = GetHealthPercentage("target");

  if hp < 70 then
    local regenBuff = FindBuff("player", "Frenzied Regeneration");
    if regenBuff == nil and IsCastableAtEnemyTarget("Frenzied Regeneration", 10) then
      WowCyborg_CURRENTATTACK = "Frenzied Regeneration";
      return SetSpellRequest(frenziedRegeneration);
    end
  end

  if IsCastableAtEnemyTarget("Adaptive Swarm", 0) then
    WowCyborg_CURRENTATTACK = "Adaptive Swarm";
    return SetSpellRequest(adaptiveSwarm);
  end


  local ggBuff = FindBuff("player", "Galactic Guardian");
  local moonfireDot = FindDebuff("target", "Moonfire");

  if IsMelee() == 0 then
    if (moonfireDot == nil and IsCastableAtEnemyTarget("Moonfire", 0)) then
      WowCyborg_CURRENTATTACK = "Moonfire";
      return SetSpellRequest(moonfire);
    end
  
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if IsCastableAtEnemyTarget("Thrash", 0) then
    WowCyborg_CURRENTATTACK = "Thrash";
    return SetSpellRequest(thrash);
  end

  if IsCastableAtEnemyTarget("Swipe", 0) then
    WowCyborg_CURRENTATTACK = "Swipe";
    return SetSpellRequest(swipe);
  end

  if (moonfireDot == nil and IsCastableAtEnemyTarget("Moonfire", 0)) and ggBuff ~= nil then
    WowCyborg_CURRENTATTACK = "Moonfire";
    return SetSpellRequest(moonfire);
  end

  if IsCastable("Ironfur", 40) then
    WowCyborg_CURRENTATTACK = "Ironfur";
    return SetSpellRequest(ironfur);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  local towerResult = GetTowerResult();
  if towerResult then
    return towerResult;
  end

  if UnitChannelInfo("player") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if UnitChannelInfo("player") == "Fleshcraft" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local moonkin = FindBuff("player", "Moonkin Form");
  if moonkin ~= nil then
    return RenderBoomkinRotation();
  end

  local bear = FindBuff("player", "Bear Form");
  if bear == nil then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local hp = GetHealthPercentage("player");

  if hp < 70 then
    local regenBuff = FindBuff("player", "Frenzied Regeneration");
    if regenBuff == nil and IsCastableAtEnemyTarget("Frenzied Regeneration", 10) then
      WowCyborg_CURRENTATTACK = "Frenzied Regeneration";
      return SetSpellRequest(frenziedRegeneration);
    end
  end

  local ggBuff = FindBuff("player", "Galactic Guardian");
  local moonfireDot = FindDebuff("target", "Moonfire");

  if (moonfireDot == nil and IsCastableAtEnemyTarget("Moonfire", 0)) or ggBuff ~= nil then
    WowCyborg_CURRENTATTACK = "Moonfire";
    return SetSpellRequest(moonfire);
  end

  if IsCastableAtEnemyTarget("Adaptive Swarm", 0) then
    WowCyborg_CURRENTATTACK = "Adaptive Swarm";
    return SetSpellRequest(adaptiveSwarm);
  end

  if IsMelee() == 0 then
    if IsCastableAtEnemyTarget("Moonfire", 0) then
      WowCyborg_CURRENTATTACK = "Moonfire";
      return SetSpellRequest(moonfire);
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if IsCastableAtEnemyTarget("Maul", 40) then
    WowCyborg_CURRENTATTACK = "Maul";
    return SetSpellRequest("7");
  end

  local _, bleedDotTl, bleedDots = FindDebuff("target", "Thrash");
  
  if (bleedDots == nil or bleedDots < 3 or bleedDotTl < 2) and IsCastableAtEnemyTarget("Thrash", 0) then
    WowCyborg_CURRENTATTACK = "Thrash";
    return SetSpellRequest(thrash);
  end
 
  if IsCastableAtEnemyTarget("Mangle", 0) then
    WowCyborg_CURRENTATTACK = "Mangle";
    return SetSpellRequest(mangle);
  end

  if IsCastableAtEnemyTarget("Thrash", 0) then
    WowCyborg_CURRENTATTACK = "Thrash";
    return SetSpellRequest(thrash);
  end
  
  if IsCastable("Ironfur", 40) then
    WowCyborg_CURRENTATTACK = "Ironfur";
    return SetSpellRequest(ironfur);
  end

  local nearbyEnemies = GetNearbyEnemyCount();
  if nearbyEnemies > 1 then
    if IsCastableAtEnemyTarget("Swipe", 0) then
      WowCyborg_CURRENTATTACK = "Swipe";
      return SetSpellRequest(swipe);
    end
  else
    if IsCastableAtEnemyTarget("Maul", 40) then
      WowCyborg_CURRENTATTACK = "Maul";
      return SetSpellRequest(maul);
    end

    if IsCastableAtEnemyTarget("Swipe", 0) then
      WowCyborg_CURRENTATTACK = "Swipe";
      return SetSpellRequest(swipe);
    end  
  end
  
  if IsCastableAtEnemyTarget("Moonfire", 0) then
    WowCyborg_CURRENTATTACK = "Moonfire";
    return SetSpellRequest(moonfire);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function CreateDamageTakenFrame()
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

  frame:SetScript("OnEvent", function()
    local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, amountDetails = CombatLogGetCurrentEventInfo()
    if destGUID ~= UnitGUID("player") then
      return;
    end
    
    local DamageDetails
    if type == "SPELL_DAMAGE" or type == "SPELL_PERIODIC_DAMAGE" or type == "RANGE_DAMAGE" then
      _, _, _, damage = amountDetails
      DamageDetails = { damage = damage, melee = false };
    elseif type == "SWING_DAMAGE" then
      damage = amountDetails;
      DamageDetails = { damage = damage, melee = true };
    elseif type == "ENVIRONMENTAL_DAMAGE" then
      _, damage = amountDetails
      DamageDetails = { damage = damage, melee = false };
    end

    if DamageDetails and DamageDetails.damage then
      DamageDetails.timestamp = timestamp;

      tinsert(incomingDamage, 1, DamageDetails);

      local cutoff = timestamp - 5
      meleeDamageInLast5Seconds = 0
      rangedDamageInLast5Seconds = 0;
      for i = #incomingDamage, 1, -1 do
          local damage = incomingDamage[i]
          if damage.timestamp < cutoff then
            incomingDamage[i] = nil
          else
            if damage.melee then
              meleeDamageInLast5Seconds = meleeDamageInLast5Seconds + incomingDamage[i].damage;
            else
              rangedDamageInLast5Seconds = rangedDamageInLast5Seconds + incomingDamage[i].damage;
            end
          end
      end
    end

  end)
end

print("Druid tank rotation loaded!");
CreateDamageTakenFrame();