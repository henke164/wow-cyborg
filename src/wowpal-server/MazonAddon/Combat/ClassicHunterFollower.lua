--[[
  Button    Spell
  Ctrl+1    Macro for following focus "/follow focus"
  Ctrl+2    Macro for assisting focus "/assist focus"
  Ctrl+3    Mount
]]--

local startedFollowingAt = 0;
local startedAssistAt = 0;
local startedWaitAt = 0;
local cobraShot = "1";
local follow = "CTRL+1";
local assist = "CTRL+2";
local mount = "CTRL+3";
local back = "CTRL+9";

function RenderMultiTargetRotation()
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  if startedFollowingAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Following...";
    return SetSpellRequest(follow);
  end

  if startedAssistAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Assisting...";
    return SetSpellRequest(assist);
  end
  
  if startedWaitAt > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Waiting...";
    return SetSpellRequest(back);
  end
  
  local energy = UnitPower("player");
  if IsCastableAtEnemyTarget("Cobra Shot", 0) and energy > 90 then
    WowCyborg_CURRENTATTACK = "Cobra Shot";
    return SetSpellRequest(cobraShot);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function CreateEmoteListenerFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("CHAT_MSG_TEXT_EMOTE");
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
    if string.find(command, "fart", 1, true) then
      print("Mounting");
      SetSpellRequest(mount);
    end
    if string.find(command, "waves", 1, true) then
      print("Fall back");
      startedWaitAt = GetTime();
    end
  end)
end

print("Classic hunter rotation loaded");
CreateEmoteListenerFrame();