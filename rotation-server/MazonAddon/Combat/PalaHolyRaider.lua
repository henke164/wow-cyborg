--[[
  Button    Spell
]]--

local judgment = "F+7";
local crusaderStrike = "F+6";
local lightOfDawn = "F+5";
local hammerOfWrath = "F+8";
local lastTargetTime = 0;

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "F",
  "R",
  "ESCAPE"
}

local lastTarget = {
  index = nil,
  time = 0,
};

function GetTargetFullName()
  local name, realm = UnitName("target");
  if realm == nil then
    return name;
  end
  return name .. "-" .. realm;
end

function GetMemberIndex(name)
  for raidIndex = 1,40 do
    local n = GetRaidRosterInfo(raidIndex);
    if n == name then
      return raidIndex;
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

  for groupindex = 1,40 do
    local php = GetHealthPercentage("raid" .. groupindex);
    if tostring(php) ~= "-nan(ind)" and php > 1 and php < 90 then
      lowCount = lowCount + 1;
    end
  end
  
  return lowCount > 1;
end

function FindHealingTarget()
  local lowestHealth = nil
  for raidIndex = 1,40 do
    local name = GetRaidRosterInfo(raidIndex);

    if name == nil then
      break;
    end
    
    local hp = GetHealthPercentage(name);
    if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 99 then
      if lowestHealth == nil or hp <= lowestHealth.hp then
        if IsSpellInRange("Holy Shock", name) == 1 then
          lowestHealth = { hp = hp, name = name }
        end
      end
    end
  end

  if lowestHealth ~= nil and lowestHealth.hp < 90 then
    return lowestHealth.name, 0;
  end

  return nil; 
end

function RenderMultiTargetRotation()
  local holyPower = UnitPower("player", 9);
  if AoeHealingRequired() and IsCastable("Light of Dawn", 0) and holyPower > 2 then
    WowCyborg_CURRENTATTACK = "Light of Dawn";
    SetSpellRequest(lightOfDawn);
    return true;
  end

  return RenderSingleTargetRotation();
end

function IsMelee()
  return IsSpellInRange("Crusader Strike") == 1;
end

function DoRaidHeal(spellName, memberindex)
  local page = GetActionBarPage();

  if memberindex <= 10 then
    if (page ~= 1) then
      SetSpellRequest("SHIFT+7");
      return nil;
    end
  elseif memberindex > 10 and memberindex <= 20 then
    if (page ~= 2) then
      SetSpellRequest("SHIFT+8");
      return nil;
    end
  elseif memberindex > 20 and memberindex <= 30 then
    if (page ~= 4) then
      SetSpellRequest("SHIFT+9");
      return nil;
    end
  end

  local key = memberindex;
  if (key > 10 and key <= 20) then
    key = key - 10;
  end

  if (key > 20 and key <= 30) then
    key = key - 20;
  end

  if (key > 30 and key <= 40) then
    key = key - 30;
  end

  if (key == 10) then
    key = 0;
  end
  
  if spellName == "Holy Shock" then
    WowCyborg_CURRENTATTACK = key;
    return SetSpellRequest(key);
  end
  
  if spellName == "Word of Glory" then
    WowCyborg_CURRENTATTACK = key;
    return SetSpellRequest("ALT+" .. key);
  end
  
  if spellName == "Holy Light" then
    WowCyborg_CURRENTATTACK = key;
    return SetSpellRequest("CTRL+" .. key);
  end 
end

function RenderSingleTargetRotation()
  local speed = GetUnitSpeed("player");
  local playerHp = GetHealthPercentage("player");
  local hp = GetHealthPercentage("target");
  local focusHealth = GetHealthPercentage("focus");
  local divine = FindBuff("player", "Divine Favor");
  local holyPower = UnitPower("player", 9);

  if (tostring(hp) == "-nan(ind)") then
    hp = 100;
  end

  local friendlyTargetName = FindHealingTarget();
  local memberindex = GetMemberIndex(friendlyTargetName);

  if memberindex ~= lastTarget.index and lastTarget.time + 1 < GetTime() then
    lastTarget = {
      index = memberindex,
      time = GetTime()
    }
  end

  if friendlyTargetName ~= nil and IsCastableAtFriendlyUnit(friendlyTargetName, "Word of Glory", 0) and holyPower > 2 then
    WowCyborg_CURRENTATTACK = "Word of Glory " .. friendlyTargetName;
    local heal = DoRaidHeal("Word of Glory", lastTarget.index);
    if heal ~= nil then
      lastTargetTime = GetTime();
      return heal;
    else
      return nil;
    end
  end

  if friendlyTargetName ~= nil and IsCastableAtFriendlyUnit(friendlyTargetName, "Holy Shock", 1600) then
    WowCyborg_CURRENTATTACK = "Shock " .. friendlyTargetName;
    local heal = DoRaidHeal("Holy Shock", lastTarget.index);
    if heal ~= nil then
      lastTargetTime = GetTime();
      return heal;
    else
      return nil;
    end
  end
  
  if friendlyTargetName ~= nil and speed == 0 and IsCastableAtFriendlyUnit(friendlyTargetName, "Holy Light", 1500) then
    WowCyborg_CURRENTATTACK = "Holy Light " .. friendlyTargetName;
    local heal = DoRaidHeal("Holy Light", lastTarget.index);
    if heal ~= nil then
      lastTargetTime = GetTime();
      return heal;
    else
      return nil;
    end
  end

  if UnitCanAttack("player", "target") == true then
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

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Holy raider pala rotation loaded");