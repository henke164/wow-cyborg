WowCyborg_Paste = "";
WowCyborg_guideHeader = nil;
WowCyborg_guideDescription = nil;
WowCyborg_Step = 1;
WowCyborg_lastUpdatedQuest = 0;
WowCyborg_CompletedSteps = {};
WowCyborg_Countdown = 0;

-- Dragonflight auto quest
print ("Loading Dragonflight guide...");

function ResetGuide()
  WowCyborg_Step = 1;
  WowCyborg_CompletedSteps = {};
end

function IsCompleted(step)
  for _, completedStep in ipairs(WowCyborg_CompletedSteps) do
    if (completedStep.event == step.completeEvent and step.questId and completedStep.questId == step.questId) then
      return true;
    end
  end;
  return false;
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
  local header = WowCyborg_Step .. ". ";
  if (step and step.target) then
    header = header .. step.target;
  end

  if (step and step.questId) then
    header = header .. " (" .. step.questId .. ")";
  end

  WowCyborg_guideHeader:SetText(header);
  WowCyborg_guideDescription:SetText(step.description);
  if TomTom ~= nil then
    TomTom.db.profile.general.confirmremoveall = false;
    SlashCmdList["TOMTOM_WAY"]("reset all");
    SlashCmdList["TOMTOM_WAY"](step.zone .. " " .. step.x .. " " .. step.y .. " " .. step.description);
  end

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

local skullOnGUID = "";
function RenderGuideFrame()
  local frame = CreateDFGuideFrame(50, 300, 250, 100);

  frame:RegisterEvent("QUEST_ACCEPTED");
  frame:RegisterEvent("QUEST_TURNED_IN");
  frame:RegisterEvent("QUEST_PROGRESS");
  frame:RegisterEvent("QUEST_COMPLETE");
  frame:RegisterEvent("QUEST_WATCH_UPDATE");
  frame:RegisterEvent("NAME_PLATE_UNIT_ADDED");
  frame:RegisterEvent("CHAT_MSG_MONSTER_SAY");

  local previous = CreateButton("<-", frame);
	previous:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -32, 15);
  
  local next = CreateButton("->", frame);
	next:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -5, 15);

  WowCyborg_XPPerHour = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  WowCyborg_XPPerHour:SetPoint("LEFT", frame, "BOTTOMLEFT", 8, 15);
  WowCyborg_XPPerHour:SetTextColor(1, 1, 0);
  WowCyborg_XPPerHour:SetText("XP/Hour: 0");

  WowCyborg_guideHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  WowCyborg_guideHeader:SetPoint("LEFT", frame, "LEFT", 8, 30);
  WowCyborg_guideHeader:SetTextColor(0, 1, 0);

  WowCyborg_guideDescription = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  WowCyborg_guideDescription:SetPoint("LEFT", frame, "LEFT", 8, 15);
  WowCyborg_guideDescription:SetTextColor(1, 1, 1);

  frame:SetScript("OnEvent", function(self, event, ...)
    local step = steps[WowCyborg_Step];
    if step == nil then
      return;
    end

    local target = UnitName("target");
    if (event == "NAME_PLATE_UNIT_ADDED" and step.target) then
      local unitID = ...;
      local name = UnitName(unitID);
      if name == step.target then
        local guid = UnitGUID(unitID);
        if skullOnGUID ~= guid then
          skullOnGUID = guid;
          SetRaidTarget(unitID, 8);
        end
      end
    end

    if (event == "QUEST_WATCH_UPDATE") then
      local questId = ...
      local uncompleted = 0;
      WowCyborg_lastUpdatedQuest = questId;

      for q = 1, 10 do
        local text, _, fulfilled = GetQuestObjectiveInfo(questId, q, false);
        if fulfilled == false then
          uncompleted = uncompleted + 1;
        end
      end

      local completedQuest = uncompleted <= 1;

      if step.completeEvent == "COMPLETED" and completedQuest and step.questId == questId then
        NextStep();
        return;
      end

      if step.completeEvent == event and ((target and step.target == target) or step.questId == questId) then
        NextStep();
        return;
      end

      local completedStep = {};
      completedStep.event = "QUEST_WATCH_UPDATE";
      completedStep.questId = questId;
      table.insert(WowCyborg_CompletedSteps, completedStep);
      
      if (completedQuest) then
        local completedStep = {};
        completedStep.event = "COMPLETED";
        completedStep.questId = questId;
        table.insert(WowCyborg_CompletedSteps, completedStep);
      end
    end

    if (event == "QUEST_ACCEPTED") then
      local questId = ...
      WowCyborg_lastUpdatedQuest = questId;
      if step.completeEvent == event and step.questId and step.questId == questId then
        NextStep();
        return;
      end

      local completedStep = {};
      completedStep.event = "QUEST_ACCEPTED";
      completedStep.questId = questId;
      table.insert(WowCyborg_CompletedSteps, completedStep);
    end

    if event == "QUEST_TURNED_IN" then
      local questId = ...
      WowCyborg_lastUpdatedQuest = questId;
      if step.completeEvent == event and step.questId and step.questId == questId then
        NextStep();
        return;
      end

      local completedStep = {};
      completedStep.event = "QUEST_TURNED_IN";
      completedStep.questId = questId;
      table.insert(WowCyborg_CompletedSteps, completedStep);
    end

    if event == "CHAT_MSG_MONSTER_SAY" then
      if step.npcMessage then
        local message = ...
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
    NextStep(true);
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

function NextStep(skipAutoSkipCompletedQuests)
  WowCyborg_Step = WowCyborg_Step + 1;
  local step = steps[WowCyborg_Step];
  if step == nil then
    WowCyborg_Step = WowCyborg_Step - 1;
    return;
  end

  if (skipAutoSkipCompletedQuests ~= true and IsCompleted(steps[WowCyborg_Step])) then
    return NextStep(skipAutoSkipCompletedQuests);
  end

  if (step.description == 'Board ship to Dragon Isles...') then
    print("-----------------");
    print("Remember:");
    print("Judgment to put in dragonflight bar");
    print("PVP-MODE");
    print("-----------------");
  end

  RenderStep(step);
end

local update = CreateFrame("FRAME");
update:SetScript("OnUpdate", function()
  HandleSpeak();
end);

RenderGuideFrame();
