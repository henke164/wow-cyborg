--[[
  Button    Spell
]]--

local startedFollowingAt = 0;
local startedAssistAt = 0;
local startedBurstAt = 0;
local startedDrinkAt = 0;

local serpentSting = "1";

local follow = "F+8";
local assist = "F+9";
local drink = "SHIFT+9";
local holdFire = false;
local isConjuring = false;
local isDrinking = false;

local cancelCast = "F+6";

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
  
  -- LOCK
  if IsCastableAtEnemyTarget("Shadow Bolt", 25) then
    WowCyborg_CURRENTATTACK = "Shadow Bolt";
    return SetSpellRequest("1");
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
      if string.find(command, "maz-3", 1, true) then
        print("Burst");
        startedBurstAt = GetTime();
        isDrinking = false;
        holdFire = false;
      end
      if string.find(command, "maz-4", 1, true) then
        print("drinking");
        startedDrinkAt = GetTime();
        isDrinking = true;
      end
      if string.find(command, "maz-5", 1, true) then
        holdFire = true;
      end
    end
  end)
end

print("TBC Multi follower rotation loaded");
CreateEmoteListenerFrame();
CreateDamageTakenFrame();