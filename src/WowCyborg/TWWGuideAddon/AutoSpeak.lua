
print ("Loading Autospeak...");

function CreateOption(npc, text, index)
  local option = {}
  option.npc = npc;
  option.text = text;
  option.index = index;
  return option;
end

optionsToSelect = {};
table.insert(optionsToSelect, CreateOption("Ebyssian", "A great journey", 1));

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
      print("Selecting Quest option");
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

-- Quick quest

local qqFrame = CreateFrame("FRAME");
qqFrame:RegisterEvent("QUEST_COMPLETE");
qqFrame:RegisterEvent("QUEST_DETAIL");
qqFrame:RegisterEvent("QUEST_PROGRESS");
qqFrame:RegisterEvent("GOSSIP_SHOW");
qqFrame:RegisterEvent("GOSSIP_CONFIRM");
qqFrame:RegisterEvent("QUEST_GREETING");
qqFrame:RegisterEvent("QUEST_LOG_UPDATE");
qqFrame:RegisterEvent("QUEST_ACCEPT_CONFIRM");

qqFrame:SetScript("OnEvent", function(self, event, ...)
  if (event == "QUEST_GREETING") then
    for index = 1, GetNumActiveQuests() do
      local _, isComplete = GetActiveTitle(index)
      if isComplete and not C_QuestLog.IsWorldQuest(GetActiveQuestID(index)) then
        SelectActiveQuest(index)
      end
		end

		for index = 1, GetNumAvailableQuests() do
        SelectAvailableQuest(index)
		end
  end

  if (event == "GOSSIP_SHOW") then
    for index, info in next, C_GossipInfo.GetActiveQuests() do
      for _, step in ipairs(steps) do
        if (step.questId == info.questID) then
					C_GossipInfo.SelectActiveQuest(index);
          break;
        end
      end;
		end

    for index, info in next, C_GossipInfo.GetAvailableQuests() do
      for _, step in ipairs(steps) do
        if (step.questId == info.questID) then
					C_GossipInfo.SelectAvailableQuest(index)
          break;
        end
      end;
		end
  end

  if (event == "QUEST_DETAIL") then
    local id = GetQuestID();
    for _, step in ipairs(steps) do
      if (step.questId == id) then
        AcceptQuest();
        break;
      end
    end;
  end

  if (event == "QUEST_PROGRESS") then
    if not IsQuestCompletable() then
      return
    end

    CompleteQuest()
  end

  if (event == "QUEST_COMPLETE") then
    local numItemRewards = GetNumQuestChoices();
    if GetNumQuestChoices() <= 1 then
			GetQuestReward(1);
      return;
		end

    local highestItemValue, highestItemValueIndex = 0

    for index = 1, numItemRewards do
      local itemLink = GetQuestItemLink('choice', index)
      if itemLink then
        local _, _, _, _, _, _, _, _, _, _, itemValue = GetItemInfo(itemLink)
        local itemID = GetItemInfoFromHyperlink(itemLink)
        if itemValue > highestItemValue then
          highestItemValue = itemValue
          highestItemValueIndex = index
        end
      else
        GetQuestItemInfo('choice', index)
        return
      end
    end

    if highestItemValueIndex then
      QuestInfoItem_OnClick(QuestInfoRewardsFrame.RewardButtons[highestItemValueIndex])
    end
  end
end);

CinematicFrame:HookScript("OnShow", function(self, ...)
  CinematicFrame_CancelCinematic();
end);
