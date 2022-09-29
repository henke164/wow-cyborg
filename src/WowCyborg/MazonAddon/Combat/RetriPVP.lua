--[[
  Button    Spell
]]--
local wakeOfashes = 1;
local bladeOfjustice = 2;
local judgment = 3;
local hammerOfwrath = 4;
local crusaderStrike = 5;
local templarsVerdict = 6;
local divineStorm = 7;
local vanqHammer = 8;
local consecration = 9;

local wog = {};
wog[1] = "F+5";
wog[2] = "F+6";
wog[3] = "F+7";
wog[4] = "F+8";
wog[5] = "F+9";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "F5",
  "F7",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD5",
  "NUMPAD9",
  "0",
  "F",
  "R",
  "LSHIFT",
  "ESCAPE"
}

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

function FindHealingTarget()
  local lowestHealth = nil
  local members = GetGroupRosterInfo();
  for groupindex = 1,5 do
    if members[groupindex] == nil or members[groupindex].name == nil then
      break;
    end
    
    local hp = GetHealthPercentage(members[groupindex].name);
    if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 100 then
      if lowestHealth == nil or hp <= lowestHealth.hp then
        if IsSpellInRange("Word of Glory", members[groupindex].name) == 1 then
          lowestHealth = { hp = hp, name = members[groupindex].name }
        end
      end
    end
  end

  if lowestHealth ~= nil and lowestHealth.hp < 60 then
    return lowestHealth.name, 0;
  end

  return nil; 
end

function GetMemberIndex(name)
  local group = GetGroupRosterInfo();
  for groupindex = 1,25 do
    if group[groupindex] == nil then
      return nil;
    end

    if group[groupindex].name == nil then
      return nil;
    end

    if group[groupindex].name == name then
      return groupindex;
    end
  end
  return nil;
end

function IsMelee()
  return IsSpellInRange("Crusader Strike") == 1;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(burst)
  local holyPower = UnitPower("player", 9);

  local friendlyTargetName = FindHealingTarget();
  if friendlyTargetName ~= nil and IsCastable("Word of Glory", 0) then
    if (holyPower > 2 and GetHealthPercentage(friendlyTargetName) < 50) then
      local memberindex = GetMemberIndex(friendlyTargetName);
      WowCyborg_CURRENTATTACK = "Word of Glory " .. friendlyTargetName;
      return SetSpellRequest(wog[memberindex]);
    end
  end

  if (IsMelee() and holyPower >= 5) then
    if IsCastableAtEnemyTarget("Vanquisher's Hammer", 0) then
      WowCyborg_CURRENTATTACK = "VanqHammer";
      return SetSpellRequest(vanqHammer);
    end

    if IsCastableAtEnemyTarget("Templar's Verdict", 0) then
      WowCyborg_CURRENTATTACK = "Templar's Verdict";
      return SetSpellRequest(templarsVerdict);
    end
  end
  
  if (IsMelee() and holyPower <= 2 and IsCastableAtEnemyTarget("Wake of Ashes", 0)) then
    WowCyborg_CURRENTATTACK = "Wake of Ashes";
    return SetSpellRequest(wakeOfashes);
  end
  
  if (IsCastableAtEnemyTarget("Judgment", 0)) then
    WowCyborg_CURRENTATTACK = "Judgment";
    return SetSpellRequest(judgment);
  end
  
  if (IsCastableAtEnemyTarget("Hammer of Wrath", 0)) then
    WowCyborg_CURRENTATTACK = "Hammer of Wrath";
    return SetSpellRequest(hammerOfwrath);
  end
  
  if (holyPower <= 3 and IsCastableAtEnemyTarget("Blade of Justice", 0)) then
    WowCyborg_CURRENTATTACK = "Blade of Justice";
    return SetSpellRequest(bladeOfjustice);
  end

  local csCharges = GetSpellCharges("Crusader Strike");

  if (csCharges == 2 and IsCastableAtEnemyTarget("Crusader Strike", 0)) then
    WowCyborg_CURRENTATTACK = "Crusader Strike";
    return SetSpellRequest(crusaderStrike);
  end
 
  
  if (IsMelee() and holyPower >= 3) then
    if IsCastableAtEnemyTarget("Vanquisher's Hammer", 0) then
      WowCyborg_CURRENTATTACK = "VanqHammer";
      return SetSpellRequest(vanqHammer);
    end
  
    if IsCastableAtEnemyTarget("Templar's Verdict", 0) then
      WowCyborg_CURRENTATTACK = "Templar's Verdict";
      return SetSpellRequest(templarsVerdict);
    end
  end
  
  if (IsMelee() and IsCastableAtEnemyTarget("Consecration", 0)) then
    WowCyborg_CURRENTATTACK = "Consecration";
    return SetSpellRequest(consecration);
  end

  if (IsCastableAtEnemyTarget("Crusader Strike", 0)) then
    WowCyborg_CURRENTATTACK = "Crusader Strike";
    return SetSpellRequest(crusaderStrike);
  end
  
  return SetSpellRequest(nil);
end

function IsMelee()
  return IsSpellInRange("Rebuke", "target") ~= 0;
end

print("Retri pala rotation loaded");