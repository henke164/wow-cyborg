--[[
  Button    Spell
]]--

local startedFollowingAt = 0;
local startedAssistAt = 0;
local startedBurstAt = 0;
local startedDrinkAt = 0;
local startedHumanizeAt = 0;

local wand = "6";
local follow = "F+8";
local assist = "F+9";
local assist2 = "F+5";
local humanize = "F+7";
local drink = "SHIFT+9";
local holdFire = false;
local isConjuring = false;
local isDrinking = false;
local forceDrain = false;

local cancelCast = "F+6";

function GetSpellCD(name)
  local stStart, stDuration = GetSpellCooldown(name);
  if stStart == nil then
    return 60;
  end

  local stCdLeft = stStart + stDuration - GetTime();
  return stCdLeft;
end

function GetHP(unit)
  local maxHp = UnitHealthMax(unit);
  local hp = UnitHealth(unit);

  if maxHp == 0 or hp == 0 then
    return 0;
  end

  return ((hp) / maxHp) * 100;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(aoe)
  local hp = GetHP("player");
  local mana = (UnitPower("player") / UnitPowerMax("player")) * 100;
  local targetRawHp = UnitHealth("target");

  if startedHumanizeAt > GetTime() - (0.5 + (math.random() * 2)) then
    WowCyborg_CURRENTATTACK = "Humanize...";
    return SetSpellRequest(humanize);
  end

  if startedDrinkAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Drinking...";
    return SetSpellRequest(drink);
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
  
  if (UnitChannelInfo("player") ~= nil) then
    WowCyborg_CURRENTATTACK = "Draining...";
    forceDrain = false;
    return SetSpellRequest("-");
  end

  if (forceDrain) then
    if IsCastableAtEnemyTarget("Drain soul", 55) then
      WowCyborg_CURRENTATTACK = "Drain soul";
      return SetSpellRequest("F+2");
    end
  end

  -- LOCK
  local dsBuff = FindBuff("player", "Demon Armor")
  if dsBuff == nil and IsCastable("Demon Armor", 25) then
    WowCyborg_CURRENTATTACK = "Demon Armor";
    return SetSpellRequest("F+6");
  end

  if WowCyborg_INCOMBAT then
    if GetUnitName("target") == nil or UnitCanAttack("player", "target") == false or targetRawHp < 1 then
      WowCyborg_CURRENTATTACK = "Assisting...";
      return SetSpellRequest(assist2);
    end
  end
  
  --[[ CHAOS BOLT BUILD ]]--
  local speed = GetUnitSpeed("player");
  if speed > 0 then
    local agonyDebuff = FindDebuff("target", "Curse of Agony")
    if agonyDebuff == nil and IsCastableAtEnemyTarget("Curse of Agony", 25) then
      WowCyborg_CURRENTATTACK = "Curse of Agony";
      return SetSpellRequest("8");
    end
  end

  if targetRawHp < 500 and GetSpellCD("Shadowburn") <= 0 and IsSpellInRange("Shadowburn", "target") and UnitLevel("target") > 18 then
    if IsCastableAtEnemyTarget("Shadowburn", 105) then
      WowCyborg_CURRENTATTACK = "Shadowburn";
      return SetSpellRequest("5");
    elseif targetRawHp < 200 and IsCastableAtEnemyTarget("Drain soul", 0) and UnitLevel("target") > 18 then
      WowCyborg_CURRENTATTACK = "Drain soul";
      return SetSpellRequest("F+2");
    end
  end

  if GetUnitName("target") == "Searing Infernal" then
    if IsCastableAtEnemyTarget("Shadow Bolt", 110) then
      WowCyborg_CURRENTATTACK = "Shadow Bolt";
      return SetSpellRequest("1");
    end
  end

  if (UnitCastingInfo("player") == "Incinerate") then
    if targetRawHp > 400 then
      WowCyborg_CURRENTATTACK = "Chaos Bolt";
      return SetSpellRequest("4");
    else
      WowCyborg_CURRENTATTACK = "Shadow Bolt";
      return SetSpellRequest("1");
    end
  end

  local inciBuff = FindBuff("player", "Incinerate");
  if inciBuff == nil then
    if IsCastableAtEnemyTarget("Incinerate", 70) then
      WowCyborg_CURRENTATTACK = "Incinerate";
      return SetSpellRequest("F+1");
    end
  end

  if targetRawHp > 400 and IsCastableAtEnemyTarget("Chaos Bolt", 26) then
    if IsCastable("Demonic Grace", 0) and GetUnitName("pet") ~= nil then
      WowCyborg_CURRENTATTACK = "Demonic Grace";
      return SetSpellRequest("F+1");
    end

    WowCyborg_CURRENTATTACK = "Chaos Bolt";
    return SetSpellRequest("4");
  end

  if (UnitChannelInfo("player") ~= nil) then
    WowCyborg_CURRENTATTACK = "Draining...";
    return SetSpellRequest("-");
  end

  if WowCyborg_INCOMBAT then
    if hp > 60 and mana < 30 then
      if IsCastable("Life tap", 0) then
        WowCyborg_CURRENTATTACK = "Life tap";
        return SetSpellRequest("7");
      end
    end
  else
    if hp > 30 and mana < 80 then
      if IsCastable("Life tap", 0) then
        WowCyborg_CURRENTATTACK = "Life tap";
        return SetSpellRequest("7");
      end
    end
  end

  --[[ META
  local metaBuff = FindBuff("player", "Metamorphosis");

  if metaBuff ~= nil then
    if WowCyborg_INCOMBAT == false then
      if IsCastableAtEnemyTarget("Demon Charge", 0) then
        WowCyborg_CURRENTATTACK = "Demon Charge";
        return SetSpellRequest("0");
      end
    end

    if IsCurrentSpell(6603) == false then
      if IsCastableAtEnemyTarget("Curse of Agony", 0) then
        WowCyborg_CURRENTATTACK = "Attack";
        return SetSpellRequest("6");
      end
    end

    local speed = GetUnitSpeed("player");
    if speed > 0 then
      local agonyDebuff = FindDebuff("target", "Curse of Agony")
      if agonyDebuff == nil and IsCastableAtEnemyTarget("Curse of Agony", 25) then
        WowCyborg_CURRENTATTACK = "Curse of Agony";
        return SetSpellRequest("8");
      end
    end

    local targetRawHp = UnitHealth("target");
    if targetRawHp < 500 and GetSpellCD("Shadowburn") <= 0 and IsSpellInRange("Shadowburn", "target") then
      if IsCastableAtEnemyTarget("Shadowburn", 0) then
        WowCyborg_CURRENTATTACK = "Shadowburn";
        return SetSpellRequest("5");
      elseif targetRawHp < 200 and IsCastableAtEnemyTarget("Drain soul", 0) then
        WowCyborg_CURRENTATTACK = "Drain soul";
        return SetSpellRequest("F+2");
      end
    end

    if IsCastableAtEnemyTarget("Shadow Cleave", 52) then
      WowCyborg_CURRENTATTACK = "Shadow Cleave";
      return SetSpellRequest("1");
    end

    if (UnitCastingInfo("player") == "Incinerate") then
      WowCyborg_CURRENTATTACK = "Searing Pain";
      return SetSpellRequest("3");
    end
  
    local inciBuff = FindBuff("player", "Incinerate");
    if inciBuff == nil then
      if IsCastableAtEnemyTarget("Incinerate", 70) then
        WowCyborg_CURRENTATTACK = "Incinerate";
        return SetSpellRequest("F+1");
      end
    end

    if IsCastableAtEnemyTarget("Searing Pain", 70) then
      WowCyborg_CURRENTATTACK = "Searing Pain";
      return SetSpellRequest("3");
    end
  end
  ]]--

  if IsCastableAtEnemyTarget("Shadow Bolt", 0) then
    if IsCastableAtEnemyTarget("Shadow Bolt", 110) then
      WowCyborg_CURRENTATTACK = "Shadow Bolt";
      return SetSpellRequest("1");
    else
      if IsCurrentSpell(5019) == false then
        WowCyborg_CURRENTATTACK = "Wanding...";
        return SetSpellRequest(wand);
      end
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

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
      end
      if string.find(command, "maz-2", 1, true) then
        print("Waiting");
        startedAssistAt = GetTime();
        isDrinking = false;
        holdFire = false;
      end
      if string.find(command, "maz-6", 1, true) then
        startedHumanizeAt = GetTime();
      end

      if string.find(command, "t-1", 1, true) then
        if GetUnitName("player") == "Voozeh" then
          startedAssistAt = GetTime();
          isDrinking = false;
          holdFire = false;
          forceDrain = true;
        end
      end
      if string.find(command, "t-2", 1, true) then
        if GetUnitName("player") == "Hayrolina" then
          startedAssistAt = GetTime();
          isDrinking = false;
          holdFire = false;
          forceDrain = true;
        end
      end
      if string.find(command, "t-3", 1, true) then
        if GetUnitName("player") == "Loxor" then
          startedAssistAt = GetTime();
          isDrinking = false;
          holdFire = false;
          forceDrain = true;
        end
      end
    end
  end)
end

print("TBC Multi follower rotation loaded");
CreateEmoteListenerFrame();
CreateDamageTakenFrame();