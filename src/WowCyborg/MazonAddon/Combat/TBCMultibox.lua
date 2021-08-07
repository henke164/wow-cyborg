--[[
  Button    Spell
]]--

local startedFollowingAt = 0;
local startedAssistAt = 0;
local startedBurstAt = 0;
local startedDrinkAt = 0;

local lastSwing = 0;
local serpentSting = "1";
local steadyShot = "2";
local raptorStrike = "3";
local arcaneShot = "4";
local multiShot = "5";
local mongoose = "6";
local wingClip = "7";
local mendPet = "8";
local killCommand = "9";
local explosiveTrap = "F+6";
local huntersMark = "F+7";
local feedPet = "SHIFT+5";

local follow = "F+8";
local assist = "F+9";
local drink = "SHIFT+9";
local holdFire = false;
local isConjuring = false;

local regrowthCost =  485;
local swiftmendCost =  195;
local rejuvenationCost =  335;
local isDrinking = false;

local startedFollowingAt = 0;
local startedAssistAt = 0;
local startedDrinkAt = 0;
local startedAspect = 0;
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
swiftmend[1] = "F+1";
swiftmend[2] = "F+2";
swiftmend[3] = "F+3";
swiftmend[4] = "F+4";
swiftmend[5] = "F+5";

local healingTouch = {};
healingTouch[1] = "SHIFT+1";
healingTouch[2] = "SHIFT+2";
healingTouch[3] = "SHIFT+3";
healingTouch[4] = "SHIFT+4";
healingTouch[5] = "SHIFT+5";

local lifebloom = "F+9";

local cancelCast = "F+6";
local thorns = "F+7";

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

function FindFriendlyHealingTarget()
  local highestDamageTaken = nil;
  for k,v in pairs(damageInLast5Seconds) do
    local hpp = GetHealthPercentage(k);
    if highestDamageTaken == nil or highestDamageTaken.amount > v then
      if IsSpellInRange("Rejuvenation", k) == 1 then
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
    if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 95 then
      if lowestHealth == nil or hp <= lowestHealth.hp then
        if IsSpellInRange("Rejuvenation", members[groupindex].name) == 1 then
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

function IsMelee()
  return IsSpellInRange("Wing Clip", "target") == 1;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(aoe)
  if WowCyborg_INCOMBAT == false then
    local happiness = GetPetHappiness();
    if happiness ~= nil and happiness < 3 then
      local feedbuff = FindBuff("pet", "Feed Pet Effect");
      if feedbuff == nil then
        WowCyborg_CURRENTATTACK = "Feed Pet";
        return SetSpellRequest(feedPet);
      end
    end

    if UnitName("player") == "Boucher" then
      if isConjuring == true then
        WowCyborg_CURRENTATTACK = "Conjuring";
        return SetSpellRequest("F+4");
      end
    end
  end

  if holdFire then
    if UnitName("player") == "Boucher" then
      WowCyborg_CURRENTATTACK = "Hold fire!";
      return SetSpellRequest(cancelCast);
    end

    if UnitName("player") == "Shibbah" or UnitName("player") == "Smattrarn" then
      WowCyborg_CURRENTATTACK = "Hold fire!";
      return SetSpellRequest("CTRL+2");
    end
  end

  if UnitName("player") == "Shibbah" and startedAspect > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Toggle aspect...";
    return SetSpellRequest("F+5");
  end
  
  if startedDrinkAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Drinking...";
    return SetSpellRequest(drink);
  end

  if UnitChannelInfo("player") == "Tranquility" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if startedFollowingAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Following...";
    return SetSpellRequest(follow);
  end

  if startedAssistAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Assisting...";
    return SetSpellRequest(assist);
  end
  
  if startedBurstAt > GetTime() - 2 then
    WowCyborg_CURRENTATTACK = "Bursting...";
    return SetSpellRequest("F+1");
  end
  
  if UnitName("player") == "Docka" then
    return RenderRestoRotation();
  end
  
  local hp = GetHealthPercentage("player");
  local targetHp = GetHealthPercentage("target");
  local petHp = GetHealthPercentage("pet");

  if UnitChannelInfo("player") == "Volley" then
    WowCyborg_CURRENTATTACK = "Volley";
    return SetSpellRequest(nil);
  end
  
  if CheckInteractDistance("target", 5) and IsCastableAtEnemyTarget("Scorch", 0) then
    if IsCastable("Blast Wave", 500) then
      WowCyborg_CURRENTATTACK = "Blast Wave";
      return SetSpellRequest("3");
    end

    if IsCastable("Dragon's Breath", 600) then
      WowCyborg_CURRENTATTACK = "Dragon's Breath";
      return SetSpellRequest("4");
    end
    
    if IsCastable("Cone of Cold", 600) then
      WowCyborg_CURRENTATTACK = "Cone of Cold";
      return SetSpellRequest("6");
    end
  end

  local scorch, scorchTl, scorchStacks = FindDebuff("target", "Fire Vulnerability");
  if (scorch == nil or scorchStacks < 5) and IsCastableAtEnemyTarget("Scorch", 141) then
    WowCyborg_CURRENTATTACK = "Scorch";
    return SetSpellRequest("1");
  end

  if IsCastable("Molten Armor", 593) then
    local maBuff = FindBuff("player", "Molten Armor");
    if maBuff == nil then
      WowCyborg_CURRENTATTACK = "Molten Armor";
      return SetSpellRequest("5");
    end
  end

  if IsCastableAtEnemyTarget("Fireball", 386) then
    WowCyborg_CURRENTATTACK = "Fireball";
    return SetSpellRequest("2");
  end

  if aoe == true then
    if IsCastableAtEnemyTarget("Multi-Shot", 200) then
        
      if IsCastable("Misdirection", 0) then
        WowCyborg_CURRENTATTACK = "Misdirection";
        return SetSpellRequest("0");
      end

      WowCyborg_CURRENTATTACK = "Multi-Shot";
      return SetSpellRequest(multiShot);
    end
    
    if IsMelee() == true then
      if IsCastable("Explosive Trap", 650) then
        WowCyborg_CURRENTATTACK = "Explosive Trap";
        return SetSpellRequest(explosiveTrap);
      end
    end
  end

  if petHp > 1 and petHp < 70 then
    local mendBuff = FindBuff("Pet", "Mend Pet");
    if mendBuff == nil then
      if IsCastable("Mend Pet", 200) then
        WowCyborg_CURRENTATTACK = "Mend Pet";
        return SetSpellRequest(mendPet);
      end
    end
  end

  if IsCastableAtEnemyTarget("Kill Command", 75) then
    WowCyborg_CURRENTATTACK = "Kill Command";
    return SetSpellRequest(killCommand);
  end

  if IsMelee() ~= true then
    if UnitName("player") == "Shibbah" then
      local hmDebuff = FindDebuff("target", "Hunter's Mark");
      if hmDebuff == nil and aoe ~= true then
        if IsCastableAtEnemyTarget("Hunter's Mark", 15) then
          WowCyborg_CURRENTATTACK = "Hunter's Mark";
          return SetSpellRequest(huntersMark);
        end
      end
    end

    local speed = GetUnitSpeed("player");
    if speed == 0 then
      local lastSwingAgo = GetTime() - lastSwing;
      if lastSwingAgo < 0.3 or lastSwingAgo > 3 then
        if IsCastableAtEnemyTarget("Steady Shot", 15) then
          WowCyborg_CURRENTATTACK = "Steady Shot";
          return SetSpellRequest(steadyShot);
        elseif IsCastableAtEnemyTarget("Arcane Shot", 15) then
          WowCyborg_CURRENTATTACK = "Arcane Shot";
          return SetSpellRequest(arcaneShot);
        end
      end
    elseif targetHp < 80 then
      if IsCastableAtEnemyTarget("Arcane Shot", 15) then
        WowCyborg_CURRENTATTACK = "Arcane Shot";
        return SetSpellRequest(arcaneShot);
      end      
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  else
    local wcDebuff = FindDebuff("Target", "Wing Clip");
    if (wcDebuff == nil) then
      if IsCastableAtEnemyTarget("Wing Clip", 40) then
        WowCyborg_CURRENTATTACK = "Wing Clip";
        return SetSpellRequest(wingClip);
      end
    end
    
    if IsCastableAtEnemyTarget("Mongoose Bite", 65) then
      WowCyborg_CURRENTATTACK = "Mongoose Bite";
      return SetSpellRequest(mongoose);
    end

    if IsCastableAtEnemyTarget("Raptor Strike", 100) then
      WowCyborg_CURRENTATTACK = "Raptor Strike";
      return SetSpellRequest(raptorStrike);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderRestoRotation()
  if isDrinking == true then
    WowCyborg_CURRENTATTACK = "Drinking...";
    return SetSpellRequest(nil);
  end
  
  if WowCyborg_INCOMBAT == false then
    local focusName = UnitName("focus");
    if focusName ~= nil then
      local thornsBuff = FindBuff("focus", "Thorns");
      if thornsBuff == nil then
        if IsCastable("Thorns", 320) then
          WowCyborg_CURRENTATTACK = "Thorns";
          return SetSpellRequest(thorns);
        end
      end
    end
  end

  local spell, _, _, _, endTime = UnitCastingInfo("player")
  if spell == "Regrowth" and healingTarget.name ~= nil then
    local hp = GetHealthPercentage(healingTarget.name)
    if hp > 80 then
      WowCyborg_CURRENTATTACK = "Cancel cast";
      return SetSpellRequest(cancelCast);
    end
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

  if healingTarget.name == nil then
    WowCyborg_CURRENTATTACK = "no ht";
    return SetSpellRequest(nil);
  end

  local hp = GetHealthPercentage(healingTarget.name);
  if hp > 95 then
    WowCyborg_CURRENTATTACK = "Full hp: " .. healingTarget.name;
    return SetSpellRequest(nil);
  end
  
  local mana = (UnitPower("player") / UnitPowerMax("player")) * 100;

  if mana < 60 then
    if IsCastable("Innervate", 0) then
      WowCyborg_CURRENTATTACK = "Innervate";
      return SetSpellRequest("SHIFT+8");
    end
  end

  local rejuvenationHot = FindBuff(healingTarget.name, "Rejuvenation");
  if rejuvenationHot == nil and IsCastableAtFriendlyUnit(healingTarget.name, "Rejuvenation", rejuvenationCost) then
    WowCyborg_CURRENTATTACK = "Rejuvenation " .. healingTarget.index;
    return SetSpellRequest(rejuvenation[healingTarget.index]);
  end

  local focusHealth = GetHealthPercentage("focus");

  if WowCyborg_INCOMBAT and focusHealth > 1 and focusHealth <= 90 and UnitGUID("focus") == UnitGUID(healingTarget.name) then
    local lifebloomHot, lifebloomX, lifebloomStacks = FindBuff("focus", "Lifebloom");
    if (lifebloomHot == nil or lifebloomStacks < 3) and IsCastableAtFriendlyUnit("focus", "Lifebloom", 220) then
      WowCyborg_CURRENTATTACK = "Lifebloom";
      return SetSpellRequest(lifebloom);
    end
  end

  if hp <= 40 and healingTarget ~= nil then
    if IsCastableAtFriendlyUnit(healingTarget.name, "Swiftmend", swiftmendCost) then
      WowCyborg_CURRENTATTACK = "Swiftmend";
      return SetSpellRequest(swiftmend[healingTarget.index]);
    end
  end

  local regrowthHot = FindBuff(healingTarget.name, "Regrowth");
  if regrowthHot == nil and hp <= 80 and IsCastableAtFriendlyUnit(healingTarget.name, "Regrowth", regrowthCost) and speed == 0 then
    WowCyborg_CURRENTATTACK = "Regrowth";
    return SetSpellRequest(regrowth[healingTarget.index]);
  end
  
  if hp <= 60 and IsCastableAtFriendlyUnit(healingTarget.name, "Healing Touch", 100) and speed == 0 then
    WowCyborg_CURRENTATTACK = "Healing Touch";
    return SetSpellRequest(healingTouch[healingTarget.index]);
  end

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

function CreateSwingTimer()
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

  frame:SetScript("OnEvent", function()
    local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, amountDetails = CombatLogGetCurrentEventInfo()

    if sourceGUID ~= UnitGUID("player") then
      return;
    end
    
    if type == "RANGE_DAMAGE" then
      lastSwing = GetTime();
    end
  end)
end

CreateSwingTimer();
print("Classic hunter runner rotation loaded");

function CreateEmoteListenerFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("CHAT_MSG_CHANNEL");
  frame:RegisterEvent("CHAT_MSG_PARTY_LEADER");
  frame:RegisterEvent("PLAYER_REGEN_ENABLED");

  frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
      local mana = (UnitPower("player") / UnitPowerMax("player")) * 100;
      if mana < 80 then
        print("drinking");
        startedDrinkAt = GetTime();
        isDrinking = true;
      end
    end

    if event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_PARTY_LEADER" then
      command = ...;

      if string.find(command, "maz-1", 1, true) then
        print("Following");
        startedFollowingAt = GetTime();
        isDrinking = false;
        holdFire = false;
        isConjuring = false;
      end
      if string.find(command, "maz-2", 1, true) then
        print("Waiting");
        startedAssistAt = GetTime();
        isDrinking = false;
        holdFire = false;
        isConjuring = false;
      end
      if string.find(command, "maz-3", 1, true) then
        print("Burst");
        startedBurstAt = GetTime();
        isDrinking = false;
        holdFire = false;
        isConjuring = false;
      end
      if string.find(command, "maz-4", 1, true) then
        print("drinking");
        startedDrinkAt = GetTime();
        isDrinking = true;
        isConjuring = false;
      end
      if string.find(command, "maz-5", 1, true) then
        holdFire = true;
        isConjuring = false;
      end
      if string.find(command, "maz-6", 1, true) then
        print("aspect");
        startedAspect = GetTime();
        isDrinking = false;
        isConjuring = false;
      end
      if string.find(command, "maz-7", 1, true) then
        print("conjuring");
        isConjuring = true;
      end
    end
  end)
end

print("TBC Hunter follower rotation loaded");
CreateEmoteListenerFrame();
CreateDamageTakenFrame();