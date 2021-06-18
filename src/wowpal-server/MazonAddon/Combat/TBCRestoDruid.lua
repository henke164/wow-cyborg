--[[
  Button    Spell
  1         Regrowth
  3         Rejuvenation
  4         Swiftmend
  5         Wild Growth
]]--

local regrowthCost =  485;
local swiftmendCost =  195;
local rejuvenationCost =  335;
local isDrinking = false;

local startedFollowingAt = 0;
local startedAssistAt = 0;
local startedDrinkAt = 0;
local incomingDamage = {};
local damageInLast5Seconds = {};
local regrowth = {};
regrowth[1] = 1;
regrowth[2] = 2;
regrowth[3] = 3;
regrowth[4] = 4;
regrowth[5] = 5;

local rejuvenation = {};
rejuvenation[1] = 6;
rejuvenation[2] = 7;
rejuvenation[3] = 8;
rejuvenation[4] = 9;
rejuvenation[5] = 0;

local swiftmend = {};
swiftmend[1] = "F+1";
swiftmend[2] = "F+2";
swiftmend[3] = "F+3";
swiftmend[4] = "F+4";
swiftmend[5] = "F+5";

local healingTouch = {};
healingTouch[1] = "SHIFT+1";
healingTouch[2] = "SHIFT+2";
healingTouch[3] = "SHIFT+3";
healingTouch[4] = "SHIFT+4";
healingTouch[5] = "SHIFT+5";

local cancelCast = "F+6";

local follow = "F+8";
local assist = "F+9";
local drink = "SHIFT+9";

local healingTarget = {
  index = nil,
  name = nil,
  time = 0,
  damageAmount = 0
};

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

function FindFriendlyHealingTarget()
  local highestDamageTaken = nil;
  for k,v in pairs(damageInLast5Seconds) do
    local hpp = GetHealthPercentage(k);
    if highestDamageTaken == nil or highestDamageTaken.amount > v then
      if IsSpellInRange("Rejuvenation", k) then
        if tostring(hpp) ~= "-nan(ind)" and hpp > 0 and hpp < 90 then
          if GetTargetFullName() ~= k then
            local speed = GetUnitSpeed("player");
            if speed > 0 then
              local rejuBuff = FindBuff(k, "Rejuvenation");
              if rejuBuff == nil then
                highestDamageTaken = { name = k, amount = v };
              end
            else
              highestDamageTaken = { name = k, amount = v };
            end
          end
        end
      end
    end
  end

  local lowestHealth = nil

  --find lowest hp
  local members = GetGroupRosterInfo();
  for groupindex = 1,5 do
    if members[groupindex] == nil or members[groupindex].name == nil then
      break;
    end
    
    local hp = GetHealthPercentage(members[groupindex].name);
    if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 95 then
      if lowestHealth == nil or hp <= lowestHealth.hp then
        if IsSpellInRange("Rejuvenation", members[groupindex].name) then
          lowestHealth = { hp = hp, name = members[groupindex].name }
        end
      end
    end
  end

  if highestDamageTaken ~= nil then
    if lowestHealth ~= nil then
      local hp1 = GetHealthPercentage(highestDamageTaken.name);
      local hp2 = lowestHealth.hp;
      if hp1 > hp2 then
        return lowestHealth.name, 0;
      end
    end
    return highestDamageTaken.name, highestDamageTaken.amount;
  end

  if lowestHealth ~= nil then
    return lowestHealth.name, 0;
  end

  return nil; 
end

function GetTankName()
  local members = GetGroupRosterInfo();
  for groupindex = 1,5 do
    if members[groupindex] == nil or members[groupindex].name == nil then
      break;
    end
    
    if members[groupindex].role == "TANK" then
      return members[groupindex].name, groupindex;
    end
  end

  return nil;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  if startedFollowingAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Following...";
    return SetSpellRequest(follow);
  end

  if startedAssistAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Assisting...";
    return SetSpellRequest(assist);
  end
  
  if startedDrinkAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Drinking...";
    return SetSpellRequest(drink);
  end

  if UnitChannelInfo("player") == "Tranquility" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if isDrinking == true then
    WowCyborg_CURRENTATTACK = "Drinking...";
    return SetSpellRequest(nil);
  end
  
  local spell, _, _, _, endTime = UnitCastingInfo("player")
  if spell == "Regrowth" and healingTarget.name ~= nil then
    local hp = GetHealthPercentage(healingTarget.name)
    if hp > 80 then
      WowCyborg_CURRENTATTACK = "Cancel cast";
      return SetSpellRequest(cancelCast);
    end
  end

  if healingTarget.time + 0.2 < GetTime() then
    local friendlyTargetName, damageAmount = FindFriendlyHealingTarget();
    if friendlyTargetName ~= nil then
      local memberindex = GetMemberIndex(friendlyTargetName);
      if memberindex == nil then
        WowCyborg_CURRENTATTACK = "No index";
        return SetSpellRequest(nil);
      end

      healingTarget = {
        name = friendlyTargetName,
        index = memberindex,
        damageAmount = damageAmount,
        time = GetTime()
      };
    end
  end

  local speed = GetUnitSpeed("player");

  if healingTarget.name == nil then
    WowCyborg_CURRENTATTACK = "no ht";
    return SetSpellRequest(nil);
  end

  local hp = GetHealthPercentage(healingTarget.name);
  if hp > 95 then
    WowCyborg_CURRENTATTACK = "Full hp: " .. healingTarget.name;
    return SetSpellRequest(nil);
  end

  local rejuvenationHot = FindBuff(healingTarget.name, "Rejuvenation");
  if rejuvenationHot == nil and IsCastableAtFriendlyUnit(healingTarget.name, "Rejuvenation", rejuvenationCost) then
    WowCyborg_CURRENTATTACK = "Rejuvenation " .. healingTarget.index;
    return SetSpellRequest(rejuvenation[healingTarget.index]);
  end

  if hp <= 40 and healingTarget ~= nil then
    if IsCastableAtFriendlyUnit(healingTarget.name, "Swiftmend", swiftmendCost) then
      WowCyborg_CURRENTATTACK = "Swiftmend";
      return SetSpellRequest(swiftmend[healingTarget.index]);
    end
  end

  local regrowthHot = FindBuff(healingTarget.name, "Regrowth");
  if regrowthHot == nil and hp <= 50 and IsCastableAtFriendlyUnit(healingTarget.name, "Regrowth", regrowthCost) and speed == 0 then
    WowCyborg_CURRENTATTACK = "Regrowth";
    return SetSpellRequest(regrowth[healingTarget.index]);
  end
  
  if hp <= 70 and IsCastableAtFriendlyUnit(healingTarget.name, "Healing Touch", 100) and speed == 0 then
    WowCyborg_CURRENTATTACK = "Healing Touch";
    return SetSpellRequest(healingTouch[healingTarget.index]);
  end

  WowCyborg_CURRENTATTACK = "Nothing: " .. healingTarget.name;
  return SetSpellRequest(nil);
end

function CreateDamageTakenFrame()
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

  frame:SetScript("OnEvent", function()
    local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, amountDetails = CombatLogGetCurrentEventInfo()

    if UnitInParty(destName) == false and destGUID ~= UnitGUID("player") then
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

      if incomingDamage[destName] == nil then
        incomingDamage[destName] = {};
      end

      tinsert(incomingDamage[destName], 1, DamageDetails);

      local cutoff = timestamp - 5;
      damageInLast5Seconds[destName] = 0
      for i = #incomingDamage[destName], 1, -1 do
          local damage = incomingDamage[destName][i]
          if damage.timestamp < cutoff then
            incomingDamage[destName][i] = nil
          else
            damageInLast5Seconds[destName] = damageInLast5Seconds[destName] + incomingDamage[destName][i].damage;
          end
      end
    end

  end)
end

function CreateEmoteListenerFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("CHAT_MSG_PARTY_LEADER");
  frame:SetScript("OnEvent", function(self, event, ...)
    command = ...;
    if string.find(command, "follow", 1, true) then
      print("Following");
      startedFollowingAt = GetTime();
      isDrinking = false;
    end
    if string.find(command, "wait", 1, true) then
      print("Waiting");
      startedAssistAt = GetTime();
      isDrinking = false;
    end
    if string.find(command, "drink", 1, true) then
      print("drinking");
      startedDrinkAt = GetTime();
      isDrinking = true;
    end
  end)
end

print("TBC Resto druid follower rotation loaded");
CreateEmoteListenerFrame();
CreateDamageTakenFrame();