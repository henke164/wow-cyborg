--[[
  Button    Spell
  1         Regrowth
  2         Lifebloom
  3         Rejuvenation
  4         Swiftmend
  5         Wild Growth
]]--

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

WowCyborg_PAUSE_KEYS = {
  "F",
  "F5",
  "F10",
  "F2",
  "R"
}

-- Boomer form
local moonfire = "SHIFT+5";
local sunfire = "SHIFT+6";
local wrath = "SHIFT+7";
local starfire = "SHIFT+8";
local starsurge = "SHIFT+9";

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
  return RenderSingleTargetRotation(true);
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

function RenderMoonkinRotation(wrathRot)
  local dot = FindDebuff("target", "Moonfire");
  if dot == nil and IsCastableAtEnemyTarget("Moonfire", 0) then
    WowCyborg_CURRENTATTACK = "Moonfire";
    return SetSpellRequest(moonfire);
  end
  
  local dot2 = FindDebuff("target", "Sunfire");
  if dot2 == nil and IsCastableAtEnemyTarget("Sunfire", 0) then
    WowCyborg_CURRENTATTACK = "Sunfire";
    return SetSpellRequest(sunfire);
  end

  if IsCastableAtEnemyTarget("Starsurge", 0) then
    WowCyborg_CURRENTATTACK = "Starsurge";
    return SetSpellRequest(starsurge);
  end

  local solar = FindBuff("player", "Eclipse (Solar)");
  if solar ~= nil then
    if IsCastableAtEnemyTarget("Wrath", 0) then
      WowCyborg_CURRENTATTACK = "Wrath";
      return SetSpellRequest(wrath);
    end
  end
  
  local lunar = FindBuff("player", "Eclipse (Lunar)");
  if lunar ~= nil then
    if IsCastableAtEnemyTarget("Starfire", 0) then
      WowCyborg_CURRENTATTACK = "Starfire";
      return SetSpellRequest(starfire);
    end
  end

  if wrathRot then
    if IsCastableAtEnemyTarget("Wrath", 0) then
      WowCyborg_CURRENTATTACK = "Wrath";
      return SetSpellRequest(wrath);
    end
  else
    if IsCastableAtEnemyTarget("Starfire", 0) then
      WowCyborg_CURRENTATTACK = "Starfire";
      return SetSpellRequest(starfire);
    end
  end
  
  if IsCastableAtEnemyTarget("Wrath", 0) then
    WowCyborg_CURRENTATTACK = "Wrath";
    return SetSpellRequest(wrath);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation(wrathRot)
  if UnitChannelInfo("player") == "Tranquility" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
    
  if UnitChannelInfo("player") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "BURSTING";
    return SetSpellRequest(nil);
  end

  local spell, _, _, _, endTime = UnitCastingInfo("player")
  if spell == "Regrowth" and healingTarget.name ~= nil then
    local hp = GetHealthPercentage(healingTarget.name)
    if hp > 90 then
      WowCyborg_CURRENTATTACK = "Cancel cast";
      return SetSpellRequest(cancelCast);
    end
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
    return RenderMoonkinRotation();
  end

  local hp = GetHealthPercentage(healingTarget.name);
  if hp == 100 then
    return RenderMoonkinRotation();
  end

  if hp <= 60 and IsCastableAtFriendlyUnit(healingTarget.name, "Regrowth", 2800) and quaking == nil and speed == 0 then
    WowCyborg_CURRENTATTACK = "Regrowth";
    return SetSpellRequest(regrowth[healingTarget.index]);
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

  return RenderMoonkinRotation();
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

print("Resto druid rotation 2 loaded");
CreateDamageTakenFrame();