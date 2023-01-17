--[[
  Button    Spell
]]--

local flashOfLight = "SHIFT+1";
local consecration = "F+1";
local holyLight = "SHIFT+2";
local shieldOfTheRighteous = "SHIFT+4";
local hammerOfWrath = 1;
local holyShock = 2;
local crusaderStrike = 3;
local judgment = 4;
local lightOfDawn = 5;

local wog = {};
wog[1] = "F+5";
wog[2] = "F+6";
wog[3] = "F+7";
wog[4] = "F+8";
wog[5] = "F+9";

local shock = {};
shock[1] = "6";
shock[2] = "7";
shock[3] = "8";
shock[4] = "9";
shock[5] = "0";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "F4",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD5",
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

function AoeCritical()
  local lowCount = 0;
  local hp = GetHealthPercentage("player");

  if hp < 80 then
    lowCount = lowCount + 1;
  end

  for groupindex = 1,5 do
    local php = GetHealthPercentage("party" .. groupindex);
    if tostring(php) ~= "-nan(ind)" and php > 1 and php < 90 then
      lowCount = lowCount + 1;
    end
  end
  
  return lowCount > 2;
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
  
  return lowCount > 2;
end

function FindHealingTarget(minPercent)
  local lowestHealth = nil
  local members = GetGroupRosterInfo();
  for groupindex = 1,5 do
    if members[groupindex] == nil or members[groupindex].name == nil then
      break;
    end
    
    local hp = GetHealthPercentage(members[groupindex].name);
    if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 99 then
      if lowestHealth == nil or hp <= lowestHealth.hp then
        if IsSpellInRange("Word of Glory", members[groupindex].name) == 1 then
          lowestHealth = { hp = hp, name = members[groupindex].name }
        end
      end
    end
  end

  if lowestHealth ~= nil and lowestHealth.hp < minPercent then
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
    if tostring(php) ~= "-nan(ind)" and php > 1 and php < 95 then
      lowCount = lowCount + 1;
    end
  end
  
  return lowCount > 1;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function IsMelee()
  return IsSpellInRange("Crusader Strike") == 1;
end

function RenderSingleTargetRotation(skipDps)
  if skipDps == nil then
    skipDps = false;
  end

  local speed = GetUnitSpeed("player");
  local shockTarget = FindHealingTarget(85);
  local criticalTarget = FindHealingTarget(70);
  local holyPower = UnitPower("player", 9);
  
  if AoeCritical() and IsCastable("Aura Mastery", 5000) then
    WowCyborg_CURRENTATTACK = "Aura Mastery";
    return SetSpellRequest("F+4");
  end

  if AoeHealingRequired() then
    if IsCastable("Beacon of Virtue", 5000) then
      WowCyborg_CURRENTATTACK = "Beacon of Virtue";
      return SetSpellRequest("SHIFT+" .. lightOfDawn);
    end

    local empyrianBuff = FindBuff("player", "Empyrean Legacy");
    if empyrianBuff == nil then
      if IsCastableAtEnemyTarget("Judgment", 1500) then
        WowCyborg_CURRENTATTACK = "Judgment";
        return SetSpellRequest(judgment);
      end
    else
      if shockTarget ~= nil and IsCastable("Word of Glory", 0) and holyPower > 2 then
        local memberindex = GetMemberIndex(shockTarget);
        WowCyborg_CURRENTATTACK = "Word of Glory " .. shockTarget;
        return SetSpellRequest(wog[memberindex]);
      end
    end
    
    if IsCastable("Light of Dawn", 0) and holyPower > 2 then
      WowCyborg_CURRENTATTACK = "Light of Dawn";
      return SetSpellRequest(lightOfDawn);
    end
  end

  if criticalTarget ~= nil and IsCastable("Word of Glory", 0) and holyPower > 2 then
    local memberindex = GetMemberIndex(criticalTarget);
    WowCyborg_CURRENTATTACK = "Word of Glory " .. criticalTarget;
    return SetSpellRequest(wog[memberindex]);
  end

  if shockTarget ~= nil and IsCastable("Holy Shock", 8000) then
    local memberindex = GetMemberIndex(shockTarget);
    WowCyborg_CURRENTATTACK = "Shock " .. shockTarget;
    return SetSpellRequest(shock[memberindex]);
  end
  
  if criticalTarget ~= nil and IsCastable("Light of the Martyr", 4500) then
    local memberindex = GetMemberIndex(criticalTarget);
    WowCyborg_CURRENTATTACK = "Martyr " .. criticalTarget;
    return SetSpellRequest("SHIFT+" .. shock[memberindex]);
  end

  if UnitCanAttack("player", "target") == true then
    if WowCyborg_INCOMBAT then
      local targetHp = GetHealthPercentage("target");
      local consec = FindBuff("player", "Consecration");
      if consec == nil and IsMelee() and IsCastableAtEnemyTarget("Consecration", 0) and speed == 0 then
        WowCyborg_CURRENTATTACK = "Consecration";
        return SetSpellRequest(consecration);
      end

      if IsCastableAtEnemyTarget("Hammer of Wrath", 0) then
        WowCyborg_CURRENTATTACK = "Hammer of Wrath";
        return SetSpellRequest(hammerOfWrath);
      end

      if holyPower < 5 then
        if IsCastableAtEnemyTarget("Holy Shock", 8000) then
          WowCyborg_CURRENTATTACK = "Holy Shock";
          return SetSpellRequest(holyShock);
        end

        local hsCd, hsDuration = GetSpellCooldown("Holy Shock");
        if hsDuration > 2 then
          if IsCastableAtEnemyTarget("Judgment", 1500) then
            WowCyborg_CURRENTATTACK = "Judgment";
            return SetSpellRequest(judgment);
          end
          
          if IsCastableAtEnemyTarget("Crusader Strike", 5000) then
            WowCyborg_CURRENTATTACK = "Crusader Strike";
            return SetSpellRequest(crusaderStrike);
          end
        end
      end

      if holyPower > 3 and skipDps == false then
        if IsMelee() and IsCastableAtEnemyTarget("Shield of the Righteous", 0) then
          WowCyborg_CURRENTATTACK = "Shield of the Righteous";
          return SetSpellRequest(shieldOfTheRighteous);
        end      
      end
    end 

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local hp = GetHealthPercentage("target");
  if UnitCanAttack("player", "target") == true or GetTargetFullName() == nil then
    hp = GetHealthPercentage("player");
  end

  if hp < 90 and IsCastable("Flash of Light", 7700) then
    WowCyborg_CURRENTATTACK = "Flash of Light";
    return SetSpellRequest(flashOfLight);
  end

  if hp < 95 and IsCastable("Holy Light", 8000) then
    WowCyborg_CURRENTATTACK = "Holy Light";
    return SetSpellRequest(holyLight);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Holy pala rotation loaded");