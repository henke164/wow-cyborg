--[[
  Button    Spell
]]--
local buttons = {}
buttons["moonfire"] = "1";
buttons["thrash_bear"] = "2";
buttons["mangle"] = "3";
buttons["ironfur"] = "4";
buttons["swipe_bear"] = "5";
buttons["frenzied_regeneration"] = "6";
buttons["raze"] = "7";
buttons["maul"] = "8";
buttons["pulverize"] = "9";
buttons["soothe"] = "0";

local reg = {};
buttons["regrowth"] = "F+5";
reg[1] = "F+5";
reg[2] = "F+6";
reg[3] = "F+7";
reg[4] = "F+8";
reg[5] = "F+9";

WowCyborg_PAUSE_KEYS = {
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "NUMPAD7",
  "F",
  "X",
  "§"
}

function IsTargetNearby()
  return CheckInteractDistance("target", 5);
end

function GetMemberIndex(name)
  local group = GetGroupRosterInfo();
  for groupindex = 1,25 do
    if group[groupindex] == nil then
      return nil;
    end

    if group[groupindex].name == nil then
      return nil;
    end

    if group[groupindex].name == name then
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

function FindHealingTarget()
  local lowestHealth = nil
  local members = GetGroupRosterInfo();
  for groupindex = 1,5 do
    if members[groupindex] == nil or members[groupindex].name == nil then
      break;
    end
    
    local hp = GetHealthPercentage(members[groupindex].name);
    if tostring(hp) ~= "-nan(ind)" and hp > 0 and hp < 100 then
      if lowestHealth == nil or hp <= lowestHealth.hp then
        if IsSpellInRange("Regrowth", members[groupindex].name) == 1 then
          lowestHealth = { hp = hp, name = members[groupindex].name }
        end
      end
    end
  end

  if lowestHealth ~= nil and lowestHealth.hp < 60 then
    return lowestHealth.name, 0;
  end

  return nil; 
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  local actionName = Hekili.GetQueue().Primary[1].actionName;
  local hp = GetHealthPercentage("player");
  if (hp <= 65) then
    if IsCastable("Frenzied Regeneration", 0) then
      WowCyborg_CURRENTATTACK = "Frenzied Regeneration";
      return SetSpellRequest("6");
    end
  end

  local friendlyTargetName = FindHealingTarget();
  if friendlyTargetName ~= nil then
    local poweredUp = FindBuff("player", "Dream of Cenarius");
    if poweredUp then
      local memberindex = GetMemberIndex(friendlyTargetName);
      WowCyborg_CURRENTATTACK = "Heal " .. friendlyTargetName;
      return SetSpellRequest(reg[memberindex]);
    end
  end

  local rage = UnitPower("player");

  if rage > 85 then
    if (IsCastable("Ironfur", 0) and IsSpellInRange("Mangle", "target") and UnitCanAttack("player", "target")) then
      WowCyborg_CURRENTATTACK = "Ironfur";
      return SetSpellRequest(buttons["ironfur"]);
    end
  end

  if (actionName == "moonfire") then
    if (IsCastableAtEnemyTarget("moonfire", 0) == false) then
      WowCyborg_CURRENTATTACK = "-";
      return SetSpellRequest(nil);
    end
  end

  if (actionName == "swipe_bear") then
    if ((IsTargetNearby() == false and IsSpellInRange("Mangle", "target") == 0) or IsCastableAtEnemyTarget("Swipe", 0) == false) then
      WowCyborg_CURRENTATTACK = "-";
      return SetSpellRequest(nil);
    end
  end

  if (actionName == "thrash_bear") then
    if ((IsTargetNearby() == false and IsSpellInRange("Mangle", "target") == 0) or IsCastableAtEnemyTarget("Thrash", 0) == false) then
      WowCyborg_CURRENTATTACK = "-";
      return SetSpellRequest(nil);
    end
  end

  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];
  
  if button ~= nil then
    return SetSpellRequest(button);
  end

  return SetSpellRequest(nil);
end

print("Bear rotation loaded");