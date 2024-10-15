--[[
  Button    Spell
]]--

local consecration = 1;
local avengersShield = 2;
local judgment = 3;
local guardian = 4;
local defender = 5;
local blessedHammer = 6;
local shieldOfTheRighteous = 7;
local hammerOfWrath = 8;
local seraphim = 9;

local ret_wakeOfashes = 1;
local ret_bladeOfjustice = 2;
local ret_judgment = 3;
local ret_hammerOfwrath = 4;
local ret_crusaderStrike = 5;
local ret_templarsVerdict = 6;
local ret_divineStorm = 7;
local ret_consecration = 9;
local ret_seraphim = 0;

local wog = {};
wog[1] = "F+5";
wog[2] = "F+6";
wog[3] = "F+7";
wog[4] = "F+8";
wog[5] = "F+9";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "F4",
  "F5",
  "F7",
  "§",
  "F",
  "R",
  "X",
  "NUMPAD1",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "0",
  "F",
  "R",
  "ESCAPE",
}

local combatFrame = CreateFrame("FRAME");
local lootUntil = 0;
combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
combatFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_REGEN_ENABLED" then
    lootUntil = GetTime() + 2;
  end
end)


function IsMelee()
  return IsSpellInRange("Rebuke", "target") ~= 0;
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
  local spec = GetSpecialization();
  if spec == 2 then
    return RenderSingleTankTargetRotation(true);
  elseif spec == 3 then
    return RenderSingleRetriTargetRotation(true);
  end
end


function RenderSingleTargetRotation(saveHolyPower)
  local spec = GetSpecialization();
  if spec == 2 then
    return RenderSingleTankTargetRotation();
  elseif spec == 3 then
    return RenderSingleRetriTargetRotation();
  end
end

function RenderSingleTankTargetRotation(saveHolyPower)
  if saveHolyPower == nil then
    saveHolyPower = false;
  end

  local concetration = FindBuff("player", "Consecration");
  local speed = GetUnitSpeed("player");
  local nearbyEnemies = GetNearbyEnemyCount();
  local hp = GetHealthPercentage("player");
  local targetHp = GetHealthPercentage("target");
  local holyPower = UnitPower("player", 9);
  local wrathBuff = FindBuff("player", "Avenging Wrath");
  local sentinelBuff = FindBuff("player", "Sentinel");

  if speed == 0 and lootUntil > GetTime() then
    WowCyborg_CURRENTATTACK = "Loot-A-Rang";
    return SetSpellRequest("0");
  end

  if (wrathBuff or sentinelBuff or targetHp < 20) and nearbyEnemies < 4 then
    if IsCastableAtEnemyTarget("Hammer of Wrath", 0) then
      WowCyborg_CURRENTATTACK = "Hammer of Wrath";
      return SetSpellRequest(hammerOfWrath);
    end
  end

  local shiningBuff, tl, shiningStacks, _, icon = FindBuff("player", "Shining Light");
  if shiningBuff ~= nil and shiningStacks == 1 and icon == 1360763 then
    if hp < 50 and saveHolyPower == false then
      WowCyborg_CURRENTATTACK = "Word of Glory";
      return SetSpellRequest(wog[1]);
    end
  end

  if concetration == nil and IsMelee() and IsCastableAtEnemyTarget("Consecration", 0) and speed == 0 then
    WowCyborg_CURRENTATTACK = "Consecration";
    return SetSpellRequest(consecration);
  end

  local poweredUp = holyPower > 2;

  local divine = FindBuff("player", "Divine Purpose")
  if poweredUp == false then
    poweredUp = divine ~= nil;
  end

  if hp < 60 then
    if (poweredUp) then
      WowCyborg_CURRENTATTACK = "Word of Glory";
      return SetSpellRequest(wog[1]);
    end
  end

  if WowCyborg_INCOMBAT then
    if hp < 50 then
      if IsCastable("Ardent Defender", 0) then
        WowCyborg_CURRENTATTACK = "Ardent Defender";
        return SetSpellRequest(defender);
      end
    end

    if hp < 40 then
      if IsCastable("Guardian of Ancient Kings", 0) then
        WowCyborg_CURRENTATTACK = "Guardian of Ancient Kings";
        return SetSpellRequest(guardian);
      end
    end
    
    if (poweredUp) then
      if IsCastable("Seraphim", 0) then
        WowCyborg_CURRENTATTACK = "Seraphim";
        return SetSpellRequest(seraphim);
      end
    end  
  end

  local friendlyTargetName = FindHealingTarget();
  if friendlyTargetName ~= nil and IsCastable("Word of Glory", 0) then
    if (poweredUp and GetHealthPercentage(friendlyTargetName) < 60) and saveHolyPower == false then
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

  if shiningBuff ~= nil and shiningStacks == 1 and icon == 1360763 then
    if hp < 80 then
      WowCyborg_CURRENTATTACK = "Word of Glory";
      return SetSpellRequest(wog[1]);
    end
  end

  if IsMelee() and IsCastableAtEnemyTarget("Shield of the Righteous", 0) and poweredUp and saveHolyPower == false then
    WowCyborg_CURRENTATTACK = "Shield of the Righteous";
    return SetSpellRequest(shieldOfTheRighteous);
  end

  if nearbyEnemies > 2 and IsCastableAtEnemyTarget("Avenger's Shield", 0) then
    WowCyborg_CURRENTATTACK = "Avenger's Shield";
    return SetSpellRequest(avengersShield);
  end
  
  local judgmentDebuff = FindDebuff("target", "Judgment")
  if judgmentDebuff == nil and IsCastableAtEnemyTarget("Judgment", 0) then
    WowCyborg_CURRENTATTACK = "Judgment";
    return SetSpellRequest(judgment);
  end
  
  if (wrathBuff or sentinelBuff or targetHp < 20) then
    if IsCastableAtEnemyTarget("Hammer of Wrath", 0) then
      WowCyborg_CURRENTATTACK = "Hammer of Wrath";
      return SetSpellRequest(hammerOfWrath);
    end
  end

  if IsCastableAtEnemyTarget("Avenger's Shield", 0) then
    WowCyborg_CURRENTATTACK = "Avenger's Shield";
    return SetSpellRequest(avengersShield);
  end
  
  if CheckInteractDistance("target", 3) and IsCastableAtEnemyTarget("Blessed Hammer", 0) then
    WowCyborg_CURRENTATTACK = "Blessed Hammer";
    return SetSpellRequest(blessedHammer);
  end
  
  if IsCastableAtEnemyTarget("Hammer of the Righteous", 0) then
    if CheckInteractDistance("target", 3) and concetration == nil and IsCastableAtEnemyTarget("Consecration", 0) then
      WowCyborg_CURRENTATTACK = "Consecration";
      return SetSpellRequest(consecration);
    end
    
    if IsMelee() and concetration ~= nil then
      WowCyborg_CURRENTATTACK = "Hammer of the Righteous";
      return SetSpellRequest(blessedHammer);
    end
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderSingleRetriTargetRotation(aoe)
  local holyPower = UnitPower("player", 9);
  local empBuff = FindBuff("player", "Empyrean Power");
  local hp = GetHealthPercentage("player");

  local shiningBuff, tl, shiningStacks, _, icon = FindBuff("player", "Shining Light");
  if shiningBuff ~= nil and shiningStacks == 1 and icon == 1360763 then
    if hp < 50 and saveHolyPower == false then
      WowCyborg_CURRENTATTACK = "Word of Glory";
      return SetSpellRequest(wog[1]);
    end
  end

  local poweredUp = holyPower > 2;
  if hp < 40 then
    if (poweredUp) then
      WowCyborg_CURRENTATTACK = "Word of Glory";
      return SetSpellRequest(wog[1]);
    end
  end

  if WowCyborg_INCOMBAT == false then
    if hp < 80 then
      if (poweredUp) then
        WowCyborg_CURRENTATTACK = "Word of Glory";
        return SetSpellRequest(wog[1]);
      end
    end
  end

  if IsMelee() and empBuff then
    if IsCastableAtEnemyTarget("Divine Storm", 0) then
      WowCyborg_CURRENTATTACK = "Divine Storm";
      return SetSpellRequest(ret_divineStorm);
    end
  end

  if (IsMelee() and holyPower >= 5) then
    if (aoe == true) then
      if IsCastableAtEnemyTarget("Divine Storm", 0) then
        WowCyborg_CURRENTATTACK = "Divine Storm";
        return SetSpellRequest(ret_divineStorm);
      end
    else
      if IsCastableAtEnemyTarget("Templar's Verdict", 0) then
        WowCyborg_CURRENTATTACK = "Templar's Verdict";
        return SetSpellRequest(ret_templarsVerdict);
      end
    end
  end
  
  if (IsMelee() and holyPower <= 2 and IsCastableAtEnemyTarget("Wake of Ashes", 0)) then
    WowCyborg_CURRENTATTACK = "Wake of Ashes";
    return SetSpellRequest(ret_wakeOfashes);
  end
  
  if (IsCastableAtEnemyTarget("Judgment", 0)) then
    WowCyborg_CURRENTATTACK = "Judgment";
    return SetSpellRequest(ret_judgment);
  end
  
  if (IsCastableAtEnemyTarget("Hammer of Wrath", 0)) then
    WowCyborg_CURRENTATTACK = "Hammer of Wrath";
    return SetSpellRequest(ret_hammerOfwrath);
  end
  
  if (holyPower <= 3 and IsCastableAtEnemyTarget("Blade of Justice", 0)) then
    WowCyborg_CURRENTATTACK = "Blade of Justice";
    return SetSpellRequest(ret_bladeOfjustice);
  end

  local csCharges = GetSpellCharges("Crusader Strike");

  if (csCharges == 2 and IsCastableAtEnemyTarget("Crusader Strike", 0)) then
    WowCyborg_CURRENTATTACK = "Crusader Strike";
    return SetSpellRequest(ret_crusaderStrike);
  end
 
  
  if (IsMelee() and holyPower >= 3) then
    if (aoe == true) then
      if IsCastableAtEnemyTarget("Divine Storm", 0) then
        WowCyborg_CURRENTATTACK = "Divine Storm";
        return SetSpellRequest(ret_divineStorm);
      end
    else
      if IsCastableAtEnemyTarget("Templar's Verdict", 0) then
        WowCyborg_CURRENTATTACK = "Templar's Verdict";
        return SetSpellRequest(ret_templarsVerdict);
      end
    end
  end
  
  if (IsMelee() and IsCastableAtEnemyTarget("Consecration", 0)) then
    WowCyborg_CURRENTATTACK = "Consecration";
    return SetSpellRequest(ret_consecration);
  end

  if (IsCastableAtEnemyTarget("Crusader Strike", 0)) then
    WowCyborg_CURRENTATTACK = "Crusader Strike";
    return SetSpellRequest(ret_crusaderStrike);
  end
  
  return SetSpellRequest(nil);
end

function IsMelee()
  return IsSpellInRange("Crusader Strike") == 1;
end

print("Prot pala rotation loaded");