--[[
  Button    Spell
]]--

local consecration = 1;
local blessedHammer = 2;
local judgment = 3;
local guardian = 4;
local defender = 5;
local avengersShield = 6;
local shieldOfTheRighteous = 7;
local hammerOfWrath = 8;
local hammerOfLight = 9;

local wog = {};
wog[1] = "F+5";
wog[2] = "F+6";
wog[3] = "F+7";
wog[4] = "F+8";
wog[5] = "F+9";

WowCyborg_PAUSE_KEYS = {
  "§",
  "F",
  "R",
  "X",
  "F4",
  "NUMPAD1",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "UP",
  "LSHIFT",
  "ESCAPE",
}

function IsMelee()
  return IsSpellInRange("Rebuke", "target") == 1;
end

function GetBurstCooldown()
  local sStart, sDuration = GetSpellCooldown("Sentinel");
  local tl = sStart + sDuration - GetTime();
  if tl < 1 then
    return 0;
  end

  return tl;
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

function FindHealingTarget(shiningBuff, shiningTimeLeft)
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

  if shiningBuff ~= nil and shiningTimeLeft < 5 and lowestHealth ~= nil and lowestHealth.hp < 100 then
    return lowestHealth.name, 0;
  end

  if shiningBuff ~= nil and lowestHealth ~= nil and lowestHealth.hp < 60 then
    return lowestHealth.name, 0;
  end
  
  if shiningBuff == nil and lowestHealth ~= nil and lowestHealth.hp < 30 then
    return lowestHealth.name, 0;
  end

  return nil; 
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(saveHolyPower)
  if saveHolyPower == nil then
    saveHolyPower = false;
  end

  local targetName = UnitName("target");
  local bastionBuff = FindBuff("player", "Bastion of Light");
  local hp = GetHealthPercentage("player");
  local mana = 0;
  if UnitPower("player") ~= nil and UnitPowerMax("player") ~= nil then
    if UnitPower("player") > 0 and UnitPowerMax("player") > 0 then
      mana = (UnitPower("player") / UnitPowerMax("player")) * 100;
    end
  end
  local targetHp = GetHealthPercentage("target");
  local holyPower = UnitPower("player", 9);
  local wrathBuff = FindBuff("player", "Avenging Wrath");
  local sentinelBuff = FindBuff("player", "Sentinel");
  local concecrationBuff, concTimeLeft = FindBuff("player", "Consecration");
  local speed = GetUnitSpeed("player");
  local useHol = false;

  local holActive = C_Spell.GetOverrideSpell(387174) == 427453;
  if (holActive) then
    useHol = true;
    saveHolyPower = true;
  end

  local bulwarkActive = C_Spell.GetOverrideSpell(432459) == 432459;

  if targetName == "Incorporeal Being" then
    if IsCastableAtEnemyTarget("Turn Evil", 0) then
      WowCyborg_CURRENTATTACK = "Turn Evil";
      return SetSpellRequest(9);
    end
  end

  if (UnitChannelInfo("target") or UnitCastingInfo("target")) and IsCastableAtEnemyTarget("Avenger's Shield", 0) then
    WowCyborg_CURRENTATTACK = "Avenger's Shield";
    return SetSpellRequest(avengersShield);
  end

  if (hp < 75) then
    local shiningBuff, shiningTl, shiningStacks, _, icon = FindBuff("player", "Shining Light");
    if (shiningBuff ~= nil and shiningStacks > 0 and icon == 1360763) or bastionBuff ~= nil then
      WowCyborg_CURRENTATTACK = "Word of Glory (Self)";
      return SetSpellRequest(wog[1]);
    end
  end

  local poweredUp = holyPower > 2 or bastionBuff ~= nil;

  local divine = FindBuff("player", "Divine Purpose")
  if poweredUp == false then
    poweredUp = divine ~= nil;
  end


  if hp < 50 then
    if (poweredUp and mana >= 10) then
      WowCyborg_CURRENTATTACK = "Word of Glory (Self)";
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

    local hbCharges = GetSpellCharges("Holy Bulwark");
    if sentinelBuff == nil and (hp < 75 or hbCharges == 2) then
      if bulwarkActive and IsCastable("Holy Bulwark", 0) then
        local currentHolyBulwarkBuff = FindBuff("player", "Holy Bulwark");
        if currentHolyBulwarkBuff == nil then
          WowCyborg_CURRENTATTACK = "Holy Bulwark";
          return SetSpellRequest(9);
        end
      end
    end

    if bulwarkActive == false and GetBurstCooldown() > 25 and FindBuff("player", "Sacred Weapon") == nil then
      if IsCastable("Sacred Weapon", 0) then
        WowCyborg_CURRENTATTACK = "Sacred Weapon";
        return SetSpellRequest(9);
      end
    end
  end

  if (concecrationBuff == nil or (concTimeLeft > 0 and concTimeLeft < 2)) and IsMelee() and IsCastable("Consecration", 0) and speed == 0 then
    WowCyborg_CURRENTATTACK = "Consecration";
    return SetSpellRequest(consecration);
  end

  local friendlyTargetName = FindHealingTarget(shiningBuff, shiningTl);
  if friendlyTargetName ~= nil then
    if poweredUp and saveHolyPower == false and mana >= 10 then
      local memberindex = GetMemberIndex(friendlyTargetName);
      WowCyborg_CURRENTATTACK = "Word of Glory " .. friendlyTargetName;
      return SetSpellRequest(wog[memberindex]);
    end

    if shiningBuff ~= nil and shiningStacks > 0 and icon == 1360763 then
      local memberindex = GetMemberIndex(friendlyTargetName);
      WowCyborg_CURRENTATTACK = "Word of Glory " .. friendlyTargetName;
      return SetSpellRequest(wog[memberindex]);
    end
  end

  if (shiningBuff ~= nil and shiningStacks > 0 and icon == 1360763) then
    if (shiningTl < 5) then
      WowCyborg_CURRENTATTACK = "Word of Glory (Self)";
      return SetSpellRequest(wog[1]);
    end
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
  
  if IsMelee() and IsCastable("Shield of the Righteous", 0) and poweredUp and saveHolyPower == false then
    WowCyborg_CURRENTATTACK = "Shield of the Righteous";
    return SetSpellRequest(shieldOfTheRighteous);
  end
  
  if IsMelee() and IsCastable("Shield of the Righteous", 0) and holyPower > 2 and useHol then
    WowCyborg_CURRENTATTACK = "Hammer of Light";
    return SetSpellRequest(hammerOfLight);
  end

  if IsCastableAtEnemyTarget("Judgment", 0) and holyPower < 3 then
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

  if shouldCastConcecration and IsMelee() and IsCastable("Consecration", 0) and speed == 0 then
    WowCyborg_CURRENTATTACK = "Consecration";
    return SetSpellRequest(consecration);
  end

  if IsMelee() then
    if IsCastable("Blessed Hammer", 0) then
      if shouldCastConcecration and IsCastable("Consecration", 0) then
        WowCyborg_CURRENTATTACK = "Consecration";
        return SetSpellRequest(consecration);
      end

      if IsCastable("Blessed Hammer", 0) then
        WowCyborg_CURRENTATTACK = "Blessed Hammer";
        return SetSpellRequest(blessedHammer);
      end
    end
  end
    
  if IsMelee() then
    if IsCastableAtEnemyTarget("Hammer of the Righteous", 0) then
      if shouldCastConcecration and IsCastable("Consecration", 0) then
        WowCyborg_CURRENTATTACK = "Consecration";
        return SetSpellRequest(consecration);
      end
      
      if concetration ~= nil then
        WowCyborg_CURRENTATTACK = "Hammer of the Righteous";
        return SetSpellRequest(blessedHammer);
      end
    end
  end
  
  local judgmentCharges = GetSpellCharges("Judgment");
  if IsCastableAtEnemyTarget("Judgment", 0) and (holyPower < 3 or judgmentCharges > 1) then
    WowCyborg_CURRENTATTACK = "Judgment";
    return SetSpellRequest(judgment);
  end
  
  if IsCastable("Blessed Hammer", 0) and WowCyborg_INCOMBAT then
    if (GetSpellCharges("Blessed Hammer") > 2) then
      WowCyborg_CURRENTATTACK = "Blessed Hammer";
      return SetSpellRequest(blessedHammer);
    end

    if holyPower < 3 and GetSpellCharges("Blessed Hammer") > 1 then
      WowCyborg_CURRENTATTACK = "Blessed Hammer";
      return SetSpellRequest(blessedHammer);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Prot pala rotation loaded");