--[[
  Button    Spell
  1-5       Riptide
  2         Lifebloom
  3         Rejuvenation
  4         Swiftmend
  5         Wild Growth
]]--

local incomingDamage = {};
local damageInLast5Seconds = {};
local riptide = {};
riptide[1] = 1;
riptide[2] = 2;
riptide[3] = 3;
riptide[4] = 4;
riptide[5] = 5;

local chainHeal = {};
chainHeal[1] = 6;
chainHeal[2] = 7;
chainHeal[3] = 8;
chainHeal[4] = 9;
chainHeal[5] = 0;

local healingSurge = {};
healingSurge[1] = "CTRL+1";
healingSurge[2] = "CTRL+2";
healingSurge[3] = "CTRL+3";
healingSurge[4] = "CTRL+4";
healingSurge[5] = "CTRL+5";

local healingWave = {};
healingWave[1] = "CTRL+6";
healingWave[2] = "CTRL+7";
healingWave[3] = "CTRL+8";
healingWave[4] = "CTRL+9";
healingWave[5] = "CTRL+0";

local flameShock = "SHIFT+1";
local healingStreamTotem = "SHIFT+2";
local lavaBurst = "SHIFT+3";
local cancelCast = "SHIFT+4";
local lightningBolt = "SHIFT+5";
local chainLightning = "SHIFT+6";
local earthShield = "SHIFT+7";

local healingTarget = {
  index = nil,
  name = nil,
  time = 0,
  damageAmount = 0
};

WowCyborg_PAUSE_KEYS = {
  "F",
  "F1",
  "F2",
  "F3",
  "F5",
  "F6",
  "F7",
  "F11",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD5",
}

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

function AoeHealingRequired(lowHp)
  local lowCount = 0;
  local hp = GetHealthPercentage("player");

  if hp < lowHp then
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
    local hpp = GetHealthPercentage(k);
    if highestDamageTaken == nil or highestDamageTaken.amount > v then
      if IsSpellInRange("Riptide", k) then
        if tostring(hpp) ~= "-nan(ind)" and hpp > 0 and hpp < 90 then
          if GetTargetFullName() ~= k then
            local speed = GetUnitSpeed("player");
            local spiritWalker = FindBuff("player", "Spiritwalker's Grace");
            if speed > 0 and spiritWalker == nil then
              local riptideBuff = FindBuff(k, "Riptide");
              if riptideBuff == nil then
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
        if IsSpellInRange("Riptide", members[groupindex].name) then
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

function CanCast()
  local quaking = FindDebuff("player", "Quake");
  local spiritWalker = FindBuff("player", "Spiritwalker's Grace");
  local speed = GetUnitSpeed("player");
  return quaking == nil and (speed == 0 or spiritWalker ~= nil);
end

function RenderSingleTargetRotation()
  local spell, _, _, _, endTime = UnitCastingInfo("player")
  if (spell == "Healing Wave" or spell == "Healing Surge") and healingTarget.name ~= nil then
    local hp = GetHealthPercentage(healingTarget.name)
    if hp > 90 then
      WowCyborg_CURRENTATTACK = "Cancel cast";
      return SetSpellRequest(cancelCast);
    end
  end

  if healingTarget.time + 0.2 < GetTime() then
    local friendlyTargetName, damageAmount = FindFriendlyHealingTarget();
    if friendlyTargetName ~= nil then
      local memberindex = GetMemberIndex(friendlyTargetName);
      if memberindex == nil then
        return HandleDps();
      end

      healingTarget = {
        name = friendlyTargetName,
        index = memberindex,
        damageAmount = damageAmount,
        time = GetTime()
      };
    end
  end

  local cb = FindBuff("player", "Cloudburst Totem");
  if AoeHealingRequired(95) and IsCastable("Healing Stream Totem", 0) and cb == nil then
    WowCyborg_CURRENTATTACK = "Healing Stream Totem";
    return SetSpellRequest(healingStreamTotem);
  end

  local focusHp = GetHealthPercentage("focus");
  if tostring(focusHp) ~= "-nan(ind)" and focusHp > 1 then
    if FindBuff("focus", "Earth Shield") == nil then
      WowCyborg_CURRENTATTACK = "Earthshield";
      return SetSpellRequest(earthShield);
    end
  end
  
  if healingTarget.name == nil then
    return HandleDps();
  end

  local hp = GetHealthPercentage(healingTarget.name);
  if hp == 100 then
    return HandleDps();
  end

  if hp > 60 and hp <= 95 and AoeHealingRequired(90) and IsCastableAtFriendlyUnit(healingTarget.name, "Chain Heal", 5000) and CanCast() then
    WowCyborg_CURRENTATTACK = "Chain Heal";
    return SetSpellRequest(chainHeal[healingTarget.index]);
  end
  
  local riptideHot = FindBuff(healingTarget.name, "Riptide");
  if riptideHot == nil and IsCastableAtFriendlyUnit(healingTarget.name, "Riptide", 0) then
    WowCyborg_CURRENTATTACK = "Riptide " .. healingTarget.index;
    return SetSpellRequest(riptide[healingTarget.index]);
  end
  
  if hp <= 70 then
    if IsCastableAtFriendlyUnit(healingTarget.name, "Healing Surge", 0) and CanCast() then
      WowCyborg_CURRENTATTACK = "Healing Surge";
      return SetSpellRequest(healingSurge[healingTarget.index]);
    end
  end

  if hp <= 90 then
    if IsCastableAtFriendlyUnit(healingTarget.name, "Healing Wave", 0) and CanCast() then
      WowCyborg_CURRENTATTACK = "Healing Wave";
      return SetSpellRequest(healingWave[healingTarget.index]);
    end
  end

  return HandleDps();
end

function HandleDps()
  local fsDebuff = FindDebuff("target", "Flame Shock");

  if IsCastableAtEnemyTarget("Flame Shock", 0) and fsDebuff == nil then
    WowCyborg_CURRENTATTACK = "Flame Shock";
    return SetSpellRequest(flameShock);
  end
  
  if IsCastableAtEnemyTarget("Lava Burst", 0) and fsDebuff ~= nil then
    WowCyborg_CURRENTATTACK = "Lava Burst";
    return SetSpellRequest(lavaBurst);
  end

  if WowCyborg_AOE_Rotation == false then
    if IsCastableAtEnemyTarget("Lightning Bolt", 0) then
      WowCyborg_CURRENTATTACK = "Lightning Bolt";
      return SetSpellRequest(lightningBolt);
    end
  end
  
  if WowCyborg_AOE_Rotation == true then
    if IsCastableAtEnemyTarget("Chain Lightning", 0) then
      WowCyborg_CURRENTATTACK = "Chain Lightning";
      return SetSpellRequest(chainLightning);
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

print("Resto druid rotation 2 loaded");
CreateDamageTakenFrame();