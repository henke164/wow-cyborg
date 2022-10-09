WowCyborg_Paste = "";
WowCyborg_guideHeader = nil;
WowCyborg_guideDescription = nil;
WowCyborg_Step = 1;

-- Dragonflight auto quest
print ("Loading Dragonflight guide...");

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

function HandleSpeak()
  if GossipFrame:IsVisible() ~= true then
    return true;
  end

  local avaQuests = C_GossipInfo.GetAvailableQuests();
  for _, v in ipairs(avaQuests) do
    C_GossipInfo.SelectAvailableQuest(v.questID);
    return;
  end

  local quests = C_GossipInfo.GetActiveQuests();
  for _, v in ipairs(quests) do
    if (v.isComplete == true) then
      C_GossipInfo.SelectActiveQuest(v.questID);
      return;
    end
  end

  local options = C_GossipInfo.GetOptions();
  for _, v in ipairs(options) do
    local textFound = string.find(v.name, "(Quest)");
    if textFound ~= nil then
      C_GossipInfo.SelectOption(v.gossipOptionID);
      return;
    end
  end

  local npcOptions = {};
  for _, v in ipairs(optionsToSelect) do
    if (v.npc == nil or v.npc == UnitName("target")) then
      table.insert(npcOptions, v);
    end
  end
  
  local gossipText = C_GossipInfo.GetText();
  for _, v in ipairs(npcOptions) do
    local textFound = string.find(C_GossipInfo.GetText(), v.text);
    if textFound ~= nil then
      if C_GossipInfo.GetOptions()[v.index] == nil then
        return;
      end

      local optionId = C_GossipInfo.GetOptions()[v.index].gossipOptionID;
      C_GossipInfo.SelectOption(optionId);
      return;
    end
  end
end

function RenderStep(step)
  if (step and step.target) then
    WowCyborg_guideHeader:SetText(WowCyborg_Step .. ". " .. step.target);
  else
    WowCyborg_guideHeader:SetText(WowCyborg_Step .. ". ");
  end

  WowCyborg_guideDescription:SetText(step.description);
  TomTom.db.profile.general.confirmremoveall = false;
  SlashCmdList["TOMTOM_WAY"]("reset all");
  SlashCmdList["TOMTOM_WAY"](step.zone .. " " .. step.x .. " " .. step.y .. " " .. step.description);

  if step.target then
    for i = 1, 100 do
      local name = UnitName('nameplate' .. i);
      if name and name == step.target then
        local guid = UnitGUID('nameplate' .. i);
        SetRaidTarget('nameplate' .. i, 8);
      end
    end
  end
end

function RenderGuideFrame()
  local frame = CreateDefaultFrame(50, 300, 250, 100);

  frame:RegisterEvent("QUEST_ACCEPTED");
  frame:RegisterEvent("QUEST_TURNED_IN");
  frame:RegisterEvent("QUEST_PROGRESS");
  frame:RegisterEvent("QUEST_COMPLETE");
  frame:RegisterEvent("QUEST_WATCH_UPDATE");
  frame:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
  frame:RegisterEvent("NAME_PLATE_UNIT_ADDED");
  frame:RegisterEvent("CHAT_MSG_MONSTER_SAY");

  local previous = CreateButton("<-", frame);
	previous:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -32, 15);
  
  local next = CreateButton("->", frame);
	next:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -5, 15);
  
  WowCyborg_guideHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  WowCyborg_guideHeader:SetPoint("LEFT", frame, "LEFT", 8, 30);
  WowCyborg_guideHeader:SetTextColor(1, 1, 0);

  WowCyborg_guideDescription = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  WowCyborg_guideDescription:SetPoint("LEFT", frame, "LEFT", 8, 15);
  WowCyborg_guideDescription:SetTextColor(1, 1, 1);

  frame:SetScript("OnEvent", function(self, event, ...)
    local step = steps[WowCyborg_Step];
    if step == nil then
      return;
    end

    local target = UnitName("target");
    if event ~= "NAME_PLATE_UNIT_ADDED" then
      print(...);
    end

    if (event == "NAME_PLATE_UNIT_ADDED" and step.target) then
      local unitID = ...;
      local name = UnitName(unitID);
      if name == step.target then
        SetRaidTarget(unitID, 8);
      end
    end

    if (event == "QUEST_WATCH_UPDATE") then
      local questId = ...
      print(questId);
      if step.completeEvent == event and ((target and step.target == target) or step.questId == questId) then
        NextStep();
        return;
      end
    end

    if (event == "QUEST_ACCEPTED") then
      local questId = ...
      if step.completeEvent == event and step.questId and step.questId == questId then
        NextStep();
        return;
      end
    end

    if event == "QUEST_TURNED_IN" then
      local questId = ...
      if step.completeEvent == event and step.questId and step.questId == questId then
        NextStep();
        return;
      end
    end

    if event == "CHAT_MSG_MONSTER_SAY" then
      if step.npcMessage then
        local textFound = string.find(message, step.npcMessage);
        if textFound then
          NextStep();
          return;
        end
      end
    end
    
    if step.target and step.completeEvent == event and step.target == target then
      NextStep();
      return;
    end
  end);

  previous:SetScript("OnClick", function(self, event)
    PreviousStep();
  end)
    
  next:SetScript("OnClick", function(self, event)
    NextStep();
  end)

  setTimer(2, function()
    local step = steps[WowCyborg_Step];
    RenderStep(step);
  end);
end

function PreviousStep()
  WowCyborg_Step = WowCyborg_Step - 1;
  local step = steps[WowCyborg_Step];
  if step == nil then
    WowCyborg_Step = 0;
    return;
  end
  RenderStep(step);
end

function NextStep()
  WowCyborg_Step = WowCyborg_Step + 1;
  local step = steps[WowCyborg_Step];
  if step == nil then
    WowCyborg_Step = WowCyborg_Step - 1;
    return;
  end

  if (step.description == 'Board ship to Dragon Isles...') then
    print("Remember:");
    print("Judgment to put in dragonflight bar");
    print("Sea Ray ready");
    print("Stand on the far front of Zeppelin");
  end

  RenderStep(step);
end

local update = CreateFrame("FRAME");
update:SetScript("OnUpdate", function()
  HandleSpeak();
end);

RenderGuideFrame();