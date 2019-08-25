--[[
  Button    Spell
  1         Wrath
  2         Moonfire
  6         Attack
  SHIFT+1   Rejuvenation
  SHIFT+2   Thorns
  SHIFT+3   Healing Wave
  SHIFT+4   Mark of the Wild
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
local startedWaitAt = 0;
local wrath = "1";
local moonfire = "2";
local attack = "6";

local rejuvenation = "SHIFT+1";
local thorns = "SHIFT+2";
local healingTouch = "SHIFT+3";
local motw = "SHIFT+4";

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
        if IsCastableAtFriendlyUnit(highestDamageTaken.name, "Lifebloom", 0) then
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
        --if IsCastableAtFriendlyUnit(members[groupindex].name, "Healing Wave", 0) then
          lowestHealth = { hp = hp, name = members[groupindex].name }
        -- end
      end
    end
  end

  if lowestHealth ~= nil then
    return lowestHealth.name, 0;
  end

  return nil; 
end

function IsMelee()
  return CheckInteractDistance("target", 5);
end

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
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
  
  if lastTarget.time + 2 < GetTime() then
    local friendlyTargetName, damageAmount = FindFriendlyHealingTarget();
    if friendlyTargetName ~= nil then
      local memberindex = GetMemberIndex(friendlyTargetName);
      if memberindex ~= nil then
        lastTarget = {
          name = friendlyTargetName,
          index = memberindex,
          damageAmount = damageAmount,
          time = GetTime()
        };
      end
    end
  end

  if lastTarget ~= nil and lastTarget.name ~= nil and lastTarget.name ~= GetTargetFullName() then
    local playerHp = GetHealthPercentage(lastTarget.name);
    if playerHp < 100 then
      WowCyborg_CURRENTATTACK = "Target partymember " .. lastTarget.name;
      return SetSpellRequest("CTRL+" .. lastTarget.index + 3);
    end
  end

  local hp = GetHealthPercentage("target");

  local motwBuff = FindBuff("player", "Mark of the Wild");
  if motwBuff == nil then
    if IsCastable("Mark of the Wild", 20) then
      WowCyborg_CURRENTATTACK = "Mark of the Wild";
      return SetSpellRequest(motw);
    end
  end
  
  local thornsBuff = FindBuff("player", "Thorns");
  if thornsBuff == nil then
    if IsCastable("Thorns", 35) then
      WowCyborg_CURRENTATTACK = "Thorns";
      return SetSpellRequest(thorns);
    end
  end

  if hp < 90 then
    if IsCastable("Rejuvenation", 25) then
      WowCyborg_CURRENTATTACK = "Rejuvenation";
      return SetSpellRequest(rejuvenation);
    end
  end

  if hp < 50 then
    if IsCastable("Healing Touch", 25) then
      WowCyborg_CURRENTATTACK = "Healing Touch";
      return SetSpellRequest(healingTouch);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function CreateEmoteListenerFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("CHAT_MSG_TEXT_EMOTE");
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
    if string.find(command, "fart", 1, true) then
      print("Mounting");
      SetSpellRequest(mount);
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

print("Classic druid follower rotation loaded");
CreateEmoteListenerFrame();
CreateDamageTakenFrame();