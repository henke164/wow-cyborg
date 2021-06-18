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

local follow = "F+8";
local assist = "F+9";
local drink = "SHIFT+9";

WowCyborg_PAUSE_KEYS = {
  "F",
  "R",
  "LSHIFT",
  "F1",
  "F2",
  "F3",
  "F4",
  "F5",
  "F6",
  "F7",
  "F11",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD5",
  "NUMPAD9",
}
function IsMelee()
  return IsSpellInRange("Wing Clip", "target") == 1;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(aoe)
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
  
  local hp = GetHealthPercentage("player");
  local targetHp = GetHealthPercentage("target");
  local petHp = GetHealthPercentage("pet");

  if UnitChannelInfo("player") == "Volley" then
    WowCyborg_CURRENTATTACK = "Volley";
    return SetSpellRequest(nil);
  end
  
  if UnitChannelInfo("player") == "Blizzard" then
    WowCyborg_CURRENTATTACK = "Blizzard";
    return SetSpellRequest(nil);
  end

  if IsCastableAtEnemyTarget("Frostbolt", 214) then
    WowCyborg_CURRENTATTACK = "Frostbolt";
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

  if petHp < 70 then
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
  frame:RegisterEvent("CHAT_MSG_PARTY_LEADER");
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
    if string.find(command, "charge", 1, true) then
      print("Burst");
      startedBurstAt = GetTime();
    end
    if string.find(command, "drink", 1, true) then
      print("drinking");
      startedDrinkAt = GetTime();
    end
  end)
end

print("TBC Hunter follower rotation loaded");
CreateEmoteListenerFrame();