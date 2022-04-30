--[[
  Button    Spell
]]--

local flashOfLight = 1;
local holyLight = 2;
local holyShock = 3;
local judgment = 4;
local crusaderStrike = 5;
local bestowFaith = "F+5";
local bestowFaithTarget = "F+6";
local lightOfTheMartyr = "F+7";
local beaconOfLight = "F+9";
local hammerOfWrath = "F+8";

local holyShock = {};
holyShock[1] = "6";
holyShock[2] = "7";
holyShock[3] = "8";
holyShock[4] = "9";
holyShock[5] = "0";

local wog = {};
wog[1] = "ALT+6";
wog[2] = "ALT+7";
wog[3] = "ALT+8";
wog[4] = "ALT+9";
wog[5] = "ALT+0";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "F5",
  "F7",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "F",
  "R",
  "ESCAPE"
}

function GetTargetFullName()
  local name, realm = UnitName("target");
  if realm == nil then
    return name;
  end
  return name .. "-" .. realm;
end

function GetGroupRosterInfo()
  local groupMembers = {};

  for groupIndex = 1,5 do
    local name,_,_,_,_,_,_,_,_,_,_,role = GetRaidRosterInfo(groupIndex);
    if UnitName("player") == name then
      table.insert(groupMembers, 1, { name = name, role = role });
    else
      table.insert(groupMembers, { name = name, role = role });
    end
  end
  return groupMembers;
end

function GetMemberIndex(name)
  local group = GetGroupRosterInfo();
  for groupindex = 1,25 do
    if group[groupindex] == nil then
      return;
    elseif group[groupindex].name == nil then
      return nil;
    elseif group[groupindex].name == name then
      return groupindex;
    end
  end
  return nil;
end

function AoeHealingRequired()
  local lowCount = 0;
  local hp = GetHealthPercentage("player");

  if hp < 90 then
    lowCount = lowCount + 1;
  end

  for groupindex = 1,5 do
    local php = GetHealthPercentage("party" .. groupindex);
    if tostring(php) ~= "-nan(ind)" and php > 1 and php < 90 then
      lowCount = lowCount + 1;
    end
  end
  
  return lowCount > 1;
end

function FindShockHealingTarget()
  local lowestHealth = nil
  local members = GetGroupRosterInfo();
  for groupindex = 1,5 do
    if members[groupindex] == nil or members[groupindex].name == nil then
      break;
    end
    
    local cyclone = FindDebuff(members[groupindex].name, "Cyclone");
    local hp = GetHealthPercentage(members[groupindex].name);
    if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 99 and cyclone == nil then
      if lowestHealth == nil or hp <= lowestHealth.hp then
        if IsSpellInRange("Holy Shock", members[groupindex].name) == 1 then
          lowestHealth = { hp = hp, name = members[groupindex].name }
        end
      end
    end
  end

  if lowestHealth ~= nil and lowestHealth.hp < 90 then
    return lowestHealth.name, 0;
  end

  return nil; 
end

function AoeHealingRequired()
  local lowCount = 0;
  local hp = GetHealthPercentage("player");

  if hp < 95 then
    lowCount = lowCount + 1;
  end

  for groupindex = 1,5 do
    local php = GetHealthPercentage("party" .. groupindex);
    if tostring(php) ~= "-nan(ind)" and php > 1 and php < 90 then
      lowCount = lowCount + 1;
    end
  end
  
  return lowCount > 1;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function HandleTankPreHots()
  if FindBuff("focus", "Beacon of Light") == nil then
    if IsCastableAtFriendlyUnit("focus", "Beacon of Light", 500) and IsSpellInRange("Beacon of Light", "focus") then
      local focusHp = GetHealthPercentage("focus");
      if focusHp > 0 then
        WowCyborg_CURRENTATTACK = "Beacon of Light";
        SetSpellRequest(beaconOfLight);
        return true;
      end
    end
  end

  return false;
end

function IsMelee()
  return IsSpellInRange("Crusader Strike") == 1;
end

function RenderSingleTargetRotation(disableAutoTarget)
  if disableAutoTarget == nil then
    local tankPreHot = HandleTankPreHots();
    if tankPreHot then
      return;
    end
  end

  local speed = GetUnitSpeed("player");
  local playerHp = GetHealthPercentage("player");
  local hp = GetHealthPercentage("target");
  local focusHealth = GetHealthPercentage("focus");
  local divine = FindBuff("player", "Divine Favor");

  if (tostring(hp) == "-nan(ind)") then
    hp = 100;
  end

  local friendlyTargetName = FindShockHealingTarget();
  local holyPower = UnitPower("player", 9);

  if friendlyTargetName ~= nil and IsCastable("Word of Glory", 0) and holyPower > 2 then
    local memberindex = GetMemberIndex(friendlyTargetName);
    WowCyborg_CURRENTATTACK = "Word of Glory " .. friendlyTargetName;
    return SetSpellRequest(wog[memberindex]);
  end

  if friendlyTargetName ~= nil and IsCastable("Holy Shock", 1600) then
    local memberindex = GetMemberIndex(friendlyTargetName);
    WowCyborg_CURRENTATTACK = "Shock " .. friendlyTargetName;
    return SetSpellRequest(holyShock[memberindex]);
  end

  if UnitCanAttack("player", "target") == true then
    if speed == 0 then

      if divine ~= nil and playerHp < 95 and playerHp > 70 and IsCastable("Holy Light", 2600) then
        WowCyborg_CURRENTATTACK = "Holy Light";
        return SetSpellRequest(holyLight);
      end

      if playerHp < 80 and IsCastable("Flash of Light", 4400) then
        WowCyborg_CURRENTATTACK = "Flash of Light";
        return SetSpellRequest(flashOfLight);
      end
    end
    
    if focusHealth < 95 then
      if IsCastableAtFriendlyUnit("focus", "Bestow Faith", 0) then
        WowCyborg_CURRENTATTACK = "Bestow Faith";
        return SetSpellRequest(bestowFaithTarget);
      end
    end

    if playerHp < 95 and IsCastable("Bestow Faith", 0) then
      WowCyborg_CURRENTATTACK = "Bestow Faith";
      return SetSpellRequest(bestowFaith);
    end
    
    local repentence = FindDebuff("target", "Repentance");
    local freeze = FindDebuff("target", "Freezing Trap");
      
    if focusHealth > 0 then
      if focusHealth < 95 then
        if IsCastableAtFriendlyUnit("focus", "Bestow Faith", 0) then
          WowCyborg_CURRENTATTACK = "Bestow Faith";
          return SetSpellRequest(bestowFaithTarget);
        end
      end

      if focusHealth < 80 and hp > 70 and speed > 0 then
        if IsCastableAtFriendlyUnit("focus", "Light of the Martyr", 0) then
          WowCyborg_CURRENTATTACK = "Light of the Martyr";
          return SetSpellRequest(lightOfTheMartyr);
        end
      end
    end
    
    if repentence == nil and freeze == nil then
      if IsCastableAtEnemyTarget("Judgment", 600) then
        WowCyborg_CURRENTATTACK = "Judgment";
        return SetSpellRequest(judgment);
      end
      
      if IsCastableAtEnemyTarget("Crusader Strike", 0) then
        WowCyborg_CURRENTATTACK = "Crusader Strike";
        return SetSpellRequest(crusaderStrike);
      end

      local wrathBuff = FindBuff("player", "Avenging Wrath");
      if wrathBuff or hp < 20 then
        if IsCastableAtEnemyTarget("Hammer of Wrath", 0) then
          WowCyborg_CURRENTATTACK = "Hammer of Wrath";
          return SetSpellRequest(hammerOfWrath);
        end
      end
    end 

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if UnitCanAttack("player", "target") == true or GetTargetFullName() == nil then
    hp = GetHealthPercentage("player");
  end

  if hp < 80 and IsCastable("Holy Shock", 2000) then
    WowCyborg_CURRENTATTACK = "Holy Shock";
    return SetSpellRequest(holyShock);
  end
  
  if hp < 95 and IsCastable("Bestow Faith", 0) then
    WowCyborg_CURRENTATTACK = "Bestow Faith";
    return SetSpellRequest(bestowFaith);
  end
  
  if divine ~= nil and hp < 95 and playerHp > 70 and IsCastable("Holy Light", 2600) then
    WowCyborg_CURRENTATTACK = "Holy Light";
    return SetSpellRequest(holyLight);
  end

  if hp < 80 and IsCastable("Flash of Light", 4400) then
    WowCyborg_CURRENTATTACK = "Flash of Light";
    return SetSpellRequest(flashOfLight);
  end

  if focusHealth > 0 then
    if focusHealth < 95 then
      if IsCastableAtFriendlyUnit("focus", "Bestow Faith", 0) then
        WowCyborg_CURRENTATTACK = "Bestow Faith";
        return SetSpellRequest(bestowFaithTarget);
      end
    end

    if focusHealth < 80 and hp > 70 and speed > 0 then
      if IsCastableAtFriendlyUnit("focus", "Light of the Martyr", 0) then
        WowCyborg_CURRENTATTACK = "Light of the Martyr";
        return SetSpellRequest(lightOfTheMartyr);
      end
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Holy PVP pala rotation loaded");