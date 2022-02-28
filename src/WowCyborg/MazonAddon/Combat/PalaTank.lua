--[[
  Button    Spell
]]--

local judgment = 1;
local avengersShield = 2;
local blessedHammer = 3;
local shieldOfTheRighteous = 4;
local hammerOfWrath = 5;
local consecration = 6;
local seraphim = 7;
local defender = 8;
local guardian = 9;

local wog = {};
wog[1] = "F+5";
wog[2] = "F+6";
wog[3] = "F+7";
wog[4] = "F+8";
wog[5] = "F+9";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "F7",
  "0",
  "F",
  "R",
  "NUMPAD1",
  "NUMPAD5",
  "NUMPAD9",
  "ESCAPE",
}

function IsMelee()
  return CheckInteractDistance("target", 3);
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
        if IsSpellInRange("Word of Glory", members[groupindex].name) == 1 then
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
  local nearbyEnemies = GetNearbyEnemyCount();
  local hp = GetHealthPercentage("player");
  local targetHp = GetHealthPercentage("target");
  local holyPower = UnitPower("player", 9);
  local wrathBuff = FindBuff("player", "Avenging Wrath");

  if (wrathBuff or targetHp < 20) and nearbyEnemies < 4 then
    if IsCastableAtEnemyTarget("Hammer of Wrath", 0) then
      WowCyborg_CURRENTATTACK = "Hammer of Wrath";
      return SetSpellRequest(hammerOfWrath);
    end
  end

  local concetration = FindBuff("player", "Consecration");
  local speed = GetUnitSpeed("player");
  if concetration == nil and IsMelee() and IsCastableAtEnemyTarget("Consecration", 0) and speed == 0 then
    WowCyborg_CURRENTATTACK = "Consecration";
    return SetSpellRequest(consecration);
  end

  local shiningBuff, tl, shiningStacks, icon = FindBuff("player", "Shining Light");
  if hp < 90 then
    if shiningBuff ~= nil and shiningStacks == 1 and icon == 1360763 then
      WowCyborg_CURRENTATTACK = "Word of Glory";
      return SetSpellRequest(wog[1]);
    end
  end

  if hp < 60 then
    if (holyPower > 2) then
      WowCyborg_CURRENTATTACK = "Word of Glory";
      return SetSpellRequest(wog[1]);
    end
  end
  
  if hp < 50 then
    if IsCastable("Ardent Defender", 0) then
      WowCyborg_CURRENTATTACK = "Ardent Defender";
      return SetSpellRequest(defender);
    end
  end

  if hp < 30 then
    if IsCastable("Guardian of Ancient Kings", 0) then
      WowCyborg_CURRENTATTACK = "Guardian of Ancient Kings";
      return SetSpellRequest(guardian);
    end
  end

  if (holyPower > 2) then
    if IsCastable("Seraphim", 0) then
      WowCyborg_CURRENTATTACK = "Seraphim";
      return SetSpellRequest(seraphim);
    end
  end

  local friendlyTargetName = FindHealingTarget();
  if friendlyTargetName ~= nil and IsCastable("Word of Glory", 0) then
    if (holyPower > 2 and GetHealthPercentage(friendlyTargetName) < 60) then
      local memberindex = GetMemberIndex(friendlyTargetName);
      WowCyborg_CURRENTATTACK = "Word of Glory " .. friendlyTargetName;
      return SetSpellRequest(wog[memberindex]);
    end

    if shiningBuff ~= nil and shiningStacks == 1 and icon == 1360763 then
      local memberindex = GetMemberIndex(friendlyTargetName);
      WowCyborg_CURRENTATTACK = "Word of Glory " .. friendlyTargetName;
      return SetSpellRequest(wog[memberindex]);
    end
  end

  if IsMelee() and IsCastableAtEnemyTarget("Shield of the Righteous", 0) and holyPower > 2 then
    WowCyborg_CURRENTATTACK = "Shield of the Righteous";
    return SetSpellRequest(shieldOfTheRighteous);
  end

  if nearbyEnemies > 2 and IsCastableAtEnemyTarget("Avenger's Shield", 0) then
    WowCyborg_CURRENTATTACK = "Avenger's Shield";
    return SetSpellRequest(avengersShield);
  end
  
  if IsCastableAtEnemyTarget("Judgment", 0) then
    WowCyborg_CURRENTATTACK = "Judgment";
    return SetSpellRequest(judgment);
  end
  
  if (wrathBuff or targetHp < 20) then
    if IsCastableAtEnemyTarget("Hammer of Wrath", 0) then
      WowCyborg_CURRENTATTACK = "Hammer of Wrath";
      return SetSpellRequest(hammerOfWrath);
    end
  end

  if IsCastableAtEnemyTarget("Avenger's Shield", 0) then
    WowCyborg_CURRENTATTACK = "Avenger's Shield";
    return SetSpellRequest(avengersShield);
  end
  
  if IsMelee() and (IsCastableAtEnemyTarget("Blessed Hammer", 0) or IsCastableAtEnemyTarget("Hammer of the Righteous", 0)) then
    WowCyborg_CURRENTATTACK = "Blessed Hammer";
    return SetSpellRequest(blessedHammer);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Prot pala rotation loaded");