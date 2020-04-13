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
local sunfire = 7;
-- CAT form
local rake = 1;
local shred = 2;
local rip = 3;
local ferociousBite = 4;
local swipe = 5;

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
  
  return lowCount > 1;
end

function FindFriendlyHealingTarget()
  local highestDamageTaken = nil;
  for k,v in pairs(damageInLast5Seconds) do
    local hpp = GetHealthPercentage(k);
    if highestDamageTaken == nil or highestDamageTaken.amount > v then
      if IsSpellInRange("Lifebloom", k) then
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
    if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 100 then
      if lowestHealth == nil or hp <= lowestHealth.hp then
        if IsSpellInRange("Lifebloom", members[groupindex].name) then
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
  local cat = FindBuff("player", "Cat Form");
  if cat ~= nil then
    return RenderCatRotation(true);
  end

  return RenderSingleTargetRotation(true);
end

local lastTarget = {
  index = nil,
  name = nil,
  time = 0,
  damageAmount = 0
};

function HandleTankPreHots()
  local tankName, index = GetTankName();
  if tankName ~= nil and FindBuff(tankName, "Lifebloom") == nil then
    if IsCastableAtFriendlyUnit(tankName, "Lifebloom", 2061) and IsSpellInRange("Lifebloom", tankName) then
      local tankHp = GetHealthPercentage(tankName);
      if tankHp > 0 then
        local targetName = UnitName("target");
        if targetName == nil or string.match(tankName, targetName) == nil then
          WowCyborg_CURRENTATTACK = "Target tank: " .. tankName;
          SetSpellRequest("CTRL+" .. index);
          return true;
        else
          WowCyborg_CURRENTATTACK = "Lifebloom";
          SetSpellRequest(lifebloom);
          return true;
        end
      end
    end
  end

  if tankName ~= nil and FindBuff(tankName, "Cenarion Ward") == nil then
    if IsCastableAtFriendlyUnit(tankName, "Cenarion Ward", 1840) and IsSpellInRange("Cenarion Ward", tankName) then
      local tankHp = GetHealthPercentage(tankName);
      if tankHp > 0 then
        local targetName = UnitName("target");
        if targetName == nil or string.match(tankName, targetName) == nil then
          WowCyborg_CURRENTATTACK = "Target tank: " .. tankName;
          SetSpellRequest("CTRL+" .. index);
          return true;
        else
          WowCyborg_CURRENTATTACK = "Cenarion Ward";
          SetSpellRequest(cenarionWard);
          return true;
        end
      end
    end
  end
  
  return false;
end

function IsMelee()
  return IsSpellInRange("Shred") == 1;
end

function RenderCatRotation(aoe)
  if IsMelee() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local rakeDot = FindDebuff("target", "Rake");
  if rakeDot == nil then
    WowCyborg_CURRENTATTACK = "Rake";
    return SetSpellRequest(rake);
  end

  local points = GetComboPoints("player", "target");
  local ripDot, ripCd = FindDebuff("target", "Rip");
  if points == 5 then
    if ripDot == nil then
      WowCyborg_CURRENTATTACK = "Rip";
      return SetSpellRequest(rip);
    end
    
    WowCyborg_CURRENTATTACK = "Ferocious Bite";
    return SetSpellRequest(ferociousBite);
  end

  if aoe then
    if IsCastableAtEnemyTarget("Swipe", 0) then
      WowCyborg_CURRENTATTACK = "Swipe";
      return SetSpellRequest(swipe);
    end
  else
    if IsCastableAtEnemyTarget("Shred", 0) then
      WowCyborg_CURRENTATTACK = "Shred";
      return SetSpellRequest(shred);
    end
  end
end

function RenderSingleTargetRotation(disableAutoTarget)
  local cat = FindBuff("player", "Cat Form");
  if cat ~= nil then
    return RenderCatRotation(false);
  end

  local quaking = FindDebuff("player", "Quake");

  if disableAutoTarget == nil then
    local tankPreHot = HandleTankPreHots();
    if tankPreHot then
      return;
    end

    local tankName, index = GetTankName();
    if tankName ~= nil and FindBuff(tankName, "Lifebloom") == nil then
      if IsCastableAtFriendlyUnit(tankName, "Lifebloom", 2061) and IsSpellInRange("Lifebloom", tankName) then
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

    if lastTarget.time + 1.5 < GetTime() then
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
  
  local speed = GetUnitSpeed("player");
  if AoeHealingRequired() and IsCastable("Wild Growth", 5600) and quaking == nil and speed == 0 then
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
  if rejuvenationHot == nil and IsCastableAtFriendlyTarget("Rejuvenation", 2000) then
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

  if hp <= 80 and IsCastableAtFriendlyTarget("Regrowth", 2800) and quaking == nil and speed == 0 then
    WowCyborg_CURRENTATTACK = "Regrowth";
    return SetSpellRequest(regrowth);
  end
  
  if WowCyborg_INCOMBAT then
    local mana = (UnitPower("player") / UnitPowerMax("player")) * 100;
    if mana > 20 then
      local sunfireDebuff = FindDebuff("targettarget", "Sunfire");
      if sunfireDebuff == nil and UnitCanAttack("player", "targettarget") then
        WowCyborg_CURRENTATTACK = "Sunfire";
        return SetSpellRequest(sunfire);
      end
    end
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