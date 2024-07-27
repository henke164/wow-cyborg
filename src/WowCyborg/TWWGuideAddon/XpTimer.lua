print("Loading xp timer...");
local defaults = {
  TotalXP = 0
}

local collectedXP = 0
local xpListener = CreateFrame("FRAME");
xpListener:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
xpListener:SetScript("OnEvent", function(self, event, ...)
  if (event == "CHAT_MSG_COMBAT_XP_GAIN") then
    local arg1 = ...;
    local xpgained = string.match(string.match(arg1, "%d+ experience"), "%d+");
    collectedXP = collectedXP + tonumber(xpgained);
  end
end);

local timer = CreateFrame("FRAME");
local function setTimer(duration, func)
	local endTime = GetTime() + duration;
	timer:SetScript("OnUpdate", function()
		if(endTime < GetTime()) then
			timer:SetScript("OnUpdate", nil);
			func();
		end
	end);
end

local xpTicks = {};
local currentTick = 1;

function printXpPerHour()
  local total = 0;
  for i = 1, 30 do
    if xpTicks[i] == nil then
      break;
    end
    total = total + xpTicks[i];
  end
  WowCyborg_XPPerHour:SetText("XP/Hour: " .. (total * 60));
end

function loop()
  setTimer(10, function()
    xpTicks[currentTick] = collectedXP;
    currentTick = currentTick + 1;
    if (currentTick > 30) then
      currentTick = 1;
    end
    printXpPerHour();
    collectedXP = 0;
    loop();
  end);
end
loop();