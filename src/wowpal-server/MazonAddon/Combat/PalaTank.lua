--[[
  Button    Spell
]]--

local judgment = 1;
local avengersShield = 2;
local blessedHammer = 3;
local shieldOfTheRighteous = 4;
local lightOfTheProtector = 5;
local consecration = 6;

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "F7",
  "0",
  "F",
  "R",
  "ESCAPE"
}

function IsMelee()
  return CheckInteractDistance("target", 5);
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
        if IsSpellInRange("Hand of the Protector", members[groupindex].name) == 1 then
          lowestHealth = { hp = hp, name = members[groupindex].name }
        end
      end
    end
  end

  if lowestHealth ~= nil and lowestHealth.hp < 90 then
    return lowestHealth.name, 0;
  end

  return nil; 
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(disableAutoTarget)
  local hp = GetHealthPercentage("player");
  if hp < 90 then
    if IsCastable("Light of the Protector", 0) then
      WowCyborg_CURRENTATTACK = "Light of the Protector";
      return SetSpellRequest(lightOfTheProtector);
    end
  end

  local concetration = FindBuff("player", "Consecration");
  if concetration == nil and IsMelee() and IsCastableAtEnemyTarget("Consecration", 0) then
    WowCyborg_CURRENTATTACK = "Consecration";
    return SetSpellRequest(consecration);
  end

  local friendlyTargetName = FindHealingTarget();
  if friendlyTargetName ~= nil and IsCastable("Hand of the Protector", 0) then
    local memberindex = GetMemberIndex(friendlyTargetName);
    WowCyborg_CURRENTATTACK = "Protector " .. friendlyTargetName;
    return SetSpellRequest("CTRL+" .. memberindex);
  end

  local judgmentDebuff = FindDebuff("target", "Judgment of Light")
  if judgmentDebuff == nil and IsCastableAtEnemyTarget("Judgment", 0) then
    WowCyborg_CURRENTATTACK = "Judgment";
    return SetSpellRequest(judgment);
  end
  
  local sotrCharges = GetSpellCharges("Shield of the Righteous")

  if IsMelee() and IsCastableAtEnemyTarget("Shield of the Righteous", 0) then
    WowCyborg_CURRENTATTACK = "Shield of the Righteous";
    return SetSpellRequest(shieldOfTheRighteous);
  end

  if IsCastableAtEnemyTarget("Avenger's Shield", 0) then
    WowCyborg_CURRENTATTACK = "Avenger's Shield";
    return SetSpellRequest(avengersShield);
  end
  
  if IsMelee() and IsCastableAtEnemyTarget("Blessed Hammer", 0) then
    WowCyborg_CURRENTATTACK = "Blessed Hammer";
    return SetSpellRequest(blessedHammer);
  end
  
  if IsMelee() and IsCastableAtEnemyTarget("Hammer of the Righteous", 0) then
    WowCyborg_CURRENTATTACK = "Hammer of the Righteous";
    return SetSpellRequest(blessedHammer);
  end
  
  if IsMelee() and IsCastableAtEnemyTarget("Blessed Hammer", 0) then
    WowCyborg_CURRENTATTACK = "Blessed Hammer";
    return SetSpellRequest(blessedHammer);
  end

  if IsCastableAtEnemyTarget("Judgment", 0) then
    WowCyborg_CURRENTATTACK = "Judgment";
    return SetSpellRequest(judgment);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Holy pala rotation loaded");