--[[
  Button    Spell
]]--

local consecration = "F+1";
local hammerOfWrath = "H";
local shieldOfTheRighteous = "V";
local holyShock = 2;
local crusaderStrike = 3;
local judgment = 4;
local prism = "T";

local chainHeal = {};
chainHeal[1] = "F+5";
chainHeal[2] = "F+6";
chainHeal[3] = "F+7";
chainHeal[4] = "F+8";
chainHeal[5] = "F+9";
chainHeal[6] = "1";

local shock = {};
shock[1] = "6";
shock[2] = "7";
shock[3] = "8";
shock[4] = "9";
shock[5] = "0";
shock[6] = "2";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "F4",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD5",
  "NUMPAD9",
  "F",
  "R",
  "ESCAPE"
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
  if name == "player" then
    return 1;
  end
  
  if name == "mouseover" then
    return 6;
  end

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
    lowCount = 1;
  end

  if IsInRaid("player") then
    for groupindex = 1,25 do
      local php = GetHealthPercentage("raid" .. groupindex);
      if tostring(php) ~= "-nan(ind)" and php > 1 and php < 95 then
        if IsSpellInRange("Word of Glory", "raid" .. groupindex) == 1 then
          lowCount = lowCount + 1;
        end
      end
    end
  else
    for groupindex = 1,5 do
      local php = GetHealthPercentage("party" .. groupindex);
      if tostring(php) ~= "-nan(ind)" and php > 1 and php < 95 then
        if IsSpellInRange("Word of Glory", "party" .. groupindex) == 1 then
          lowCount = lowCount + 1;
        end
      end
    end
  end
  
  if IsInRaid("player") then
    return lowCount > 4;
  end

  return lowCount > 2;
end

function FindHealingTarget()
  local members = GetGroupRosterInfo();
  local lowestHealth = { hp = 100, name = "player" };

  local playerHp = GetHealthPercentage("player");
  if playerHp > 0 and playerHp < 90 then
    lowestHealth = { hp = playerHp, name = "player" }
  end

  if IsInRaid("player") then
    if UnitCanAttack("player", "mouseover") == false then
      local hp = GetHealthPercentage("mouseover");
      if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 90 then
        if hp < lowestHealth.hp then
          if IsSpellInRange("Riptide", "mouseover") == 1 then
            lowestHealth = { hp = playerHp, name = "mouseover" }
          end
        end
      end
    end
  else
    for groupindex = 1,5 do
      if members[groupindex] ~= nil and members[groupindex].name ~= nil then
        local hp = GetHealthPercentage(members[groupindex].name);
        if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 90 then
          if lowestHealth == nil or hp < lowestHealth.hp then
            if IsSpellInRange("Riptide", members[groupindex].name) == 1 then
              lowestHealth = { hp = hp, name = members[groupindex].name }
            end
          end
        end
      end
    end
  end

  if lowestHealth ~= nil and lowestHealth.hp < 90 then
    return lowestHealth.name, lowestHealth.hp;
  end

  return nil; 
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(skipDps)
  if skipDps == nil then
    skipDps = false;
  end

  if IsInRaid("player") then
    skipDps = true;
  end

  local speed = GetUnitSpeed("player");
  local healingTarget, healingTargetHp = FindHealingTarget();
  local twBuff = FindBuff("player", "Tidal Waves");
  local playerHp = GetHealthPercentage("player");
  local riptideCastable = GetSpellCharges("Riptide") > 0 and IsCastable("Riptide", 0);

  if healingTarget ~= nil then
    local erBuff = FindBuff("player", "Elemental Resistance")
    if erBuff == nil and AoeHealingRequired() and IsCastable("Healing Stream Totem", 4500) then
      return SetSpellRequest("5");
    end
    
    local riptideBuff = FindBuff(healingTarget, "Riptide");
    if twBuff == nil and healingTargetHp < 90 and riptideCastable then
      local memberindex = GetMemberIndex(healingTarget);
      WowCyborg_CURRENTATTACK = "Riptide " .. healingTarget;
      return SetSpellRequest(chainHeal[memberindex]);
    end
    
    if speed == 0 and AoeHealingRequired() then
      if IsCastable("Chain Heal", 0) then
        local memberindex = GetMemberIndex(healingTarget);
        WowCyborg_CURRENTATTACK = "Chain Heal " .. healingTarget;
        return SetSpellRequest(chainHeal[memberindex]);
      end
    elseif speed == 0 and healingTarget == "mouseover" and IsCastable("Healing Surge", 45000) then
      WowCyborg_CURRENTATTACK = "Healing Surge " .. healingTarget;
      return SetSpellRequest("X");
    end

    
    local riptideBuff = FindBuff(healingTarget, "Riptide");
    if riptideBuff == nil and healingTargetHp < 90 and riptideCastable then
      local memberindex = GetMemberIndex(healingTarget);
      WowCyborg_CURRENTATTACK = "Riptide " .. healingTarget;
      return SetSpellRequest(chainHeal[memberindex]);
    end
  end
  
  if UnitCanAttack("player", "mouseover") == false then
    local hp = GetHealthPercentage("mouseover");
    if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 95 then
      if speed == 0 and IsCastable("Healing Surge", 45000) then
        WowCyborg_CURRENTATTACK = "Healing Surge Mouseover";
        return SetSpellRequest("X");
      end
    end
  end


  if UnitCanAttack("player", "target") == true then
    if WowCyborg_INCOMBAT then
      local targetHp = GetHealthPercentage("target");
    end 

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Resto shammy rotation loaded");