--[[
  Button    Spell
  Ctrl+1    Macro: /target player
  Ctrl+2    Macro: /target party1
  Ctrl+3    Macro: /target party2
  Ctrl+4    Macro: /target party3
  Ctrl+5    Macro: /target party4
  1         Regrowth
  2         Lifebloom
  3         Rejuvenation
  4         Swiftmend
  5         Wild Growth
]]--

local incomingDamage = {};
local damageInLast5Seconds = {};
local regrowth = 1;
local lifebloom = 2;
local rejuvenation = 3;
local swiftmend = 4;
local wildGrowth = 5;
local cenarionWard = 6;

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
    if tostring(hpp) ~= "-nan(ind)" and hpp > 0 and hpp < 80 then
      if GetTargetFullName() ~= highestDamageTaken.name then
        if IsSpellInRange("Lifebloom", highestDamageTaken.name) then
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
        if IsSpellInRange("Lifebloom", members[groupindex].name) then
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
  return RenderSingleTargetRotation(true);
end

local lastTarget = {
  index = nil,
  name = nil,
  time = 0,
  damageAmount = 0
};

function RenderSingleTargetRotation(disableAutoTarget)
  if disableAutoTarget == nil then
    local tankName, index = GetTankName();
    if tankName ~= nil and FindBuff(tankName, "Lifebloom") == nil then
      if IsCastableAtFriendlyUnit(tankName, "Lifebloom", 2240) and IsSpellInRange("Lifebloom", tankName) then
        local tankHp = GetHealthPercentage(tankName);
        if tankHp > 0 then
          local targetName = UnitName("target");
          if targetName == nil or string.match(tankName, targetName) == nil then
            WowCyborg_CURRENTATTACK = "Target tank: " .. tankName;
            return SetSpellRequest("CTRL+" .. index);
          else
            WowCyborg_CURRENTATTACK = "Lifebloom";
            return SetSpellRequest(lifebloom);
          end
        end
      end
    end

    if lastTarget.time + 2 < GetTime() then
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

    if lastTarget ~= nil and lastTarget.name ~= nil and lastTarget.name ~= GetTargetFullName() and lastTarget.time + 2 > GetTime() then
      WowCyborg_CURRENTATTACK = "Target partymember " .. lastTarget.name;
      return SetSpellRequest("CTRL+" .. lastTarget.index);
    end
  end

  if UnitChannelInfo("player") == "Tranquility" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if AoeHealingRequired() and IsCastable("Wild Growth", 5600) then
    WowCyborg_CURRENTATTACK = "Wild Growth";
    return SetSpellRequest(wildGrowth);
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

  local rejuvenationHot = FindBuff("target", "Rejuvenation");
  if hp <= 95 and rejuvenationHot == nil and IsCastableAtFriendlyTarget("Rejuvenation", 2100) then
    WowCyborg_CURRENTATTACK = "Rejuvenation";
    return SetSpellRequest(rejuvenation);
  end

  local swiftmendCharges = GetSpellCharges("Swiftmend");
  if hp <= 70 and lastTarget ~= nil and swiftmendCharges > 0 then
    if IsCastableAtFriendlyTarget("Swiftmend", 2800) then
      WowCyborg_CURRENTATTACK = "Swiftmend";
      return SetSpellRequest(swiftmend);
    end
  end

  if hp <= 80 and IsCastableAtFriendlyTarget("Regrowth", 2800) then
    WowCyborg_CURRENTATTACK = "Regrowth";
    return SetSpellRequest(regrowth);
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
print("Resto druid rotation loaded");
CreateDamageTakenFrame();