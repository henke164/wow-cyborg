--[[
  Button    Spell
  Ctrl+1    Macro: /target player
  Ctrl+2    Macro: /target party1
  Ctrl+3    Macro: /target party2
  Ctrl+4    Macro: /target party3
  Ctrl+5    Macro: /target party4
  1         Renewing Mist
  2         Soothing Mist
  3         Enveloping Mist
  4         Vivify
  5         Essence Font
]]--

local incomingDamage = {};
local damageInLast5Seconds = {};
local renewingMist = 1;
local soothingMist = 2;
local envelopingMist = 3;
local vivify = 4;
local essenceFont = 5;

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
  for k,v in pairs(damageInLast5Seconds) do
    if v > 7000 then
      lowCount = lowCount + 1;
    end
  end

  return lowCount > 2;
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
    if hpp < 80 then
      if GetTargetFullName() ~= highestDamageTaken.name then
        return highestDamageTaken.name;
      end
    end
  end

  local lowestHealth = nil

  local members = GetGroupRosterInfo();
  for groupindex = 1,25 do
    if members[groupindex] == nil or members[groupindex].name == nil then
      break;
    end
    
    local hp = GetHealthPercentage(members[groupindex].name);
    if hp > 0 and hp < 100 then
      if lowestHealth == nil or hp <= lowestHealth.hp then
        lowestHealth = { hp = hp, name = members[groupindex].name }
      end
    end
  end

  if lowestHealth ~= nil then
    return lowestHealth.name;
  end

  return nil; 
end

function RenderMultiTargetRotation()
  return SetSpellRequest(nil);
end

local lastTarget = {
  index = nil,
  name = nil,
  time = 0
};

function RenderSingleTargetRotation()
  if lastTarget.time + 2 < GetTime() then
    local friendlyTargetName = FindFriendlyHealingTarget();
    if friendlyTargetName ~= nil then
      local memberindex = GetMemberIndex(friendlyTargetName);
      if memberindex == nil then
        return SetSpellRequest(nil);
      end
      lastTarget = {
        name = friendlyTargetName,
        index = memberindex,
        time = GetTime()
      };
    end
  end

  if lastTarget ~= nil and lastTarget.name ~= nil and lastTarget.name ~= GetTargetFullName() then
    WowCyborg_CURRENTATTACK = "Target partymember " .. lastTarget.name;
    return SetSpellRequest("CTRL+" .. lastTarget.index);
  end

  if UnitChannelInfo("player") == "Essence Font" then
    return SetSpellRequest(nil);
  end
  
  if AoeHealingRequired() and IsCastable("Essence Font", 7200) then
    return SetSpellRequest(essenceFont);
  end

  if UnitCanAttack("player", "target") == true then
    return SetSpellRequest(nil);
  end

  local hp = GetHealthPercentage("target");
  if hp == 100 then
    return SetSpellRequest(nil);
  end

  local rmBuff = FindBuff("target", "Renewing Mist");
  if rmBuff == nil then
    local rmCharges = GetSpellCharges("Renewing Mist");
    if rmCharges > 0 and IsCastableAtFriendlyTarget("Renewing Mist", 2800) then
      return SetSpellRequest(renewingMist);
    end
  end

  if hp <= 80 and IsCastableAtFriendlyTarget("Soothing Mist", 800) and UnitChannelInfo("player") ~= "Soothing Mist" then
    return SetSpellRequest(soothingMist);
  end

  local emBuff = FindBuff("target", "Enveloping Mist");
  if emBuff == nil and hp <= 60 and IsCastableAtFriendlyTarget("Enveloping Mist", 5200) then
    return SetSpellRequest(envelopingMist);
  end

  if hp <= 75 and IsCastableAtFriendlyTarget("Vivify", 3500) then
    return SetSpellRequest(vivify);
  end

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
print("Mistweaver monk rotation loaded");
CreateDamageTakenFrame();