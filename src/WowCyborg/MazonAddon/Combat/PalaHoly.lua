--[[
  Button    Spell
]]--

local consecration = "F+1";
local hammerOfWrath = "1";
local shieldOfTheRighteous = "V";
local holyShock = 2;
local crusaderStrike = 3;
local judgment = 4;
local prism = "T";

local wog = {};
wog[1] = "F+5";
wog[2] = "F+6";
wog[3] = "F+7";
wog[4] = "F+8";
wog[5] = "F+9";
wog[6] = "1";

local shock = {};
shock[1] = "6";
shock[2] = "7";
shock[3] = "8";
shock[4] = "9";
shock[5] = "0";
shock[6] = "2";

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
  if name == "player" then
    return 1;
  end
  
  if name == "mouseover" then
    return 6;
  end

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

function AoeHealingRequired()
  local lowCount = 0;
  local hp = GetHealthPercentage("player");

  if hp < 95 then
    lowCount = lowCount + 1;
  end

  if IsInRaid("player") then
    for groupindex = 1,25 do
      local php = GetHealthPercentage("raid" .. groupindex);
      if tostring(php) ~= "-nan(ind)" and php > 1 and php < 95 then
        if IsSpellInRange("Word of Glory", "raid" .. groupindex) == 1 then
          lowCount = lowCount + 1;
        end
      end
    end
  else
    for groupindex = 1,5 do
      local php = GetHealthPercentage("party" .. groupindex);
      if tostring(php) ~= "-nan(ind)" and php > 1 and php < 95 then
        if IsSpellInRange("Word of Glory", "party" .. groupindex) == 1 then
          lowCount = lowCount + 1;
        end
      end
    end
  end
  
  if IsInRaid("player") then
    return lowCount > 4;
  end

  return lowCount > 1;
end

function FindHealingTarget(minMissingHealth)
  local members = GetGroupRosterInfo();
  local missingHealth = GetMissingHealth("player");
  local lowestHealth = { hp = missingHealth, name = "player" }

  if IsInRaid("player") then
    if UnitCanAttack("player", "mouseover") == false then
      local hp = GetHealthPercentage("mouseover");
      if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 99 then
        local missingHealth = GetMissingHealth("mouseover");
        if missingHealth >= lowestHealth.hp then
          if IsSpellInRange("Word of Glory", "mouseover") == 1 then
            lowestHealth = { hp = missingHealth, name = "mouseover" }
          end
        end
      end
    end
  else
    for groupindex = 1,5 do
      if members[groupindex] == nil or members[groupindex].name == nil then
        break;
      end
      
      local hp = GetHealthPercentage(members[groupindex].name);
      if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 99 then
        local missingHealth = GetMissingHealth(members[groupindex].name);
        if missingHealth >= lowestHealth.hp then
          if IsSpellInRange("Word of Glory", members[groupindex].name) == 1 then
            lowestHealth = { hp = missingHealth, name = members[groupindex].name }
          end
        end
      end
    end
  end

  if lowestHealth ~= nil and lowestHealth.hp > minMissingHealth then
    return lowestHealth.name, 0;
  end

  return nil; 
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

  if IsInRaid("player") then
    skipDps = true;
  end

  local speed = GetUnitSpeed("player");
  local divinePurpose = FindBuff("player", "Divine Purpose");
  local shiningRighteousness = FindBuff("player", "Shining Righteousness");
  local shockTarget = FindHealingTarget(150000);
  local holyPower = UnitPower("player", 9);
  local playerHp = GetHealthPercentage("player");

  if playerHp < 10 and IsCastable("Divine Shield", 5000) then
    WowCyborg_CURRENTATTACK = "Divine Shield";
    return SetSpellRequest("F");
  end

  if AoeCritical() and IsCastable("Aura Mastery", 5000) then
    WowCyborg_CURRENTATTACK = "Aura Mastery";
    return SetSpellRequest("F+4");
  end

  if AoeHealingRequired() then
    if IsCastable("Beacon of Virtue", 100000) then
      WowCyborg_CURRENTATTACK = "Beacon of Virtue";
      return SetSpellRequest(5);
    end

    if IsCastable("Holy Prism", 65000) then
      WowCyborg_CURRENTATTACK = "Holy Prism";
      return SetSpellRequest(prism);
    end

    local empyrianBuff = FindBuff("player", "Empyrean Legacy");
    if empyrianBuff == nil and IsCastableAtEnemyTarget("Judgment", 60000) then
      WowCyborg_CURRENTATTACK = "Judgment";
      return SetSpellRequest(judgment);
    end
  end

  if shockTarget ~= nil then
    local missingHp = GetMissingHealth(shockTarget);
    if missingHp > 300000 and IsCastable("Word of Glory", 0) and (holyPower > 2 or divinePurpose ~= nil) then
      local memberindex = GetMemberIndex(shockTarget);
      WowCyborg_CURRENTATTACK = "Word of Glory " .. shockTarget;
      return SetSpellRequest(wog[memberindex]);
    end
    
    if GetSpellCharges("Holy Shock") > 0 and IsCastable("Holy Shock", 65000) then
      local memberindex = GetMemberIndex(shockTarget);
      WowCyborg_CURRENTATTACK = "Shock " .. shockTarget;
      return SetSpellRequest(shock[memberindex]);
    end
    
    if speed == 0 and shockTarget == "mouseover" and IsCastable("Flash of Light", 45000) then
      WowCyborg_CURRENTATTACK = "Flash of Light " .. shockTarget;
      return SetSpellRequest("X");
    end
  end
  
  if UnitCanAttack("player", "target") == true then
    if WowCyborg_INCOMBAT then
      local targetHp = GetHealthPercentage("target");
      local consec = FindDebuff("target", "Consecration");
      if shockTarget == nil and consec == nil and IsMelee() and IsCastable("Consecration", 0) and speed == 0 then
        WowCyborg_CURRENTATTACK = "Consecration";
        return SetSpellRequest(consecration);
      end

      if IsInRaid("player") == false then
        if IsCastableAtEnemyTarget("Hammer of Wrath", 0) then
          WowCyborg_CURRENTATTACK = "Hammer of Wrath";
          return SetSpellRequest(hammerOfWrath);
        end
      end

      if skipDps == false then
        if holyPower >= 3 then
          if IsMelee() then
            WowCyborg_CURRENTATTACK = "Shield of the Righteous";
            return SetSpellRequest(shieldOfTheRighteous);
          end
        end
      end
    
      if IsCastableAtEnemyTarget("Judgment", 42000) then
        WowCyborg_CURRENTATTACK = "Judgment";
        return SetSpellRequest(judgment);
      end
      
      if holyPower < 5 then
        local hsCharges = GetSpellCharges("Holy Shock");
        if hsCharges > 1 and IsCastableAtEnemyTarget("Holy Shock", 65000) then
          WowCyborg_CURRENTATTACK = "Holy Shock";
          return SetSpellRequest(holyShock);
        end

        if IsCastableAtEnemyTarget("Crusader Strike", 15000) then
          WowCyborg_CURRENTATTACK = "Crusader Strike";
          return SetSpellRequest(crusaderStrike);
        end
      end
    end 

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Holy pala rotation loaded");