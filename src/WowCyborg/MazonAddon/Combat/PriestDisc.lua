--[[
  Button    Spell
]]--

local incomingDamage = {};
local damageInLast5Seconds = {};
local pwShield = {};
pwShield[1] = 1;
pwShield[2] = 2;
pwShield[3] = 3;
pwShield[4] = 4;
pwShield[5] = 5;

local schism = 6;
local penanceTarget = 6;
local purgeWicked = 7;
local pwSolace = 8;
local smite = 9;
local holyNova = "F+5";
local pwRadiance = "F+6";
local penance = {};
penance[1] = "CTRL+1";
penance[2] = "CTRL+2";
penance[3] = "CTRL+3";
penance[4] = "CTRL+4";
penance[5] = "CTRL+5";

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

function AoeHealingRequired()
  local lowCount = 0;
  local hp = GetHealthPercentage("player");

  if hp < 95 then
    lowCount = lowCount + 1;
  end

  for groupindex = 1,5 do
    local php = GetHealthPercentage("party" .. groupindex);
    local hasAtonement = FindBuff("party" .. groupindex, "Atonement");
    if hasAtonement == nil and tostring(php) ~= "-nan(ind)" and php > 1 and php < 90 then
      lowCount = lowCount + 1;
    end
  end
  
  return lowCount > 1;
end

function FindFriendlyHealingTarget()
  local highestDamageTaken = nil;
  for k,v in pairs(damageInLast5Seconds) do
    local hpp = GetHealthPercentage(k);
    if highestDamageTaken == nil or highestDamageTaken.amount > v then
      if tostring(hpp) ~= "-nan(ind)" and hpp > 0 and hpp < 100 then
        if IsSpellInRange("Penance", k) then
          if GetTargetFullName() ~= k then
            highestDamageTaken = { name = k, amount = v };
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
    if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 100 then
      if IsSpellInRange("Penance", members[groupindex].name) then
        if lowestHealth == nil or hp <= lowestHealth.hp then
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

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  if UnitChannelInfo("player") ~= nil then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local quaking = FindDebuff("player", "Quake");

  if healingTarget.time + 0.2 < GetTime() then
    local friendlyTargetName, damageAmount = FindFriendlyHealingTarget();
    if friendlyTargetName ~= nil then
      local memberindex = GetMemberIndex(friendlyTargetName);
      if memberindex ~= nil then
        healingTarget = {
          name = friendlyTargetName,
          index = memberindex,
          damageAmount = damageAmount,
          time = GetTime()
        };
      end
    end
  end

  local speed = GetUnitSpeed("player");
  if AoeHealingRequired() then

    local revelationBuff = FindBuff("player", "Sudden Revelation");
    local charges = GetSpellCharges("Power Word: Radiance");

    if revelationBuff ~= nil then
      WowCyborg_CURRENTATTACK = "Holy Nova";
      return SetSpellRequest(holyNova);
    end

    if charges > 0 and IsCastable("Power Word: Radiance", 0) and quaking == nil and speed == 0 then
      WowCyborg_CURRENTATTACK = "Power Word: Radiance";
      return SetSpellRequest(pwRadiance);
    end
  end

  if healingTarget.name ~= nil then
    local hp = GetHealthPercentage(healingTarget.name);
    if hp <= 90 and IsCastableAtFriendlyUnit(healingTarget.name, "Power Word: Shield", 0) then
      local weak = FindDebuff(healingTarget.name, "Weakened Soul");
      if weak == nil then
        WowCyborg_CURRENTATTACK = "Power Word: Shield";
        return SetSpellRequest(pwShield[healingTarget.index]);
      end
    end  
    if hp <= 80 and healingTarget ~= nil then
      if IsCastableAtFriendlyUnit(healingTarget.name, "Penance", 0) then
        WowCyborg_CURRENTATTACK = "Penance";
        return SetSpellRequest(penance[healingTarget.index]);
      end
    end
  end

  if IsCastableAtEnemyTarget("Schism", 500) and speed == 0 then
    WowCyborg_CURRENTATTACK = "Schism";
    return SetSpellRequest(schism);
  end
  
  local ptwDebuff = FindDebuff("target", "Purge the Wicked");
  if ptwDebuff == nil and IsCastableAtEnemyTarget("Purge the Wicked", 0) then
    WowCyborg_CURRENTATTACK = "Purge the Wicked";
    return SetSpellRequest(purgeWicked);
  end

  if IsCastableAtEnemyTarget("Power Word: Solace", 0) then
    WowCyborg_CURRENTATTACK = "Power Word: Solace";
    return SetSpellRequest(pwSolace);
  end
  
  if IsCastableAtEnemyTarget("Penance", 0) then
    WowCyborg_CURRENTATTACK = "Penance";
    return SetSpellRequest(penanceTarget);
  end

  if (IsCastableAtEnemyTarget("Smite", 0) or IsCastableAtEnemyTarget("Ascended Blast", 0)) and speed == 0 then
    WowCyborg_CURRENTATTACK = "Smite";
    return SetSpellRequest(smite);
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

print("Disc priest loaded");
CreateDamageTakenFrame();