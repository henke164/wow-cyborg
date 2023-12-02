--[[
  Button    Spell
  1         Regrowth
  2         Lifebloom
  3         Rejuvenation
  4         Swiftmend
  5         Wild Growth
]]--

local regrowth = 1;
local treants = 2;
local rejuvenation = 3;
local swiftmend = 4;
local wildGrowth = 5;
local cancelCast = "0";

local regrowthRequestTarget = "";
local regrowthTarget = "";
local regrowthCastEndTime = 0;
local treantCastAt = 0;

WowCyborg_PAUSE_KEYS = {
  "F",
  "NUMPAD1",
  "F1",
  "F3",
  "F10",
  "R"
}

function GetTargetFullName()
  local name, realm = UnitName("target");
  if realm == nil then
    return name;
  end
  return name .. "-" .. realm;
end

function AoeHealingRequired()
  local lowCount = 0;
  local hp = GetHealthPercentage("player");

  if hp < 90 then
    lowCount = lowCount + 1;
  end

  for groupindex = 1,5 do
    local php = GetHealthPercentage("raid" .. groupindex);
    if tostring(php) ~= "-nan(ind)" and php > 1 and php < 90 then
      lowCount = lowCount + 1;
    end

    if lowCount > 5 then
      break;
    end
  end
  
  return lowCount > 1;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation()
  local hpFloat = GetHealthPercentage("mouseover")
  local hp = math.ceil(hpFloat);

  if UnitChannelInfo("player") then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local castingInfo, _, _, _, endTimeMS = UnitCastingInfo("player");

  if castingInfo ~= nil then
    if castingInfo == "Regrowth" then
      if regrowthRequestTarget ~= "" then
        regrowthTarget = regrowthRequestTarget;
      end

      regrowthCastEndTime = endTimeMS;
      WowCyborg_CURRENTATTACK = "Casting Regrowth...";
      return SetSpellRequest(nil);
    end
  end

  if regrowthCastEndTime > 0 then
    if (GetTime() * 1000 - regrowthCastEndTime > 1) then
      regrowthCastEndTime = 0;
      regrowthTarget = "";
      regrowthRequestTarget = "";
    end
  end


  if hp == nil or hp == 0 or hp == 100 then
    WowCyborg_CURRENTATTACK = hp .. "HP";
    return SetSpellRequest(nil);
  end

  local speed = GetUnitSpeed("player");
  if AoeHealingRequired() and IsCastable("Wild Growth", 0) and speed == 0 then
    WowCyborg_CURRENTATTACK = "Wild Growth: " .. hp .. "HP";
    return SetSpellRequest(wildGrowth);
  end

  local rejuvenationHot = FindBuff("mouseover", "Rejuvenation");
  if hp <= 95 and rejuvenationHot == nil and IsCastableAtFriendlyUnit("mouseover", "Rejuvenation", 0) then
    WowCyborg_CURRENTATTACK = "Rejuvenation: " .. hp .. "HP";
    return SetSpellRequest(rejuvenation);
  end

  local regrowthBuff = FindBuff("mouseover", "Regrowth");
  if hp <= 90 and regrowthBuff == nil and IsCastableAtFriendlyUnit("mouseover", "Regrowth", 0) and speed == 0 then
    local skipRegrowth = false;
    if regrowthTarget == UnitGUID("mouseover") then
      skipRegrowth = true;
    end

    if skipRegrowth == false and regrowthCastEndTime == 0 then
      regrowthRequestTarget = UnitGUID("mouseover");
      WowCyborg_CURRENTATTACK = "Regrowth";
      return SetSpellRequest(regrowth);
    end
  end
  local treantsCharges = GetSpellCharges("Grove Guardians");
  if hp <= 70 then
    if treantsCharges > 0 and treantCastAt + 7 < GetTime() then
      if IsCastableAtFriendlyUnit("mouseover", "Grove Guardians", 0) then
        WowCyborg_CURRENTATTACK = "Grove Guardians: " .. hp .. "HP";
        return SetSpellRequest(treants);
      end
    elseif IsCastableAtFriendlyUnit("mouseover", "Swiftmend", 0) then
      WowCyborg_CURRENTATTACK = "Swiftmend: " .. hp .. "HP";
      return SetSpellRequest(swiftmend);
    end
  end

  if hp <= 40 then
    if treantsCharges > 0 then
      if IsCastableAtFriendlyUnit("mouseover", "Grove Guardians", 0) then
        WowCyborg_CURRENTATTACK = "Grove Guardians: " .. hp .. "HP";
        return SetSpellRequest(treants);
      end
    end
  end

  if hp <= 60 and IsCastableAtFriendlyUnit("mouseover", "Regrowth", 0) and speed == 0 then
    WowCyborg_CURRENTATTACK = "Regrowth";
    return SetSpellRequest(regrowth);
  end

  WowCyborg_CURRENTATTACK = hp .. "HP";
  return SetSpellRequest(nil);
end

function CreateSummonFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

  frame:SetScript("OnEvent", function(...)
    local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo();
    if type == 'SPELL_SUMMON' and sourceName == UnitName('player') then
      local spellId, spellName, spellSchool = ...
      if destName == "Treant" then
        treantCastAt = GetTime();
      end
    end
  end)
end

CreateSummonFrame();

print("Resto druid raid rotation loaded");