--[[
  Button    Spell
  Ctrl+1    Macro: /target player
  Ctrl+2    Macro: /target party1
  Ctrl+3    Macro: /target party2
  Ctrl+4    Macro: /target party3
  Ctrl+5    Macro: /target party4
  1         Healing Wave
  2         Riptide
  3         Healing Surge
  4         Chain heal
  5         Healing Stream Totem
]]--

local incomingDamage = {};
local damageInLast5Seconds = {};
local healingWave = 1;
local riptide = 2;
local healingSurge = 3;
local chainHeal = 4;
local healingStreamTotem = 5;

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
        if IsCastableAtFriendlyUnit(highestDamageTaken.name, "Riptide", 0) then
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
    if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 100 then
      if lowestHealth == nil or hp <= lowestHealth.hp then
        if IsCastableAtFriendlyUnit(members[groupindex].name, "Riptide", 0) then
          lowestHealth = { hp = hp, name = members[groupindex].name }
        end
      end
    end
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
  return SetSpellRequest(nil);
end

function IsHealingStreamUp()
  for index=1,MAX_TOTEMS do
    local arg1, totemName, startTime, duration, icon = GetTotemInfo(1);
    if totemName == "Healing Stream Totem" then
      return true;
    end
  end
  return false;
end

local lastTarget = {
  index = nil,
  name = nil,
  time = 0,
  damageAmount = 0
};

function RenderSingleTargetRotation()
  if IsInGroup() == false then
    WowCyborg_CURRENTATTACK = "Not in group";
    return SetSpellRequest(nil);
  end

  local riptideCharges = GetSpellCharges("Riptide");

  if lastTarget.time + 1 < GetTime() then
    local friendlyTargetName, damageAmount = FindFriendlyHealingTarget();
    if friendlyTargetName ~= nil then
      local memberindex = GetMemberIndex(friendlyTargetName);
      if memberindex == nil then
        WowCyborg_CURRENTATTACK = "-";
        return SetSpellRequest(nil);
      end
      lastTarget = {
        name = friendlyTargetName,
        index = memberindex,
        damageAmount = damageAmount,
        time = GetTime()
      };
    end
  end

  if lastTarget ~= nil and lastTarget.name ~= nil and lastTarget.name ~= GetTargetFullName() then
    WowCyborg_CURRENTATTACK = "Target partymember " .. lastTarget.name;
    return SetSpellRequest("CTRL+" .. lastTarget.index);
  end

  if AoeHealingRequired() then
    local healingStreamCharges = GetSpellCharges("Healing Stream Totem");
    if IsHealingStreamUp() == false and healingStreamCharges > 0 then
      WowCyborg_CURRENTATTACK = "Healing Stream Totem";
      return SetSpellRequest(healingStreamTotem);
    end
  end

  if AoeHealingRequired() and IsCastable("Chain Heal", 5000) then
    if FindBuff("target", "Riptide") == nil and IsCastableAtFriendlyTarget("Riptide", 1600) and riptideCharges > 0 then
      WowCyborg_CURRENTATTACK = "Riptide";
      return SetSpellRequest(riptide);
    end
    WowCyborg_CURRENTATTACK = "Chain Heal";
    return SetSpellRequest(chainHeal);
  end

  if UnitCanAttack("player", "target") == true then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local hp = GetHealthPercentage("target");
  if hp == 100 then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if hp <= 90 and FindBuff("target", "Riptide") == nil and IsCastableAtFriendlyTarget("Riptide", 1600) and riptideCharges > 0 then
    WowCyborg_CURRENTATTACK = "Riptide";
    return SetSpellRequest(riptide);
  end

  if hp <= 70 and lastTarget ~= nil then
    if IsCastableAtFriendlyTarget("Healing Surge", 3800) then
      WowCyborg_CURRENTATTACK = "Healing Surge";
      return SetSpellRequest(healingSurge);
    end
  end

  if hp <= 90 and IsCastableAtFriendlyTarget("Healing Wave", 1800) then
    WowCyborg_CURRENTATTACK = "Healing Wave";
    return SetSpellRequest(healingWave);
  end

  WowCyborg_CURRENTATTACK = "-";
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
print("Resto shaman rotation loaded");
CreateDamageTakenFrame();