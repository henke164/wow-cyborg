--[[
  Button    Spell
  1         Regrowth
  2         Lifebloom
  3         Rejuvenation
  4         Swiftmend
  5         Wild Growth
]]--

local startedFollowingAt = 0;
local startedAssistAt = 0;
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
swiftmend[1] = "CTRL+1";
swiftmend[2] = "CTRL+2";
swiftmend[3] = "CTRL+3";
swiftmend[4] = "CTRL+4";
swiftmend[5] = "CTRL+5";

local lifebloom = "SHIFT+1";
local wildGrowth = "SHIFT+2";
local cenarionWard = "SHIFT+3";
local cancelCast = "SHIFT+4";

local follow = "SHIFT+8";
local assist = "SHIFT+9";

local sunfire = 7;
-- CAT form
local rake = 1;
local shred = 2;
local rip = 3;
local ferociousBite = 4;
local swipe = 5;

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

  return RenderSingleTargetRotation();
end

function HandleTankPreHots()
  local tankName, index = GetTankName();
  if tankName ~= nil and FindBuff(tankName, "Lifebloom") == nil then
    if IsCastableAtFriendlyUnit(tankName, "Lifebloom", 2061) and IsSpellInRange("Lifebloom", tankName) then
      local tankHp = GetHealthPercentage(tankName);
      if tankHp > 0 then
        WowCyborg_CURRENTATTACK = "Lifebloom";
        SetSpellRequest(lifebloom);
        return true;
      end
    end
  end

  if tankName ~= nil and FindBuff(tankName, "Cenarion Ward") == nil then
    if IsCastableAtFriendlyUnit(tankName, "Cenarion Ward", 1840) and IsSpellInRange("Cenarion Ward", tankName) then
      local tankHp = GetHealthPercentage(tankName);
      if tankHp > 0 then
        WowCyborg_CURRENTATTACK = "Cenarion Ward";
        SetSpellRequest(cenarionWard);
        return true;
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

function RenderSingleTargetRotation()
  if startedFollowingAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Following...";
    return SetSpellRequest(follow);
  end

  if startedAssistAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Assisting...";
    return SetSpellRequest(assist);
  end

  if UnitChannelInfo("player") == "Tranquility" then
    WowCyborg_CURRENTATTACK = "-";
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

  local cat = FindBuff("player", "Cat Form");
  if cat ~= nil then
    return RenderCatRotation(false);
  end

  local quaking = FindDebuff("player", "Quake");

  local tankPreHot = HandleTankPreHots();
  if tankPreHot then
    WowCyborg_CURRENTATTACK = "Tank Prehot";
    return;
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
  if AoeHealingRequired() and IsCastable("Wild Growth", 5600) and quaking == nil and speed == 0 then
    WowCyborg_CURRENTATTACK = "Wild Growth";
    return SetSpellRequest(wildGrowth);
  end

  if healingTarget.name == nil then
    WowCyborg_CURRENTATTACK = "no ht";
    return SetSpellRequest(nil);
  end

  local hp = GetHealthPercentage(healingTarget.name);
  if hp == 100 then
    WowCyborg_CURRENTATTACK = "Full hp: " .. healingTarget.name;
    return SetSpellRequest(nil);
  end

  local rejuvenationHot = FindBuff(healingTarget.name, "Rejuvenation");
  if rejuvenationHot == nil and IsCastableAtFriendlyUnit(healingTarget.name, "Rejuvenation", 2000) then
    WowCyborg_CURRENTATTACK = "Rejuvenation " .. healingTarget.index;
    return SetSpellRequest(rejuvenation[healingTarget.index]);
  end

  local swiftmendCharges = GetSpellCharges("Swiftmend");
  if hp <= 70 and healingTarget ~= nil and swiftmendCharges > 0 then
    if IsCastableAtFriendlyUnit(healingTarget.name, "Swiftmend", 2800) then
      WowCyborg_CURRENTATTACK = "Swiftmend";
      return SetSpellRequest(swiftmend[healingTarget.index]);
    end
  end

  if hp <= 80 and IsCastableAtFriendlyUnit(healingTarget.name, "Regrowth", 2800) and quaking == nil and speed == 0 then
    WowCyborg_CURRENTATTACK = "Regrowth";
    return SetSpellRequest(regrowth[healingTarget.index]);
  end
  
  --if WowCyborg_INCOMBAT then
  --  local mana = (UnitPower("player") / UnitPowerMax("player")) * 100;
  --  if mana > 20 then
  --    local sunfireDebuff = FindDebuff("targettarget", "Sunfire");
  --    if sunfireDebuff == nil and UnitCanAttack("player", "targettarget") then
  --      WowCyborg_CURRENTATTACK = "Sunfire";
  --      return SetSpellRequest(sunfire);
  --    end
  --  end
  --end

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
  end)
end

print("Resto druid follower rotation 2 loaded");
CreateEmoteListenerFrame();
CreateDamageTakenFrame();