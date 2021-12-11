--[[
  Button    Spell
  Ctrl+1    Macro: /target player
  Ctrl+2    Macro: /target party1
  Ctrl+3    Macro: /target party2
  Ctrl+4    Macro: /target party3
  Ctrl+5    Macro: /target party4
  1         Regrowth
  2         Lifebloom
  3         Rejuvenation
  4         Swiftmend
  5         Wild Growth
]]--

local damageInLast5Seconds = {};
local regrowth = 4;
local lifebloom = 5;
local rejuvenation = 6;
local swiftmend = 7;
local cenarionWard = 8;
local adaptiveSwarm = 9;
local overgrowth = "F+4";
local cancelCast = "CTRL+4";

local polymorphAt = 0;

-- Bear form
local mangle = 2;
local frenziedRegen = 3;
local ironFur = 4;

-- CAT form
local rake = 2;
local shred = 3;
local maim = 4;

WowCyborg_PAUSE_KEYS = {
  "F2",
  "R",
  "F3",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "NUMPAD6",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "F10",
  "LSHIFT"
}

function HandleAntiPolymorph()
  local polymorphIn = polymorphAt - GetTime();
  if polymorphAt < 0 then
    polymorphAt = 0;
  end

  if polymorphIn <= 0 or polymorphIn > 1.5 then
    return false;
  end
  
  if UnitChannelInfo("player") == "Fleshcraft" then
    return true;
  end

  if UnitChannelInfo("player") ~= nil or UnitCastingInfo("player") ~= nil then
    WowCyborg_CURRENTATTACK = "Abort casting!";
    SetSpellRequest(cancelCast);
    return true;
  end

  local travel = FindBuff("player", "Travel Form");
  local bear = FindBuff("player", "Bear Form");
  local cat = FindBuff("player", "Cat Form");

  if travel == nil and bear == nil and cat == nil then
    if IsCastable("Fleshcraft", 0) then
      WowCyborg_CURRENTATTACK = "Avoid Poly!";
      SetSpellRequest("F+3");
      return true;
    end
    
    WowCyborg_CURRENTATTACK = "Avoid Poly!";
    SetSpellRequest("0");
    return true;
  end
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function IsMelee()
  return IsSpellInRange("Shred") == 1;
end

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

function RenderCatRotation()
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
  if points == 4 then
    if ripDot == nil then
      WowCyborg_CURRENTATTACK = "Maim";
      return SetSpellRequest(maim);
    end
  end

  if IsCastableAtEnemyTarget("Shred", 0) then
    WowCyborg_CURRENTATTACK = "Shred";
    return SetSpellRequest(shred);
  end
end

function RenderSingleTargetRotation(attack)
  local handlingPoly = HandleAntiPolymorph();

  if handlingPoly then
    return;
  end

  local casting = UnitChannelInfo("player");

  if casting == "Shackles of Malediction" then
    WowCyborg_CURRENTATTACK = "Shackles of Malediction";
    return SetSpellRequest(nil);
  end

  if UnitChannelInfo("player") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if UnitChannelInfo("player") == "Fleshcraft" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local travel = FindBuff("player", "Travel Form");
  if travel ~= nil then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local bear = FindBuff("player", "Bear Form");
  if bear ~= nil then
    return RenderBearRotation();
  end

  local cat = FindBuff("player", "Cat Form");
  if cat ~= nil then
    return RenderCatRotation();
  end

  local speed = GetUnitSpeed("player");

  if UnitChannelInfo("player") == "Tranquility" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local target = "target";
  if UnitCanAttack("player", "target") == true or UnitName("target") == nil then
    target = "player";
  end

  local naturesSwiftness = FindBuff("player", "Nature's Swiftness");
  local rejuvenationHot, rejuvenationHotTL = FindBuff(target, "Rejuvenation");
  local hp = GetHealthPercentage(target);
  if hp <= 70 then
    if naturesSwiftness ~= nil then
      if IsCastableAtFriendlyUnit(target, "Regrowth", 0) then
        WowCyborg_CURRENTATTACK = "Regrowth";
        return SetSpellRequest(regrowth);
      end
    end

    local regrowthHot = FindBuff(target, "Regrowth");

    if rejuvenationHot ~= nil or regrowth ~= nil then
      if IsCastableAtFriendlyUnit(target, "Swiftmend", 800) then
        WowCyborg_CURRENTATTACK = "Swiftmend";
        return SetSpellRequest(swiftmend);
      end
    end

    if IsCastableAtFriendlyUnit(target, "Overgrowth", 3000) then
      WowCyborg_CURRENTATTACK = "Overgrowth";
      return SetSpellRequest(overgrowth);
    end
      
    if IsCastableAtFriendlyUnit(target, "Cenarion Ward", 0) then
      WowCyborg_CURRENTATTACK = "Cenarion Ward";
      return SetSpellRequest(cenarionWard);
    end
  end

  if hp <= 40 then
    if IsCastableAtFriendlyUnit(target, "Regrowth", 1700) and speed == 0 then
      WowCyborg_CURRENTATTACK = "Regrowth";
      return SetSpellRequest(regrowth);
    end

    if IsCastableAtFriendlyUnit(target, "Adaptive Swarm", 500) then
      WowCyborg_CURRENTATTACK = "Adaptive Swarm";
      return SetSpellRequest(adaptiveSwarm);
    end

    if IsCastableAtFriendlyUnit(target, "Lifebloom", 800) then
      local lifebloomBuff, lbBuffTl = FindBuff(target, "Lifebloom");

      if UnitIsPVP("player") then
        local focusGrowth, fg_, fgstacks = FindBuff(target, "Focused Growth");
        if (focusGrowth == nil or fgstacks < 3 or lbBuffTl < 5) and hp <= 50 then
          WowCyborg_CURRENTATTACK = "Lifebloom";
          return SetSpellRequest(lifebloom);
        end
      elseif lifebloomBuff == nil or lbBuffTl < 5 then
        WowCyborg_CURRENTATTACK = "Lifebloom";
        return SetSpellRequest(lifebloom);
      end
    end
  end

  local t_, t__, t___, germinationTalented = GetTalentInfo(7,2,1);
    local rejuvenationHot2, rejuvenationHotTL2 = FindBuff(target, "Rejuvenation (Germination)");
    if (rejuvenationHot == nil or rejuvenationHotTL < 1) and IsCastableAtFriendlyUnit(target, "Rejuvenation", 1100) then
      if germinationTalented then
        WowCyborg_CURRENTATTACK = "Rejuvenation 2";
        return SetSpellRequest(rejuvenation);
      end
    end

  if (rejuvenationHot2 == nil or rejuvenationHotTL2 < 1) and IsCastableAtFriendlyUnit(target, "Rejuvenation", 1100) then
    WowCyborg_CURRENTATTACK = "Rejuvenation 1";
    return SetSpellRequest(rejuvenation);
  end

  if hp <= 90 and IsCastableAtFriendlyUnit(target, "Adaptive Swarm", 500) then
    WowCyborg_CURRENTATTACK = "Adaptive Swarm";
    return SetSpellRequest(adaptiveSwarm);
  end

  if IsCastableAtFriendlyUnit(target, "Lifebloom", 800) and hp <= 80 then
    local lifebloomBuff, lbBuffTl = FindBuff(target, "Lifebloom");

    if UnitIsPVP("player") then
      local focusGrowth, fg_, fgstacks = FindBuff(target, "Focused Growth");
      if (focusGrowth == nil or fgstacks < 3 or lbBuffTl < 5) and hp <= 50 then
        WowCyborg_CURRENTATTACK = "Lifebloom";
        return SetSpellRequest(lifebloom);
      end
    elseif lifebloomBuff == nil or lbBuffTl < 5 then
      WowCyborg_CURRENTATTACK = "Lifebloom";
      return SetSpellRequest(lifebloom);
    end
  end

  if hp <= 90 and IsCastableAtFriendlyUnit(target, "Regrowth", 1700) and (speed == 0 or naturesSwiftness ~= nil) then
    WowCyborg_CURRENTATTACK = "Regrowth";
    return SetSpellRequest(regrowth);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function CreateIncomingCastFrame()
  local frame = CreateFrame("Frame");

  frame:RegisterEvent("UNIT_SPELLCAST_START");
   
  frame:SetScript("OnEvent", function(self, event, ...)
    local unitTarget, castGUID, spellID = ...
    if UnitCanAttack(unitTarget, "player") == true then
      local spellName, _, __, castTime = GetSpellInfo(spellID);
      if spellName == "Polymorph" or spellName == "Hex" then
        polymorphAt = GetTime() + (castTime / 1000);
      end
    end
  end)
end

CreateIncomingCastFrame();

print("Arena resto druid rotation loaded");