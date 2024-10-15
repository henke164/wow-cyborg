--[[
  Button    Spell
]]--

local adaptiveSwarm = "9";
local rake = "F+6";
local rip = "F+9";
local shred = "F+7";
local maim = "2";
local ferociousBite = "3";
local moonfire = "6";
local tigersFury = "7";
local thrash = "8";
local brutalSlash = "F+5";
local feralFrenzy = "F+8";
local regrowth = {};
regrowth[1] = "CTRL+1";
regrowth[2] = "CTRL+2";
regrowth[3] = "CTRL+3";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F4",
  "R",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "NUMPAD6",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "F10",
  "LSHIFT"
}

function ShouldMoonfire()
  local t_, t__, t___, shouldUseMoonfire = GetTalentInfo(1,3,1);
  return shouldUseMoonfire;
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

function FindFriendlyHealingTarget()
  local lowestHealth = nil

  --find lowest hp
  local members = GetGroupRosterInfo();
  for groupindex = 1,5 do
    if members[groupindex] == nil or members[groupindex].name == nil then
      break;
    end
    
    local hp = GetHealthPercentage(members[groupindex].name);
    if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 85 then
      if lowestHealth == nil or hp <= lowestHealth.hp then
        if IsSpellInRange("Regrowth", members[groupindex].name) then
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

function IsMelee()
  return IsSpellInRange("Shred") == 1;
end

function RenderBearRotation()
  local hp = GetHealthPercentage("player");
  if hp < 70 then
    if IsCastable("Frenzied Regeneration", 10) then
      WowCyborg_CURRENTATTACK = "Frenzied Regeneration";
      return SetSpellRequest("3");
    end
    
    if IsCastable("Ironfur", 40) then
      WowCyborg_CURRENTATTACK = "Ironfur";
      return SetSpellRequest("4");
    end
  end
  
  if IsCastable("Strength of the Wild", 40) then
    WowCyborg_CURRENTATTACK = "Strength of the Wild";
    return SetSpellRequest("7");
  end

  if IsCastableAtEnemyTarget("Mangle", 0) then
    WowCyborg_CURRENTATTACK = "Mangle";
    return SetSpellRequest("2");
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(stun)
  if UnitChannelInfo("player") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "BURSTING";
    return SetSpellRequest(nil);
  end

  local casting = UnitChannelInfo("player");

  if casting == "Shackles of Malediction" then
    WowCyborg_CURRENTATTACK = "Shackles of Malediction";
    return SetSpellRequest(nil);
  end

  if casting == "Fleshcraft" then
    return true;
  end

  local cat = FindBuff("player", "Cat Form");
  local bear = FindBuff("player", "Bear Form");

  if bear ~= nil then
    return RenderBearRotation();
  end

  if cat == nil then
    WowCyborg_CURRENTATTACK = "Not Cat";
    return SetSpellRequest(nil);
  end
  
  local energy = UnitPower("player");
  local hp = GetHealthPercentage("player");
  local targetHp = GetHealthPercentage("player");
  local prowl = FindBuff("player", "Prowl");
  local moonfireDebuff, moonfireTl = FindDebuff("target", "Moonfire");

  local members = GetGroupRosterInfo();
  local predaSwiftBuff = FindBuff("player", "Predatory Swiftness");
  local speed = GetUnitSpeed("player");
  if predaSwiftBuff ~= nil and speed > 0 then
    local friendlyTargetName = FindFriendlyHealingTarget();
    if friendlyTargetName ~= nil then
      local memberindex = GetMemberIndex(friendlyTargetName);
      if memberindex < 4 and members[memberindex] ~= nil then
        if IsSpellInRange("Regrowth", members[memberindex].name) then
          WowCyborg_CURRENTATTACK = "Regrowth";
          return SetSpellRequest(regrowth[memberindex]);
        end
      end
    end
  end

  if IsMelee() == false then
    if WowCyborg_INCOMBAT and prowl == nil and (moonfireDebuff == nil or moonfireTl < 4) and IsCastableAtEnemyTarget("Moonfire", 30) then
      if ShouldMoonfire() then
        WowCyborg_CURRENTATTACK = "Moonfire";
        return SetSpellRequest(moonfire);
      end
    end
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local rakeDot, rakeTl = FindDebuff("target", "Rake");
  if (prowl ~= nil or (rakeDot == nil or rakeTl < 5)) and IsCastableAtEnemyTarget("Rake", 35) then
    WowCyborg_CURRENTATTACK = "Rake";
    return SetSpellRequest(rake);
  end

  local tfuryBuff = FindBuff("player", "Tiger's Fury");
  if energy <= 80 and tfuryBuff == nil and IsCastable("Tiger's Fury", 0) then
    WowCyborg_CURRENTATTACK = "Tiger's Fury";
    return SetSpellRequest(tigersFury);
  end

  if IsCastableAtEnemyTarget("Feral Frenzy", 25) then
    WowCyborg_CURRENTATTACK = "Feral Frenzy";
    return SetSpellRequest(feralFrenzy);
  end
  
  if IsCastableAtEnemyTarget("Adaptive Swarm", 0) then
    WowCyborg_CURRENTATTACK = "Adaptive Swarm";
    return SetSpellRequest(adaptiveSwarm);
  end

  local points = GetComboPoints("player", "target");

  local ripDot, ripTl = FindDebuff("target", "Rip");
  if (points > 0 and ripDot == nil) or (ripDot ~= nil and ripTl < 4) and IsCastableAtEnemyTarget("Rip", 20) then
    WowCyborg_CURRENTATTACK = "Rip";
    return SetSpellRequest(rip);
  end

  if (moonfireDebuff == nil or moonfireTl < 4) and IsCastableAtEnemyTarget("Moonfire", 30) then
    if ShouldMoonfire() then
      WowCyborg_CURRENTATTACK = "Moonfire";
      return SetSpellRequest(moonfire);
    end
  end

  local clearcastingBuff = FindBuff("player", "Clearcasting");
  if clearcastingBuff ~= nil then
    local thrashDot, thrashDotTl = FindDebuff("target", "Thrash");
    if thrashDot == nil or thrashDotTl < 5 and IsCastableAtEnemyTarget("Thrash", 0) then
      WowCyborg_CURRENTATTACK = "Thrash";
      return SetSpellRequest(thrash);
    end
  end

  if points < 5 and IsCastableAtEnemyTarget("Brutal Slash", 0) then
    WowCyborg_CURRENTATTACK = "Brutal Slash";
    return SetSpellRequest(brutalSlash);
  end

  if points == 5 then
    if energy <= 20 and tfuryBuff == nil and IsCastable("Tiger's Fury", 0) then
      WowCyborg_CURRENTATTACK = "Tiger's Fury";
      return SetSpellRequest(tigersFury);
    end

    if stun == true then
      if IsCastableAtEnemyTarget("Maim", 30) then
        WowCyborg_CURRENTATTACK = "Maim";
        return SetSpellRequest(maim);
      end

      if IsCastableAtEnemyTarget("Ferocious Bite", 25) then
        WowCyborg_CURRENTATTACK = "Ferocious Bite";
        return SetSpellRequest(ferociousBite);
      end
    end
    
    if stun ~= true and IsCastableAtEnemyTarget("Ferocious Bite", 25) then
      WowCyborg_CURRENTATTACK = "Ferocious Bite";
      return SetSpellRequest(ferociousBite);
    end
  end

  if IsCastableAtEnemyTarget("Shred", 0) and (points < 5 or clearcastingBuff) then
    WowCyborg_CURRENTATTACK = "Shred";
    return SetSpellRequest(shred);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Druid feral rotation loaded !");