--[[
  Button    Spell
  Ctrl+1    Macro for following focus "/follow focus"
  Ctrl+2    Macro for assisting focus "/assist focus"
  Ctrl+3    Mount
  
  Ctrl+4    Macro: /target player
  Ctrl+5    Macro: /target party1
  Ctrl+6    Macro: /target party2
  Ctrl+7    Macro: /target party3
  Ctrl+8    Macro: /target party4
]]--

local incomingDamage = {};
local damageInLast5Seconds = {};
local startedFollowingAt = 0;
local startedAssistAt = 0;
local startedMountingAt = 0;
local startedWaitAt = 0;

local lesserHealingWave = "1";
local healingWaveMed = "2";
local healingWave = "3";
local manatide = "4";
local chainHeal = "5";
local stopcasting = "9";

local follow = "CTRL+1";
local assist = "CTRL+2";
local mount = "CTRL+3";
local back = "CTRL+9";

local lastTarget = {
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


function FindFriendlyHealingTarget()
  local highestDamageTaken = nil;
  for k,v in pairs(damageInLast5Seconds) do
    if highestDamageTaken == nil or highestDamageTaken.amount > v then
      highestDamageTaken = { name = k, amount = v };
    end
  end

  if highestDamageTaken ~= nil then
    local hpp = GetHealthPercentage(highestDamageTaken.name);
    if tostring(hpp) ~= "-nan(ind)" and hpp > 0 and hpp < 80 then
      if GetTargetFullName() ~= highestDamageTaken.name then
        if IsCastableAtFriendlyUnit(highestDamageTaken.name, "Healing Wave", 0) then
          return highestDamageTaken.name, highestDamageTaken.amount;
        end
      end
    end
  end

  local lowestHealth = nil

  local members = GetGroupRosterInfo();
  for groupindex = 1,5 do
    if members[groupindex] == nil or members[groupindex].name == nil then
      break;
    end
    
    local hp = GetHealthPercentage(members[groupindex].name);
    if tostring(hp) ~= "-nan(ind)" and hp > 1 and hp < 100 then
      if lowestHealth == nil or hp <= lowestHealth.hp then
        if IsSpellInRange("Healing Wave", members[groupindex].name) then
          lowestHealth = { hp = hp, name = members[groupindex].name }
        end
      end
    end
  end

  if lowestHealth ~= nil then
    if IsSpellInRange("Healing Wave", lowestHealth.name) then
      return lowestHealth.name, 0;
    end
  end

  return nil; 
end

function AoeHealingRequired()
  local lowCount = 0;
  local hp = GetHealthPercentage("player");

  if hp < 95 then
    lowCount = lowCount + 1;
  end

  for groupindex = 1,10 do
    local php = GetHealthPercentage("raid" .. groupindex);
    if tostring(php) ~= "-nan(ind)" and php > 1 and php < 90 then
      lowCount = lowCount + 1;
    end
  end
  
  return lowCount > 2;
end

-- Multi target
function RenderMultiTargetRotation()
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

-- Single target
function RenderSingleTargetRotation()
  if startedFollowingAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Following...";
    return SetSpellRequest(follow);
  end

  if startedAssistAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Assisting...";
    return SetSpellRequest(assist);
  end
  
  if startedWaitAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Waiting...";
    return SetSpellRequest(back);
  end

  if startedMountingAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Mounting...";
    return SetSpellRequest(mount);
  end  
  
  local hp = GetHealthPercentage("target");
  local currentCastingSpell = CastingInfo("player");  
  local mana = (UnitPower("player") / UnitPowerMax("player")) * 100;
  
  if mana < 50 then
    if IsCastable("Mana Tide Totem", 40) then
      return SetSpellRequest(manatide);
    end
  end

  local lesserHealAt = 70;
  local mediumHealAt = 85;
  local greaterHealAt = 60;
  
  local currentCastingSpell, _, _, _, _, _, _, _, id = CastingInfo("player");

  if currentCastingSpell == "Healing Wave" then
    if id == 10396 and hp >= greaterHealAt then
      return SetSpellRequest(stopcasting);
    end

    if id == 939 and hp >= mediumHealAt then
      return SetSpellRequest(stopcasting);
    end
  end
  
  if currentCastingSpell == "Lesser Healing Wave" then
    if hp >= lesserHealAt then
      return SetSpellRequest(stopcasting);
    end
  end

  if AoeHealingRequired() then
    if IsCastableAtFriendlyTarget("Chain Heal", 385) and 
      currentCastingSpell ~= "Chain Heal" 
    then
      WowCyborg_CURRENTATTACK = "Chain Heal";
      return SetSpellRequest(chainHeal);
    end
  end

  if hp < greaterHealAt then
    if IsCastableAtFriendlyTarget("Healing Wave", 532) and 
      currentCastingSpell ~= "Healing Wave" 
    then
      WowCyborg_CURRENTATTACK = "Healing Wave";
      return SetSpellRequest(healingWave);
    end
  end

  if hp < mediumHealAt then
    if IsCastableAtFriendlyTarget("Healing Wave", 190) then
      WowCyborg_CURRENTATTACK = "Healing Wave Med";
      return SetSpellRequest(healingWaveMed);
    end
  end

  if hp < lesserHealAt then
    if IsCastableAtFriendlyTarget("Lesser Healing Wave", 290) then
      WowCyborg_CURRENTATTACK = "Lesser Healing Wave";
      return SetSpellRequest(lesserHealingWave);
    end
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function CreateEmoteListenerFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("CHAT_MSG_WHISPER");
  frame:SetScript("OnEvent", function(self, event, ...)
    command = ...;
    if string.find(command, "follow", 1, true) then
      print("Following");
      startedFollowingAt = GetTime();
    end
    if string.find(command, "wait", 1, true) then
      print("Waiting");
      startedAssistAt = GetTime();
    end
    if string.find(command, "drink", 1, true) then
      print("Drinking");
      startedMountingAt = GetTime();
    end
    if string.find(command, "waves", 1, true) then
      print("Fall back");
      startedWaitAt = GetTime();
    end
  end)
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

print("Classic shaman follower rotation loaded");
CreateEmoteListenerFrame();
CreateDamageTakenFrame();