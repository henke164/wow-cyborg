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
local follow = "SHIFT+8";
local assist = "SHIFT+9";

local barbed_shot = "1"
local kill_command = "2"
local bestial_wrath = "3"
local cobra_shot = "4"
local aspect_of_the_wild = "5"
local multishot = "6"
local blood_fury = "8"

local immolate = "1";
local chaosBolt = "2";
local cataclysm = "3";
local conflagrate = "4";
local incinerate = "5";


local deathsCaress = "1";
local marrowrend = "2";
local bloodboil = "3";
local deathstrike = "4";
local heartstrike = "5";
local bonestorm = "6";

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

local sunfire = 7;

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

function GetRuneCount()
  local runeAmount = 0
  for i=1,6 do
    local start, duration, runeReady = GetRuneCooldown(i)
    if runeReady == true then
      runeAmount = runeAmount+1
    end
  end
  return runeAmount;
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
  local name = GetUnitName("player")

  if name ~= "Thering" then
    if startedFollowingAt > GetTime() - 0.5 then
      WowCyborg_CURRENTATTACK = "Following...";
      return SetSpellRequest(follow);
    end

    if startedAssistAt > GetTime() - 0.5 then
      WowCyborg_CURRENTATTACK = "Assisting...";
      return SetSpellRequest(assist);
    end
  end

  if name == "Klong" then
    return RenderKlongRotation()
  end

  if name == "Kattigast" then
    return RenderKattigastRotation()
  end

  if name == "Thering" then
    return RenderTheRingRotation()
  end

  if name == "Mazoon" then
    return RenderMazoonMultiRotation()
  end
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

function RenderKlongRotation()
  
  local immolateDebuff = FindDebuff("target", "Immolate"); 
  if immolateDebuff == nil then
    if IsCastableAtEnemyTarget("Immolate", 0) then
      WowCyborg_CURRENTATTACK = "Immolate";
      return SetSpellRequest(immolate);
    end
  end

  local shards = UnitPower("player", 7)
  if shards >= 4 then
    if IsCastableAtEnemyTarget("Chaos Bolt", 0) then
      WowCyborg_CURRENTATTACK = "Chaos Bolt";
      return SetSpellRequest(chaosBolt);
    end
  end

  if IsCastableAtEnemyTarget("Immolate", 0) and IsCastableAtEnemyTarget("Cataclysm", 0) then
    WowCyborg_CURRENTATTACK = "Cataclysm";
    return SetSpellRequest(cataclysm);
  end

  if IsCastableAtEnemyTarget("Conflagrate", 0) then
    WowCyborg_CURRENTATTACK = "Conflagrate";
    return SetSpellRequest(conflagrate);
  end

  if IsCastableAtEnemyTarget("Incinerate", 0) then
    WowCyborg_CURRENTATTACK = "Incinerate";
    return SetSpellRequest(incinerate);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderKattigastRotation()
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
  
  WowCyborg_CURRENTATTACK = "Nothing: " .. healingTarget.name;
  return SetSpellRequest(nil);
end

function RenderTheRingRotation()
  local bsBuff, bsTs, bsStacks = FindBuff("player", "Bone Shield");

  if bsBuff == nil or bsStacks == nil or bsStacks < 6 or bsTs < 4 then
    if IsCastableAtEnemyTarget("Marrowrend", 0) then
      WowCyborg_CURRENTATTACK = "Marrowrend";
      return SetSpellRequest(marrowrend);
    else
      return SetSpellRequest(nil);
    end
  end

  local bbCharges = GetSpellCharges("Blood Boil");

  if bbCharges ~= nil and bbCharges > 0 then
    if IsCastableAtEnemyTarget("Death Strike", 0) then
      WowCyborg_CURRENTATTACK = "Blood Boil";
      return SetSpellRequest(bloodboil);
    end
  end

  if IsCastableAtEnemyTarget("Death Strike", 45) then
    WowCyborg_CURRENTATTACK = "Death Strike";
    return SetSpellRequest(deathstrike);
  end

  local runeCount = GetRuneCount();
  local runeLimit = 3;
  if bsBuff == nil or bsTs > 10 then
    runeLimit = 0;
  end

  if runeCount >= runeLimit then
    if IsCastableAtEnemyTarget("Heart Strike", 0) then
      WowCyborg_CURRENTATTACK = "Heart Strike";
      return SetSpellRequest(heartstrike);
    end
  end

  if bsBuff == nil or bsStacks == nil or bsStacks < 10 or bsTs < 4 then
    if IsCastableAtEnemyTarget("Marrowrend", 0) then
      WowCyborg_CURRENTATTACK = "Marrowrend";
      return SetSpellRequest(marrowrend);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderMazoonSingleRotation()
 -- barbed shot
 if (FindBuff("pet", "frenzy") ~= nil and GetBuffTimeLeft("pet", "frenzy")<GetCurrentSpellGCD("barbed shot") or GetCooldown("bestial wrath") and (GetFullRechargeTime("barbed shot")<GetCurrentSpellGCD("barbed shot") or true and GetCooldown("aspect of the wild")<GetCurrentSpellGCD("barbed shot"))) then
  if IsCastableAtEnemyTarget("barbed shot", 0) then
    WowCyborg_CURRENTATTACK = "barbed shot";
    return SetSpellRequest(barbed_shot);
  end
end

-- concentrated flame
if (UnitPower("player")+GetPowerRegen()*GetCurrentSpellGCD("concentrated flame")<UnitPowerMax("player") and FindBuff("player", "bestial wrath") == nil and ( not GetDebuffTimeLeft("target", "concentrated flame burn") and  not false) or GetFullRechargeTime("concentrated flame")<GetCurrentSpellGCD("concentrated flame") or 30<5) then
  if IsCastableAtEnemyTarget("concentrated flame", 0) then
    WowCyborg_CURRENTATTACK = "concentrated flame";
    return SetSpellRequest(concentrated_flame);
  end
end

-- aspect of the wild
if (FindBuff("player", "aspect of the wild") == nil and (GetSpellCharges("barbed shot")<1 or  not true)) then
  if IsCastableAtEnemyTarget("aspect of the wild", 0) then
    WowCyborg_CURRENTATTACK = "aspect of the wild";
    return SetSpellRequest(aspect_of_the_wild);
  end
end

-- stampede
if (FindBuff("player", "aspect of the wild") ~= nil and FindBuff("player", "bestial wrath") ~= nil or 30<15) then
  if IsCastableAtEnemyTarget("stampede", 0) then
    WowCyborg_CURRENTATTACK = "stampede";
    return SetSpellRequest(stampede);
  end
end

-- a murder of crows
if (true) then
  if IsCastableAtEnemyTarget("a murder of crows", 0) then
    WowCyborg_CURRENTATTACK = "a murder of crows";
    return SetSpellRequest(a_murder_of_crows);
  end
end

-- focused azerite beam
if (FindBuff("player", "bestial wrath") == nil or 30<5) then
  if IsCastableAtEnemyTarget("focused azerite beam", 0) then
    WowCyborg_CURRENTATTACK = "focused azerite beam";
    return SetSpellRequest(focused_azerite_beam);
  end
end

-- the unbound force
if (FindBuff("player", "reckless force") ~= nil or GetBuffStacks("reckless force counter")<10 or 30<5) then
  if IsCastableAtEnemyTarget("the unbound force", 0) then
    WowCyborg_CURRENTATTACK = "the unbound force";
    return SetSpellRequest(the_unbound_force);
  end
end

-- bestial wrath
if (TalentEnabled("one with the pack") and GetBuffTimeLeft("player", "bestial wrath")<GetCurrentSpellGCD("bestial wrath") or FindBuff("player", "bestial wrath") == nil and GetCooldown("aspect of the wild")>15 or 30<15+GetCurrentSpellGCD("bestial wrath")) then
  if IsCastableAtEnemyTarget("bestial wrath", 0) then
    WowCyborg_CURRENTATTACK = "bestial wrath";
    return SetSpellRequest(bestial_wrath);
  end
end

-- barbed shot
if (1>1 and GetBuffTimeLeft("player", "dance of death")<GetCurrentSpellGCD("barbed shot")) then
  if IsCastableAtEnemyTarget("barbed shot", 0) then
    WowCyborg_CURRENTATTACK = "barbed shot";
    return SetSpellRequest(barbed_shot);
  end
end

-- blood of the enemy
if (GetBuffTimeLeft("player", "aspect of the wild")>10+GetCurrentSpellGCD("blood of the enemy") or 30<10+GetCurrentSpellGCD("blood of the enemy")) then
  if IsCastableAtEnemyTarget("blood of the enemy", 0) then
    WowCyborg_CURRENTATTACK = "blood of the enemy";
    return SetSpellRequest(blood_of_the_enemy);
  end
end

-- kill command
if (true) then
  if IsCastableAtEnemyTarget("kill command", 0) then
    WowCyborg_CURRENTATTACK = "kill command";
    return SetSpellRequest(kill_command);
  end
end

-- bag of tricks
if (FindBuff("player", "bestial wrath") == nil or 30<5) then
  if IsCastableAtEnemyTarget("bag of tricks", 0) then
    WowCyborg_CURRENTATTACK = "bag of tricks";
    return SetSpellRequest(bag_of_tricks);
  end
end

-- chimaera shot
if (true) then
  if IsCastableAtEnemyTarget("chimaera shot", 0) then
    WowCyborg_CURRENTATTACK = "chimaera shot";
    return SetSpellRequest(chimaera_shot);
  end
end

-- dire beast
if (true) then
  if IsCastableAtEnemyTarget("dire beast", 0) then
    WowCyborg_CURRENTATTACK = "dire beast";
    return SetSpellRequest(dire_beast);
  end
end

-- barbed shot
if (TalentEnabled("one with the pack") and GetSpellCharges("barbed shot")>1.5 or GetSpellCharges("barbed shot")>1.8 or GetCooldown("aspect of the wild")<GetBuffTimeLeft("player", "frenzy")-GetCurrentSpellGCD("barbed shot") and true or 30<9) then
  if IsCastableAtEnemyTarget("barbed shot", 0) then
    WowCyborg_CURRENTATTACK = "barbed shot";
    return SetSpellRequest(barbed_shot);
  end
end

-- purifying blast
if (FindBuff("player", "bestial wrath") == nil or 30<8) then
  if IsCastableAtEnemyTarget("purifying blast", 0) then
    WowCyborg_CURRENTATTACK = "purifying blast";
    return SetSpellRequest(purifying_blast);
  end
end

-- barrage
if (true) then
  if IsCastableAtEnemyTarget("barrage", 0) then
    WowCyborg_CURRENTATTACK = "barrage";
    return SetSpellRequest(barrage);
  end
end

-- cobra shot
if ((UnitPower("player")-GetCurrentCost("cobra shot")+GetPowerRegen()*(GetCooldown("kill command")-1)>GetCurrentCost("kill command") or GetCooldown("kill command")>1+GetCurrentSpellGCD("cobra shot") and GetCooldown("bestial wrath")>GetTimeToMax() or FindBuff("player", "memory of lucid dreams") ~= nil) and GetCooldown("kill command")>1 or 30<3) then
  if IsCastableAtEnemyTarget("cobra shot", 0) then
    WowCyborg_CURRENTATTACK = "cobra shot";
    return SetSpellRequest(cobra_shot);
  end
end

-- spitting cobra
if (true) then
  if IsCastableAtEnemyTarget("spitting cobra", 0) then
    WowCyborg_CURRENTATTACK = "spitting cobra";
    return SetSpellRequest(spitting_cobra);
  end
end

-- barbed shot
if (GetBuffTimeLeft("player", "frenzy")-GetCurrentSpellGCD("barbed shot")>GetFullRechargeTime("barbed shot")) then
  if IsCastableAtEnemyTarget("barbed shot", 0) then
    WowCyborg_CURRENTATTACK = "barbed shot";
    return SetSpellRequest(barbed_shot);
  end
end

WowCyborg_CURRENTATTACK = "-";
return SetSpellRequest(nil);
end

function RenderMazoonMultiRotation()
  -- barbed shot
  if (GetDebuffTimeLeft("target", "barbed shot")) then
    if IsCastableAtEnemyTarget("barbed shot", 0) then
      WowCyborg_CURRENTATTACK = "barbed shot";
      return SetSpellRequest(barbed_shot);
    end
  end
  
  -- multi-shot
  if (GetGCDMax()-GetBuffTimeLeft("pet", "beast cleave")>0.25) then
    if IsCastableAtEnemyTarget("multi-shot", 0) then
      WowCyborg_CURRENTATTACK = "multi-shot";
      return SetSpellRequest(multishot);
    end
  end
  
  -- barbed shot
  if (GetDebuffTimeLeft("target", "barbed shot")) then
    if IsCastableAtEnemyTarget("barbed shot", 0) then
      WowCyborg_CURRENTATTACK = "barbed shot";
      return SetSpellRequest(barbed_shot);
    end
  end
  
  -- aspect of the wild
  if (true) then
    if IsCastableAtEnemyTarget("aspect of the wild", 0) then
      WowCyborg_CURRENTATTACK = "aspect of the wild";
      return SetSpellRequest(aspect_of_the_wild);
    end
  end
  
  -- stampede
  if (FindBuff("player", "aspect of the wild") ~= nil and FindBuff("player", "bestial wrath") ~= nil or 30<15) then
    if IsCastableAtEnemyTarget("stampede", 0) then
      WowCyborg_CURRENTATTACK = "stampede";
      return SetSpellRequest(stampede);
    end
  end
  
  -- bestial wrath
  if (GetCooldown("aspect of the wild")>20 or TalentEnabled("one with the pack") or 30<15) then
    if IsCastableAtEnemyTarget("bestial wrath", 0) then
      WowCyborg_CURRENTATTACK = "bestial wrath";
      return SetSpellRequest(bestial_wrath);
    end
  end
  
  -- chimaera shot
  if (true) then
    if IsCastableAtEnemyTarget("chimaera shot", 0) then
      WowCyborg_CURRENTATTACK = "chimaera shot";
      return SetSpellRequest(chimaera_shot);
    end
  end
  
  -- a murder of crows
  if (true) then
    if IsCastableAtEnemyTarget("a murder of crows", 0) then
      WowCyborg_CURRENTATTACK = "a murder of crows";
      return SetSpellRequest(a_murder_of_crows);
    end
  end
  
  -- barrage
  if (true) then
    if IsCastableAtEnemyTarget("barrage", 0) then
      WowCyborg_CURRENTATTACK = "barrage";
      return SetSpellRequest(barrage);
    end
  end
  
  -- kill command
  if (GetActiveEnemies()<4 or  not true) then
    if IsCastableAtEnemyTarget("kill command", 0) then
      WowCyborg_CURRENTATTACK = "kill command";
      return SetSpellRequest(kill_command);
    end
  end
  
  -- dire beast
  if (true) then
    if IsCastableAtEnemyTarget("dire beast", 0) then
      WowCyborg_CURRENTATTACK = "dire beast";
      return SetSpellRequest(dire_beast);
    end
  end
  
  -- barbed shot
  if (GetDebuffTimeLeft("target", "barbed shot")) then
    if IsCastableAtEnemyTarget("barbed shot", 0) then
      WowCyborg_CURRENTATTACK = "barbed shot";
      return SetSpellRequest(barbed_shot);
    end
  end
  
  -- focused azerite beam
  if (true) then
    if IsCastableAtEnemyTarget("focused azerite beam", 0) then
      WowCyborg_CURRENTATTACK = "focused azerite beam";
      return SetSpellRequest(focused_azerite_beam);
    end
  end
  
  -- purifying blast
  if (true) then
    if IsCastableAtEnemyTarget("purifying blast", 0) then
      WowCyborg_CURRENTATTACK = "purifying blast";
      return SetSpellRequest(purifying_blast);
    end
  end
  
  -- concentrated flame
  if (true) then
    if IsCastableAtEnemyTarget("concentrated flame", 0) then
      WowCyborg_CURRENTATTACK = "concentrated flame";
      return SetSpellRequest(concentrated_flame);
    end
  end
  
  -- blood of the enemy
  if (true) then
    if IsCastableAtEnemyTarget("blood of the enemy", 0) then
      WowCyborg_CURRENTATTACK = "blood of the enemy";
      return SetSpellRequest(blood_of_the_enemy);
    end
  end
  
  -- the unbound force
  if (FindBuff("player", "reckless force") ~= nil or GetBuffStacks("reckless force counter")<10) then
    if IsCastableAtEnemyTarget("the unbound force", 0) then
      WowCyborg_CURRENTATTACK = "the unbound force";
      return SetSpellRequest(the_unbound_force);
    end
  end
  
  -- multi-shot
  if (true and GetActiveEnemies()>2) then
    if IsCastableAtEnemyTarget("multi-shot", 0) then
      WowCyborg_CURRENTATTACK = "multi-shot";
      return SetSpellRequest(multishot);
    end
  end
  
  -- cobra shot
  if (GetCooldown("kill command")>GetTimeToMax() and (GetActiveEnemies()<3 or  not true)) then
    if IsCastableAtEnemyTarget("cobra shot", 0) then
      WowCyborg_CURRENTATTACK = "cobra shot";
      return SetSpellRequest(cobra_shot);
    end
  end
  
  -- spitting cobra
  if (true) then
    if IsCastableAtEnemyTarget("spitting cobra", 0) then
      WowCyborg_CURRENTATTACK = "spitting cobra";
      return SetSpellRequest(spitting_cobra);
    end
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  local name = GetUnitName("player")

  if name ~= "Thering" then
    if startedFollowingAt > GetTime() - 0.5 then
      WowCyborg_CURRENTATTACK = "Following...";
      return SetSpellRequest(follow);
    end

    if startedAssistAt > GetTime() - 0.5 then
      WowCyborg_CURRENTATTACK = "Assisting...";
      return SetSpellRequest(assist);
    end

    if name ~= "Kattigast" then
      local tarname = GetUnitName("target")
      local tarHp = GetHealthPercentage("target")
      if tarname == nil or tarHp < 2 then
        if (UnitCanAttack("player", "party1target")) then
          WowCyborg_CURRENTATTACK = "Assisting...";
          return SetSpellRequest(assist);
        end
      end
    end
  end

  if name == "Klong" then
    return RenderKlongRotation()
  end

  if name == "Kattigast" then
    return RenderKattigastRotation()
  end

  if name == "Thering" then
    return RenderTheRingRotation()
  end

  if name == "Mazoon" then
    return RenderMazoonSingleRotation()
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

function CreateEmoteListenerFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("CHAT_MSG_SAY");
  print("Listener")
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

print("Group rotation loaded");
CreateDamageTakenFrame();
CreateEmoteListenerFrame();