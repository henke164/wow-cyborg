--[[
  Button    Spell
  1         Regrowth
  3         Rejuvenation
  4         Swiftmend
  5         Wild Growth
]]--

function RenderSingleTargetRotation()
end

function CreateEmoteListenerFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("CHAT_MSG_PARTY_LEADER");
  frame:SetScript("OnEvent", function(self, event, ...)
    command = ...;
    if string.find(command, "follow", 1, true) then
      print("Following");
      startedFollowingAt = GetTime();
      isDrinking = false;
    end
    if string.find(command, "wait", 1, true) then
      print("Waiting");
      startedAssistAt = GetTime();
      isDrinking = false;
    end
    if string.find(command, "drink", 1, true) then
      print("drinking");
      startedDrinkAt = GetTime();
      isDrinking = true;
    end
  end)
end

print("TBC Resto druid follower rotation loaded");
CreateEmoteListenerFrame();
CreateDamageTakenFrame();