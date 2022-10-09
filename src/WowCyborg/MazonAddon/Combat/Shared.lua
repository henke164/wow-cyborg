WowCyborg_AOE_Rotation = false;
WowCyborg_CLASSIC = true;
WowCyborg_CURRENTATTACK = "-";
WowCyborg_DISABLED = false;
WowCyborg_PAUSE = false;
WowCyborg_PAUSE_UNTIL = 0;

if WowCyborg_PAUSE_KEYS == nil then
  WowCyborg_PAUSE_KEYS = {}
end

local spellButtonTexture;
local buttonCombinerTexture;
local letterToggleTexture;

function CreateDefaultFrame(x, y, width, height)
  local frame = CreateFrame("Frame");
  frame:ClearAllPoints();
  frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y);
  frame:SetWidth(width);
  frame:SetHeight(height);
  local texture = frame:CreateTexture("WhiteTexture", "ARTWORK");
  texture:SetWidth(width);
  texture:SetHeight(height);
  texture:ClearAllPoints();
  texture:SetColorTexture(0, 0, 0);
  texture:SetAllPoints(frame);
  return frame, texture;
end

function CreateRotationFrame()
  _, letterToggleTexture = CreateDefaultFrame(frameSize, frameSize, frameSize, frameSize);
  frame, spellButtonTexture = CreateDefaultFrame(frameSize * 2, frameSize, frameSize, frameSize);
  _, buttonCombinerTexture = CreateDefaultFrame(frameSize * 3, frameSize, frameSize, frameSize);
  
  frame:EnableKeyboard(true);
  frame:SetPropagateKeyboardInput(true);

  frame:SetScript("OnUpdate", function(self, event, ...)
    if WowCyborg_DISABLED == true then
      WowCyborg_CURRENTATTACK = "-";
      return SetSpellRequest(nil);
    end

    PreventAzeriteBeamAbortion();
    HandleSpeak();

    if WowCyborg_PAUSE_UNTIL > GetTime() then
      WowCyborg_CURRENTATTACK = "Paused";
      return SetSpellRequest(nil);
    end

    if WowCyborg_AOE_Rotation == true then
      RenderMultiTargetRotation();
    end
    if WowCyborg_AOE_Rotation == false then
      RenderSingleTargetRotation();
    end
  end)

  RenderFontFrame();
end

function SetSpellRequest(buttonCombination)
  if buttonCombination == nil then
    r, g, b = GetColorFromNumber(nil);
    buttonCombinerTexture:SetColorTexture(r, g, b);
    spellButtonTexture:SetColorTexture(r, g, b);
    return true
  end

  local b1, b2 = strsplit("+", buttonCombination);
  if b2 == nil then
    local letterNum1, letterNum2 = GetNumbersFromLetter(b1);
    if letterNum1 ~= nil and letterNum2 ~= nil then
      -- Alphabetic keypress
      letterToggleTexture:SetColorTexture(0, 1, 0);
      spellButtonTexture:SetColorTexture(GetColorFromNumber(letterNum1));
      buttonCombinerTexture:SetColorTexture(GetColorFromNumber(letterNum2));
      return true;
    end

    -- Numeric keypress
    letterToggleTexture:SetColorTexture(GetColorFromButton(nil));
    buttonCombinerTexture:SetColorTexture(GetColorFromButton(nil));
    spellButtonTexture:SetColorTexture(GetColorFromNumber(tonumber(b1)));
    return true
  end

  local letterNum1, letterNum2 = GetNumbersFromLetter(b2);
  if letterNum1 ~= nil and letterNum2 ~= nil then
    -- Alphabetic keypress
    letterToggleTexture:SetColorTexture(0, 1, 0);
    spellButtonTexture:SetColorTexture(GetColorFromNumber(letterNum1));
    buttonCombinerTexture:SetColorTexture(GetColorFromNumber(letterNum2));
    return true;
  end

  -- Numeric keypress
  letterToggleTexture:SetColorTexture(GetColorFromButton(nil));
  buttonCombinerTexture:SetColorTexture(GetColorFromButton(b1));
  spellButtonTexture:SetColorTexture(GetColorFromNumber(tonumber(b2)));
  return true
end

function IsMoving()
  local currentSpeed = GetUnitSpeed("player");
  return currentSpeed > 0;
end

function FindBuff(target, buffName)
  for i=1,40 do
    local name, icon, stacks, _, __, etime = UnitBuff(target, i);
    if name ~= nil and buffName ~= nil and string.lower(name) == string.lower(buffName) then
      local time = GetTime();
      return name, etime - time, stacks, i, icon;
    end
  end
end

function FindUnitBuff(target, buffName)
  for i=1,40 do
    local name = UnitBuff(target, i);
    if name ~= nil and buffName ~= nil and string.lower(name) == string.lower(buffName) then
      return UnitBuff(target, i);
    end
  end
end

function FindDebuff(target, buffName)
  for i=1,40 do
    local name, _, stack, _, _, etime, castBy = UnitDebuff(target, i);
    if name ~= nil and string.lower(name) == string.lower(buffName) and castBy == "player" then
      local time = GetTime();
      return name, etime - time, stack;
    end
  end
end

function IsCastable(spellName, requiredEnergy)
  local usable, known = IsUsableSpell(spellName);
  if (usable == false and known == false) then
    return false;
  end

  local energy = UnitPower("player");

  if energy < requiredEnergy then
    return false;
  end

  local totalCd = GetCooldown(spellName);

  if totalCd < GetCurrentSpellGCD(spellName) then
    return true;
  end
  
  local charges = GetSpellCharges(spellName);
  if (charges == nil) == false then
    if charges > 0 then
      return true;
    end
  end
  
  return false;
end

function IsCastableAtFriendlyUnit(unitName, spellName, requiredEnergy)
  if IsSpellInRange(spellName, unitName) == 0 then
    return false;
  end

  if UnitCanAttack("player", unitName) == true then
    return false;
  end

  if IsAlive(unitName) == false then
    return false;
  end;
  
  return IsCastable(spellName, requiredEnergy);
end

function IsCastableAtFriendlyTarget(spellName, requiredEnergy)
  return IsCastableAtFriendlyUnit("target", spellName, requiredEnergy);
end

function IsCastableAtEnemyTarget(spellName, requiredEnergy)
  if IsSpellInRange(spellName, "target") == 0 then
    return false;
  end
  
  if UnitCanAttack("player", "target") == false then
    return false;
  end

  if TargetIsAlive() == false then
    return false;
  end;

  return IsCastable(spellName, requiredEnergy);
end

function IsCastableAtEnemyFocus(spellName, requiredEnergy)
  if IsSpellInRange(spellName, "focus") == 0 then
    return false;
  end
  
  if UnitCanAttack("player", "focus") == false then
    return false;
  end

  if IsAlive("focus") == false then
    return false;
  end;

  return IsCastable(spellName, requiredEnergy);
end

function GetHealthPercentage(unit)
  local maxHp = UnitHealthMax(unit);
  local hp = UnitHealth(unit);

  if maxHp == 0 or hp == 0 then
    return 0;
  end

  return (hp / maxHp) * 100;
end

function TargetIsAlive()
  hp = UnitHealth("target");
  return hp > 0;
end

function IsAlive(unit)
  hp = UnitHealth(unit);
  return hp > 0;
end

function Pause(secondsAfterGcd)
  local cdUntil = GetSpellCooldown(61304);
  local globalTl = 1 - (GetTime() - cdUntil);
  if globalTl > 1.5 or globalTl < 0 then
    globalTl = 0;
  end

  WowCyborg_PAUSE_UNTIL = GetTime() + globalTl + secondsAfterGcd;
end

function RenderFontFrame()
  local fontFrame, fontTexture = CreateDefaultFrame(frameSize * 5, frameSize * 5, 100, 20);
  fontFrame:SetMovable(true)
  fontFrame:EnableMouse(true)
  fontFrame:RegisterForDrag("LeftButton")
  fontFrame:SetScript("OnDragStart", fontFrame.StartMoving)
  fontFrame:SetScript("OnDragStop", fontFrame.StopMovingOrSizing)

  local str = fontFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
  str:SetPoint("CENTER");
  str:SetTextColor(1, 1, 1);

  local infoStr = fontFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  infoStr:SetPoint("CENTER", fontFrame, "CENTER", 0, -20);
  infoStr:SetTextColor(1, 1, 1);
  
  fontFrame:SetPropagateKeyboardInput(true);

  fontFrame:SetScript("OnKeyDown", function(self, key)
    if key == "CAPSLOCK" then
      if IsShiftKeyDown() then
        WowCyborg_DISABLED = WowCyborg_DISABLED == false;
      elseif WowCyborg_DISABLED == true then
        WowCyborg_DISABLED = false;
      else
        WowCyborg_AOE_Rotation = not WowCyborg_AOE_Rotation;
      end
    end

    for index, value in ipairs(WowCyborg_PAUSE_KEYS) do
      if value == key then
        Pause(0.3);
      end
    end
  end)
  
  local middleButtonReleased = true;
  fontFrame:SetScript("OnUpdate", function(self, event, ...)
    
    if middleButtonReleased and IsMouseButtonDown("MiddleButton") then
      WowCyborg_DISABLED = WowCyborg_DISABLED == false;
      middleButtonReleased = false;
    end

    if IsMouseButtonDown("MiddleButton") == false then
      middleButtonReleased = true;
    end

    if WowCyborg_DISABLED == true then
      fontTexture:SetColorTexture(1, 1, 0);
      str:SetText("Disabled");
      infoStr:SetText(WowCyborg_CURRENTATTACK);
    else
      if WowCyborg_AOE_Rotation == true then
        fontTexture:SetColorTexture(1, 0, 0);
        str:SetText("Multi target");
        infoStr:SetText(WowCyborg_CURRENTATTACK);
      end
      
      if WowCyborg_AOE_Rotation == false then
        fontTexture:SetColorTexture(0, 0, 1);
        str:SetText("Single target");
        infoStr:SetText(WowCyborg_CURRENTATTACK);
      end
    end
  end)
end

function TalentEnabled(talentName)
  return true
end

function GetCooldownDuration(spellName) 
  local start, duration = GetSpellCooldown(spellName)
  if start == nil then
    return 999
  end

  return duration
end

function GetCooldown(spellName)
  local start, duration = GetSpellCooldown(spellName)
  if start == nil then
    return 999
  end

  return start + duration - GetTime()
end

function GetFullRechargeTime(spellName)
  local current, max, start, cd = GetSpellCharges(spellName)
  if current == nil then
    return 999
  end

  local rechargeTime = 0
  if max == current then
    rechargeTime = 0
  elseif max - current == 1 then
    rechargeTime = (start + cd) - GetTime()
  else
    rechargeTime = ((max - current - 1) * cd) + (start + cd) - GetTime()
  end

  return rechargeTime
end

function GetCurrentCost(spellName)
  local spellCost = GetSpellPowerCost(spellName)[1]
  if spellCost == nil then
    return 0
  end

  return spellCost.cost
end

function GetTimeToMax()
  local max = UnitPowerMax("player")
  local current = UnitPower("player")
  local regen = GetPowerRegen()
  return (max - current) / regen
end

function GetBuffTimeLeft(who, buffName)
  local buff, buffTime = FindBuff(who, buffName)
  if buff == nil then
    return 0
  end

  return buffTime
end

function GetDebuffTimeLeft(who, debuffName)
  local debuff, debuffTime = FindDebuff(who, debuffName)
  if debuff == nil then
    return 0
  end

  return debuffTime
end

function GetBuffStacks(buffName)
  local _, __, stacks = FindBuff("player", buffName);
  if stacks == nil then
    return 0
  end
  return stacks
end

function GetActiveEnemies() 
  local inRange = 0
  for i = 1, 40 do
    if UnitExists('nameplate' .. i) and CheckInteractDistance("nameplate"..i, 1) == true and UnitCanAttack("player", 'nameplate' .. i) then
      inRange = inRange + 1
    end
  end
  return inRange;
end

local delay = 0.5
function GetCurrentSpellGCD(spellName)
  if UnitSpellHaste == nil then
    return 1.5;
  end

  local spellHastePercent = UnitSpellHaste("player")
  local _, gcd = GetSpellBaseCooldown(spellName)
  if gcd == nil then
    gcd = 1.5
  else
    gcd = gcd / 1000
  end
  return (gcd - ((gcd / 2) * (spellHastePercent * 0.01))) - delay;
end

function GetGCDMax()
  if UnitSpellHaste == nil then
    return 1.5;
  end

  local spellHastePercent = UnitSpellHaste("player")
  return (0.75 * (spellHastePercent * 0.01)) - delay;
end

function PreventAzeriteBeamAbortion()
  local castingInfo, _, __, ___, castingEndTime = UnitCastingInfo("player");
  if castingInfo == "Focused Azerite Beam" then
    local finish = castingEndTime / 1000 - GetTime();
    WowCyborg_PAUSE_UNTIL = GetTime() + (finish + 1);
  end

  local channelInfo, c_, c__, c___, channelEndTime = UnitChannelInfo("player");
  if channelInfo == "Focused Azerite Beam" then
    local finish = channelEndTime / 1000 - GetTime();
    WowCyborg_PAUSE_UNTIL = GetTime() + (finish + 0.5);
  end
end

function GetNearbyEnemyCount(interactDistance)
  if interactDistance == nil then
    interactDistance = 3;
  end

  local count = 0;

  for i = 1, 40 do 
    local guid = UnitGUID("nameplate"..i) 
    if guid then 
      if CheckInteractDistance("nameplate"..i, interactDistance) then
        if UnitCanAttack("player", "nameplate"..i) == true then
          count = count + 1;
        end
      end
    end
  end

  return count;
end

-- Dragonflight auto quest
print ("Loading dragon flight autoquest...");
function CreateOption(npc, text, index)
  local option = {}
  option.npc = npc;
  option.text = text;
  option.index = index;
  return option;
end

local optionsToSelect = {};
-- options here

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

function SellItems(color)
  print("Selling items");
  for b = 0, 6 do
    for s = 1, C_Container.GetContainerNumSlots(b) do 
      local item = C_Container.GetContainerItemLink(b, s);
      if item and string.find(item, color) then
        print("Selling b:" .. b .. "s:" .. s);
        C_Container.UseContainerItem(b,s);
      end
    end
  end
end

function SellGrayItems()
  SellItems("cFF9D9D9D");
end

function SellGreenItems()
  SellItems("cFF1EFF00");
end

-- TOMTOM
local paste = "";
local steps = {};
WowCyborg_guideHeader = nil;
WowCyborg_guideDescription = nil;

WowCyborg_Step = 1;

local timer = CreateFrame("FRAME");
local function setTimer(duration, func)
	local endTime = GetTime() + duration;
	timer:SetScript("OnUpdate", function()
		if(endTime < GetTime()) then
      print("Times up");
			--time is up
			func();
			timer:SetScript("OnUpdate", nil);
		end
	end);
end

function CreateButton(text, parent, width)
	local button = CreateFrame("Button", nil, parent)
	button:SetWidth(25)
	button:SetHeight(25)
	
  if width then
    button:SetWidth(width)
  end
  
	button:SetText(text)
	button:SetNormalFontObject("GameFontNormal")
	
	local ntex = button:CreateTexture()
	ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	ntex:SetAllPoints()	
	button:SetNormalTexture(ntex)
	
	local htex = button:CreateTexture()
	htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	htex:SetTexCoord(0, 0.625, 0, 0.6875)
	htex:SetAllPoints()
	button:SetHighlightTexture(htex)
	
	local ptex = button:CreateTexture()
	ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	ptex:SetAllPoints()
	button:SetPushedTexture(ptex)
  return button;
end

function PrintScript(type, description)
  local zone = GetZoneText();
  local target = UnitName("target");
  local x, y = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY();
  local str = "table.insert(steps, CreateStep(" ..
    math.ceil(x * 10000) / 100 ..
    ", " ..
    math.ceil(y * 10000) / 100 ..
  ", \"" .. zone .. "\", ";

  if target == nil then
    str = str .. "nil"
  else
    str = str .. "\"".. target .. "\""
  end

  str = str .. ", \"" .. description .. "\", \"" .. type .. "\"));";

  paste = paste .. "\r\n" .. str;
  KethoEditBox_Show(paste);
end

function RenderGuideFrame()
  local fontFrame, fontTexture = CreateDefaultFrame(0, 0, 250, 75);
  fontFrame:SetMovable(true)
  fontFrame:EnableMouse(true)
  fontFrame:RegisterForDrag("LeftButton")
  fontFrame:SetScript("OnDragStart", fontFrame.StartMoving)
  fontFrame:SetScript("OnDragStop", fontFrame.StopMovingOrSizing)

  fontFrame:RegisterEvent("QUEST_ACCEPTED");
  fontFrame:RegisterEvent("QUEST_TURNED_IN");
  fontFrame:RegisterEvent("QUEST_PROGRESS");
  fontFrame:RegisterEvent("QUEST_COMPLETE");
  fontFrame:RegisterEvent("QUEST_WATCH_UPDATE");
  fontFrame:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
  fontFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED");
  fontFrame:RegisterEvent("CHAT_MSG_MONSTER_SAY");

  local previous = CreateButton("<-", fontFrame);
	previous:SetPoint("RIGHT", fontFrame, "BOTTOMRIGHT", -25, -25);
  
  local next = CreateButton("->", fontFrame);
	next:SetPoint("RIGHT", fontFrame, "BOTTOMRIGHT", 0, -25);
  
  WowCyborg_guideHeader = fontFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  WowCyborg_guideHeader:SetPoint("CENTER", fontFrame, "CENTER", 0, 5);
  WowCyborg_guideHeader:SetTextColor(1, 1, 1);

  WowCyborg_guideDescription = fontFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  WowCyborg_guideDescription:SetPoint("CENTER", fontFrame, "CENTER", 0, -5);
  WowCyborg_guideDescription:SetTextColor(1, 1, 1);

  fontFrame:SetScript("OnEvent", function(self, event, ...)
    local step = steps[WowCyborg_Step];
    if step == nil then
      return;
    end

    local target = UnitName("target");
    if event ~= "NAME_PLATE_UNIT_ADDED" then
      print("Key:" .. event);
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
        local message = ...
        print(message);
        print(step.npcMessage);
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

  
  local c1 = CreateButton("Acc", fontFrame, 25);
	c1:SetPoint("RIGHT", fontFrame, "BOTTOMRIGHT", -50, -25);
  c1:SetScript("OnClick", function(self, event)
    PrintScript("QUEST_ACCEPTED", "Accept quest");
  end)
  
  local c2 = CreateButton("Tur", fontFrame, 25);
	c2:SetPoint("RIGHT", fontFrame, "BOTTOMRIGHT", -75, -25);
  c2:SetScript("OnClick", function(self, event)
    PrintScript("QUEST_TURNED_IN", "Turn in quest");
  end)
  
  local c3 = CreateButton("Upd", fontFrame, 25);
	c3:SetPoint("RIGHT", fontFrame, "BOTTOMRIGHT", -100, -25);
  c3:SetScript("OnClick", function(self, event)
    PrintScript("QUEST_WATCH_UPDATE", "Talk");
  end)

  setTimer(5, function()
    local step = steps[WowCyborg_Step];
    RenderStep(step);
    print ("Dragon flight autoquest loaded!");
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


table.insert(optionsToSelect, CreateOption("Ebyssian", "A great journey", 1));
table.insert(optionsToSelect, CreateOption("Pathfinder Tacha", "interested in", 1));
table.insert(optionsToSelect, CreateOption("Cataloger Coralie", "new discovery", 1));
table.insert(optionsToSelect, CreateOption("Boss Magor", "buy something", 1));
table.insert(optionsToSelect, CreateOption("Kodethi", "Welcome", 1));
table.insert(optionsToSelect, CreateOption("Archmage Khadgar", "We have much to discuss", 1));
table.insert(optionsToSelect, CreateOption(nil, "Each page is filled with an elegant,", 1));
table.insert(optionsToSelect, CreateOption(nil, "<The first column asks for your name.>", 1));
table.insert(optionsToSelect, CreateOption(nil, "<The middle column asks for", 3));
table.insert(optionsToSelect, CreateOption(nil, "<The final column asks for", 4));
table.insert(optionsToSelect, CreateOption("Sendrax", "A single egg remains.", 1));
table.insert(optionsToSelect, CreateOption("Alexstrasza the Life-Binder", "The Ruby Lifeshrine", 1));
table.insert(optionsToSelect, CreateOption("Gurgthock", "rumble", 1));
table.insert(optionsToSelect, CreateOption(nil, "It is an honor to serve", 1));
table.insert(optionsToSelect, CreateOption("Talonstalker Kavia", "occupying", 1));
table.insert(optionsToSelect, CreateOption("Archivist Edress", "history of the", 1));
table.insert(optionsToSelect, CreateOption("Forgemaster Bazentus", "mortal", 1));
table.insert(optionsToSelect, CreateOption("Wrathion", "grasp", 1));
table.insert(optionsToSelect, CreateOption("Wrathion", "secure this courtyard", 1));
table.insert(optionsToSelect, CreateOption("Left", "good fight", 1));
table.insert(optionsToSelect, CreateOption("Talonstalker Kavia", "new ways", 1));
table.insert(optionsToSelect, CreateOption("Archivist Edress", "books, scrolls, hours", 1));
table.insert(optionsToSelect, CreateOption("Baskilan", "Well met", 1));
table.insert(optionsToSelect, CreateOption("Forgemaster Bazentus", "begin building", 1));
table.insert(optionsToSelect, CreateOption("Sabellian", "Are you ready to depart", 1));
table.insert(optionsToSelect, CreateOption("Aru", "Hunting is about", 1));
table.insert(optionsToSelect, CreateOption("Beastmaster Nuqut", "I tend to our beasts", 1));
table.insert(optionsToSelect, CreateOption("Ohn Seshteng", "your arrival", 1));
table.insert(optionsToSelect, CreateOption("Scout Tomul", "to keep up", 1));
table.insert(optionsToSelect, CreateOption("Ohn Seshteng", "aid in the ritual", 2));
table.insert(optionsToSelect, CreateOption("Elder Odgerel", "Clan Teerai", 1));
table.insert(optionsToSelect, CreateOption("Ohn Arasara", "Stay true", 1));
table.insert(optionsToSelect, CreateOption("Provisioner Zara", "seeks a hearth.", 1));
table.insert(optionsToSelect, CreateOption("Sansok Khan", "Do you feel prepared", 1));
table.insert(optionsToSelect, CreateOption("Sansok Khan", "traditions and guides", 4));
table.insert(optionsToSelect, CreateOption("Sansok Khan", "honed a special connection", 1));
table.insert(optionsToSelect, CreateOption("Sansok Khan", "military force", 2));
table.insert(optionsToSelect, CreateOption("Sansok Khan", "hunting game", 1));
table.insert(optionsToSelect, CreateOption("Matchmaker Osila", "Zandalari", 1));
table.insert(optionsToSelect, CreateOption("Hunter Narman", "small pond", 1));
table.insert(optionsToSelect, CreateOption("Khansguard Akato", "Khanam", 1));
table.insert(optionsToSelect, CreateOption("Scout Khenyug", "What do you want", 1));
table.insert(optionsToSelect, CreateOption("Herbalist Agura", "A handful", 1));
table.insert(optionsToSelect, CreateOption("Khansguard Hojin", "Are you lost", 1));
table.insert(optionsToSelect, CreateOption("Quartermaster Gensai", "How can I help you", 1));
table.insert(optionsToSelect, CreateOption("Boku's Belongings", "There are more", 1));
table.insert(optionsToSelect, CreateOption("Unidentified Centaur", "This is not Boku", 1));
table.insert(optionsToSelect, CreateOption("Khanam Matra Sarest", "Have you rallied my forces?", 1));
table.insert(optionsToSelect, CreateOption("Khanam Matra Sarest", "The Horn of Drusahl is one", 1));
table.insert(optionsToSelect, CreateOption("Khanam Matra Sarest", "But first", 1));
table.insert(optionsToSelect, CreateOption("Gerithus", "My mother is kind", 1));
table.insert(optionsToSelect, CreateOption("Sariosa", "Greetings! Oh my", 1));
table.insert(optionsToSelect, CreateOption("Sidra the Mender", "The Primalists", 1));
table.insert(optionsToSelect, CreateOption("Guard-Captain Alowen", "The Primalists", 1));
table.insert(optionsToSelect, CreateOption("Aronus", "Care for a lift?", 1));
table.insert(optionsToSelect, CreateOption("Viranikus", "The Primalists", 1));

function CreateStep(x, y, zone, target, description, completeEvent, questId, npcMessage)
  local step = {};
  step.x = x;
  step.y = y;
  step.zone = zone;
  step.description = description;
  step.target = target;
  step.completeEvent = completeEvent;
  step.questId = questId;
  step.npcMessage = npcMessage;
  return step;
end

table.insert(steps, CreateStep(44.12, 38.05, "Orgrimmar", "Ebyssian", "Turn in and accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(44.12, 38.05, "Orgrimmar", "Ebyssian", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(44.12, 38.05, "Orgrimmar", "Naleidea Rivergleam", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(44.12, 38.05, "Orgrimmar", "Scalecommander Cindrethresh", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(38.60, 56.97, "Orgrimmar", "Pathfinder Tacha", "Talk", "UNIT_QUEST_LOG_CHANGED"));
table.insert(steps, CreateStep(71.41, 50.68, "Orgrimmar", "Cataloger Coralie", "Talk", "UNIT_QUEST_LOG_CHANGED"));
table.insert(steps, CreateStep(57.10, 54.11, "Orgrimmar", "Boss Magor", "Talk", "UNIT_QUEST_LOG_CHANGED"));
table.insert(steps, CreateStep(55.06, 89.60, "Orgrimmar", "Kodethi", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(55.86, 12.70, "Durotar", "Naleidea Rivergleam", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(55.86, 12.70, "Durotar", "Naleidea Rivergleam", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(55.86, 12.70, "Durotar", "Archmage Khadgar", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(55.86, 12.70, "Durotar", "Ebyssian", "Accept quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(55.86, 12.70, "Durotar", "Naleidea Rivergleam", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(55.06, 89.60, "Durotar", nil, "Board ship to Dragon Isles...", "QUEST_WATCH_UPDATE", 65444));
table.insert(steps, CreateStep(80.63, 27.67, "The Waking Shores", "Naleidea Rivergleam", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(80.63, 27.67, "The Waking Shores", "Naleidea Rivergleam", "Accept Quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(80.63, 27.67, "The Waking Shores", "Scalecommander Cindrethresh", "Accept Quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(80.63, 27.67, "The Waking Shores", "Boss Magor", "Accept Quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(80.32, 26.32, "The Waking Shores", "Protodragon Rib Cage", "Click on the Rib Cage. Kill and loot Dragons", "QUEST_WATCH_UPDATE", 65452));
table.insert(steps, CreateStep(78.80, 24.46, "The Waking Shores", "Archivist Spearblossom", "Rescue Spearblossom", "QUEST_WATCH_UPDATE", 65452));
table.insert(steps, CreateStep(77.49, 22.17, "The Waking Shores", "Ancient Hornswog", "Kill the frog", "QUEST_WATCH_UPDATE", 66076));
table.insert(steps, CreateStep(77.33, 29.88, "The Waking Shores", "Spelunker Lazee", "Rescue Spelunker", "QUEST_WATCH_UPDATE", 65452));
-- Wingrest Embrassy
table.insert(steps, CreateStep(76.63, 33.56, "The Waking Shores", "Naleidea Rivergleam", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(76.63, 33.56, "The Waking Shores", "Naleidea Rivergleam", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(76.29, 33.04, "The Waking Shores", "Scalecommander Cindrethresh", "Talk with Sendrax, then turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(75.96, 33.25, "The Waking Shores", "Boss Magor", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(76.63, 33.56, "The Waking Shores", "Sendrax", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(76.63, 33.56, "The Waking Shores", "Sendrax", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(76.31, 35.57, "The Waking Shores", "Ambassador Fastrasz", "Talk", "QUEST_WATCH_UPDATE", 69911));
table.insert(steps, CreateStep(76.31, 35.57, "The Waking Shores", nil, "Press the book", "QUEST_WATCH_UPDATE", 69911));
table.insert(steps, CreateStep(75.62, 34.16, "The Waking Shores", nil, "Press the Stone", "QUEST_WATCH_UPDATE", 69911));
table.insert(steps, CreateStep(78.39, 31.80, "The Waking Shores", nil, "Press the Brazier", "QUEST_WATCH_UPDATE", 69911));
table.insert(steps, CreateStep(76.63, 33.56, "The Waking Shores", "Sendrax", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(76.63, 33.56, "The Waking Shores", "Sendrax", "Accept quest", "UNIT_QUEST_LOG_CHANGED"));
table.insert(steps, CreateStep(76.63, 33.56, "The Waking Shores", "Sendrax", "Talk", nil, nil, "We were trained to only use these signal flares"));
table.insert(steps, CreateStep(76.36, 33.09, "The Waking Shores", "Warlord Breka Grimaxe", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(76.36, 33.09, "The Waking Shores", "Aster Cloudgaze", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(76.36, 33.09, "The Waking Shores", "Aster Cloudgaze", "Use the disk (1), jump off when it lands.", nil, nil, "Incredible! The elements"));
table.insert(steps, CreateStep(76.72, 34.55, "The Waking Shores", "Captain Garrick", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(76.27, 34.40, "The Waking Shores", "Sendrax", "Be near Sendrax", nil, nil, "Here they come!"));
table.insert(steps, CreateStep(76.36, 33.09, "The Waking Shores", "Aster Cloudgaze", "Use the disk (1), jump off when it lands.", nil, nil, "Incredible! The elements"));
table.insert(steps, CreateStep(76.36, 33.09, "The Waking Shores", "Aster Cloudgaze", "Complete and turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(76.19, 34.50, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(76.19, 34.50, "The Waking Shores", "Majordomo Selistra", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(76.63, 33.56, "The Waking Shores", "Majordomo Selistra", "Talk", nil, nil, "Cadet Sendrax, escort the"));
table.insert(steps, CreateStep(76.25, 34.40, "The Waking Shores", "Sendrax", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(76.25, 34.40, "The Waking Shores", "Sendrax", "Accept quest", "UNIT_QUEST_LOG_CHANGED"));
table.insert(steps, CreateStep(76.63, 33.56, "The Waking Shores", "Sendrax", "Talk", "QUEST_WATCH_UPDATE", 65760));
table.insert(steps, CreateStep(71.20, 40.76, "The Waking Shores", "Commander Lethanak", "Follow Sendrax", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(71.20, 40.76, "The Waking Shores", "Commander Lethanak", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(71.37, 44.59, "The Waking Shores", "Whimpering Whelpling", "Save Whelpling (Kill Djaradins)", "QUEST_WATCH_UPDATE", 65990));
table.insert(steps, CreateStep(71.00, 46.66, "The Waking Shores", "Whimpering Whelpling", "Save Whelpling (Kill Djaradins)", "QUEST_WATCH_UPDATE", 65990));
table.insert(steps, CreateStep(69.89, 45.28, "The Waking Shores", "Whimpering Whelpling", "Save Whelpling (Kill Djaradins)", "QUEST_WATCH_UPDATE", 65990));
table.insert(steps, CreateStep(69.37, 43.41, "The Waking Shores", "Whimpering Whelpling", "Save Whelpling (Kill Djaradins)", "QUEST_WATCH_UPDATE", 65990));
table.insert(steps, CreateStep(71.20, 40.76, "The Waking Shores", "Commander Lethanak", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(71.20, 40.76, "The Waking Shores", "Commander Lethanak", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(71.20, 40.76, "The Waking Shores", "Commander Lethanak", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(66.35, 34.92, "The Waking Shores", nil, "Run to Wrathion", "QUEST_WATCH_UPDATE", 65991));
table.insert(steps, CreateStep(66.35, 34.92, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(66.35, 34.92, "The Waking Shores", "Wrathion", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(66.35, 34.92, "The Waking Shores", "Wrathion", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(64.45, 33.16, "The Waking Shores", "Dragonhunter Igordan", "Kill", "QUEST_TURNED_IN", 66956));
table.insert(steps, CreateStep(62.95, 29.44, "The Waking Shores", "Meatgrinder Sotok", "Kill and get quest", "QUEST_ACCEPTED", 65995));
table.insert(steps, CreateStep(63.44, 28.87, "The Waking Shores", "Left", "Consult Left", "QUEST_WATCH_UPDATE", 65992));
table.insert(steps, CreateStep(65.10, 29.34, "The Waking Shores", "Right", "Consult Right", "QUEST_WATCH_UPDATE", 65992));
table.insert(steps, CreateStep(63.03, 33.34, "The Waking Shores", "Talonstalker Kavia", "Consult Talonstalker", "QUEST_WATCH_UPDATE", 65992));
table.insert(steps, CreateStep(62.68, 33.08, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.68, 33.08, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.68, 33.08, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.68, 33.08, "The Waking Shores", "Majordomo Selistra", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(61.04, 35.77, "The Waking Shores", "Injured Ruby Culler", "Injured Ruby Culler", "QUEST_WATCH_UPDATE", 65996));
table.insert(steps, CreateStep(61.11, 36.75, "The Waking Shores", "Injured Ruby Culler", "Injured Ruby Culler", "QUEST_WATCH_UPDATE", 65996));
table.insert(steps, CreateStep(59.05, 34.93, "The Waking Shores", "Injured Ruby Culler", "Injured Ruby Culler", "QUEST_WATCH_UPDATE", 65996));
table.insert(steps, CreateStep(59.05, 34.93, "The Waking Shores", "Caretaker Ventraz", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(58.43, 31.02, "The Waking Shores", nil, "Kill elementals", "QUEST_WATCH_UPDATE", 66988));
table.insert(steps, CreateStep(59.05, 34.93, "The Waking Shores", "Caretaker Ventraz", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(56.64, 37.74, "The Waking Shores", "Injured Ruby Culler", "Injured Ruby Culler", "QUEST_WATCH_UPDATE", 65996));
table.insert(steps, CreateStep(55.00, 30.80, "The Waking Shores", "Caretaker Azkra", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(55.00, 30.80, "The Waking Shores", "Caretaker Azkra", "Accept quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(55.15, 24.89, "The Waking Shores", "Sendrax", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(55.15, 24.89, "The Waking Shores", "Sendrax", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(55.15, 24.89, "The Waking Shores", nil, "Accept quest", "QUEST_ACCEPTED", 66000));
table.insert(steps, CreateStep(56.66, 24.79, "The Waking Shores", "Dragonhunter Igordan", "Kill", "QUEST_TURNED_IN", 70648));

table.insert(steps, CreateStep(56.16, 22.36, "The Waking Shores", "Sendrax", "Complete all quests and turn in", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(56.16, 22.36, "The Waking Shores", "Sendrax", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(56.16, 22.36, "The Waking Shores", "Sendrax", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(56.16, 22.36, "The Waking Shores", "Sendrax", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(56.16, 22.36, "The Waking Shores", "Sendrax", "Talk", "QUEST_WATCH_UPDATE"));

table.insert(steps, CreateStep(55.00, 30.69, "The Waking Shores", nil, "Grap and hand in egg", "QUEST_WATCH_UPDATE", 66001));
table.insert(steps, CreateStep(54.53, 30.84, "The Waking Shores", "Apprentice Caretaker Zefren", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(54.53, 30.84, "The Waking Shores", "Apprentice Caretaker Zefren", "Complete and Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(55.06, 30.99, "The Waking Shores", "Majordomo Selistra", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(55.06, 30.99, "The Waking Shores", "Majordomo Selistra", "Accept quest", "QUEST_ACCEPTED"));

-- Ruby Lifeshrine
table.insert(steps, CreateStep(62.26, 72.91, "The Waking Shores", "Alexstrasza the Life-Binder", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(62.26, 72.91, "The Waking Shores", "Alexstrasza the Life-Binder", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.26, 72.91, "The Waking Shores", "Alexstrasza the Life-Binder", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(62.26, 72.91, "The Waking Shores", "Alexstrasza the Life-Binder", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(60.70, 74.02, "The Waking Shores", "Xius", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(59.46, 72.47, "The Waking Shores", "Akxall", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(58.36, 67.19, "The Waking Shores", "Lord Andestrasz", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(57.69, 66.90, "The Waking Shores", "Lord Andestrasz", "Take Flight Path & Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(57.69, 66.90, "The Waking Shores", "Lord Andestrasz", "Complete dragonflying", "QUEST_ACCEPTED", 68796));
table.insert(steps, CreateStep(57.73, 66.76, "The Waking Shores", "Celormu", "Talk", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(75.12, 55.04, "The Waking Shores", "Lord Andestrasz", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(75.12, 55.04, "The Waking Shores", "Lord Andestrasz", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(74.11, 57.88, "The Waking Shores", "Glensera", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(74.11, 57.88, "The Waking Shores", nil, "Press the platform", "QUEST_WATCH_UPDATE", 68797));
table.insert(steps, CreateStep(75.12, 55.04, "The Waking Shores", "Lord Andestrasz", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(75.12, 55.04, "The Waking Shores", "Lord Andestrasz", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(74.54, 56.94, "The Waking Shores", "Lithragosa", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(74.54, 56.94, "The Waking Shores", "Lithragosa", "Open Dragonriding skill Track", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(73.24, 52.20, "The Waking Shores", "Celormu", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(75.12, 55.04, "The Waking Shores", "Lord Andestrasz", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(75.12, 55.04, "The Waking Shores", "Lord Andestrasz", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(61.57, 68.72, "The Waking Shores", "Mother Elion", "Fly back and Talk to Mother Elion", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(62.77, 70.44, "The Waking Shores", "Zahkrana", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(62.77, 70.44, "The Waking Shores", "Zahkrana", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.21, 70.57, "The Waking Shores", "Amella", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(61.09, 71.46, "The Waking Shores", "Ruby Whelpling", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(62.34, 72.76, "The Waking Shores", "Majordomo Selistra", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.36, 72.95, "The Waking Shores", "Alexstrasza the Life-Binder", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.34, 72.99, "The Waking Shores", "Alexstrasza the Life-Binder", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(59.49, 72.7, "The Waking Shores", "Majordomo Selistra", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(59.49, 72.7, "The Waking Shores", "Majordomo Selistra", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(59.43, 75.9, "The Waking Shores", "Commander Lethanak", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(59.43, 75.9, "The Waking Shores", "Commander Lethanak", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(57.79, 76.65, "The Waking Shores", "Enraged Cliff", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(59.76, 78.66, "The Waking Shores", "Enraged Cliff", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(61.04, 79.12, "The Waking Shores", "Enraged Cliff", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(60.91, 77.65, "The Waking Shores", "Enraged Cliff", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(59.39, 75.87, "The Waking Shores", "Commander Lethanak", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(59.39, 75.87, "The Waking Shores", "Commander Lethanak", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(59.47, 76.12, "The Waking Shores", "Majordomo Selistra", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(59.91, 75.95, "The Waking Shores", "Kildrumeh", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(57.34, 83.29, "The Waking Shores", nil, "Pick up egg", "QUEST_WATCH_UPDATE", 66121));
table.insert(steps, CreateStep(55.33, 83.29, "The Waking Shores", nil, "Pick up egg", "QUEST_WATCH_UPDATE", 66121));
table.insert(steps, CreateStep(54.8, 82.21, "The Waking Shores", "Klozicc the Ascended", "Kill", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(54.97, 80.97, "The Waking Shores", nil, "Pick up egg", "QUEST_TURNED_IN", 66121));
table.insert(steps, CreateStep(56.13, 81.27, "The Waking Shores", nil, "Pick up egg", "QUEST_WATCH_UPDATE", 66121));

table.insert(steps, CreateStep(53.73, 80.23, "The Waking Shores", "Majordomo Selistra", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(53.73, 80.23, "The Waking Shores", "Majordomo Selistra", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(53.73, 80.23, "The Waking Shores", "Majordomo Selistra", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(53.46, 83.03, "The Waking Shores", "Jadzigeth", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(53.73, 80.23, "The Waking Shores", "Majordomo Selistra", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(53.73, 80.23, "The Waking Shores", "Majordomo Selistra", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(45.96, 81.48, "The Waking Shores", "Iyali", "Take Flightpath and Accept Meat-thod quest", "QUEST_ACCEPTED", 69898));
table.insert(steps, CreateStep(47.42, 77.25, "The Waking Shores", "Pudgy Riverbeast", "Find Meat", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(46.2, 78.43, "The Waking Shores", "Majordomo Selistra", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(46.19, 78.46, "The Waking Shores", "Majordomo Selistra", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(46.12, 78.32, "The Waking Shores", "Alexstrasza the Life-Binder", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(42.5, 66.84, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(42.5, 66.84, "The Waking Shores", "Scalecommander Emberthal", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(42.53, 66.79, "The Waking Shores", "Scalecommander Emberthal", "Talk, then Make Inn home", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(42.53, 66.79, "The Waking Shores", "Scalecommander Emberthal", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(42.51, 66.79, "The Waking Shores", "Scalecommander Emberthal", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(42.49, 66.83, "The Waking Shores", "Wrathion", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(42.44, 66.19, "The Waking Shores", "Fao the Relentless", "Talk and take map", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(42.8, 66.82, "The Waking Shores", "Forgemaster Bazentus", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(43.75, 67.23, "The Waking Shores", "Archivist Edress", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(42.26, 69.33, "The Waking Shores", "Talonstalker Kavia", "Talk and complete", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(42.48, 66.85, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(42.48, 66.85, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(42.51, 66.83, "The Waking Shores", "Wrathion", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(42.51, 66.83, "The Waking Shores", "Wrathion", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(35.66, 68.55, "The Waking Shores", "Piercer Gigra", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(34.82, 66.97, "The Waking Shores", "Olphis the Molten", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(35.59, 60.72, "The Waking Shores", "Modak Flamespit", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(34.03, 61.32, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(34.03, 61.32, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(34.03, 61.32, "The Waking Shores", "Wrathion", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(34.03, 61.32, "The Waking Shores", "Wrathion", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(29.07, 58.79, "The Waking Shores", "Wrathion", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(29.07, 58.79, "The Waking Shores", "Wrathion", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(27.14, 57.07, "The Waking Shores", "Champion Choruk", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(26.42, 58.74, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(26.42, 58.74, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(26.4, 58.75, "The Waking Shores", "Wrathion", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(27.32, 62.57, "The Waking Shores", "Wrathion", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(27.31, 62.62, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(27.28, 62.78, "The Waking Shores", "Forgemaster Bazentus", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(23.84, 59.16, "The Waking Shores", "Scalecommander Emberthal", "Complete quest", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(27.28, 62.78, "The Waking Shores", "Forgemaster Bazentus", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(27.28, 62.78, "The Waking Shores", "Forgemaster Bazentus", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(24.65, 60.94, "The Waking Shores", "Forgemaster Bazentus", "Click forge", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(24.74, 61.21, "The Waking Shores", "Forgemaster Bazentus", "Complete and Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(24.71, 61.14, "The Waking Shores", "Forgemaster Bazentus", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(24.64, 60.94, "The Waking Shores", "Forgemaster Bazentus", "Click forge", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(24.64, 60.94, "The Waking Shores", "Forgemaster Bazentus", "Click forge", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(24.7, 61.1, "The Waking Shores", "Forgemaster Bazentus", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(24.71, 61.14, "The Waking Shores", "Forgemaster Bazentus", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(27.34, 62.58, "The Waking Shores", "Wrathion", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(27.34, 62.58, "The Waking Shores", "Wrathion", "Travel", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(24.48, 55.57, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(24.48, 55.57, "The Waking Shores", "Wrathion", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(24.31, 55.88, "The Waking Shores", "Sabellian", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(24.99, 55.19, "The Waking Shores", "Left", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(26.37, 54.64, "The Waking Shores", "Talonstalker Kavia", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(25.14, 56.32, "The Waking Shores", "Archivist Edress", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(25.14, 56.32, "The Waking Shores", "Archivist Edress", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(24.4, 57.82, "The Waking Shores", "Forgemaster Bazentus", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(24.33, 58.8, "The Waking Shores", "Baskilan", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(24.43, 55.58, "The Waking Shores", "Wrathion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(24.33, 55.92, "The Waking Shores", "Sabellian", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(24.34, 55.87, "The Waking Shores", "Sabellian", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(43.83, 66.4, "The Waking Shores", "Sabellian", "Use Hearthstone and Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(57.92, 67.3, "The Waking Shores", "Sabellian", "Escort and Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(57.94, 67.31, "The Waking Shores", "Sabellian", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(61.56, 68.69, "The Waking Shores", "Mother Elion", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(61.56, 68.69, "The Waking Shores", "Mother Elion", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(61.57, 68.71, "The Waking Shores", "Mother Elion", "Complete and Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(61.56, 68.69, "The Waking Shores", "Mother Elion", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(62.35, 73.03, "The Waking Shores", "Alexstrasza the Life-Binder", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.35, 73.03, "The Waking Shores", "Alexstrasza the Life-Binder", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(61.55, 68.59, "The Waking Shores", "Alexstrasza the Life-Binder", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(61.55, 68.59, "The Waking Shores", "Alexstrasza the Life-Binder", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(45.95, 81.47, "The Waking Shores", "Iyali", "Fly and Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(48.29, 88.59, "The Waking Shores", "Ambassador Taurasza", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(48.29, 88.59, "The Waking Shores", "Ambassador Taurasza", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(77.73, 23.9, "Ohn'ahran Plains", "Scout Tomul", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(77.73, 23.9, "Ohn'ahran Plains", "Scout Tomul", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(78.52, 26.98, "Ohn'ahran Plains", "Blazing Proto-Dragon", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(78.62, 25.43, "Ohn'ahran Plains", "Scout Tomul", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(78.62, 25.43, "Ohn'ahran Plains", "Scout Tomul", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(85.29, 25.39, "Ohn'ahran Plains", "Scout Tomul", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(85.32, 25.37, "Ohn'ahran Plains", "Loyal Bakar", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(84.57, 25.25, "Ohn'ahran Plains", "Muqur Rain-Touched", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(84.41, 24.98, "Ohn'ahran Plains", "Farrier Roscha", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(84.38, 24.97, "Ohn'ahran Plains", "Apprentice Ehri", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(85.7, 25.32, "Ohn'ahran Plains", "Sansok Khan", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(85.7, 25.32, "Ohn'ahran Plains", "Sansok Khan", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(85.7, 25.32, "Ohn'ahran Plains", "Sansok Khan", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(85.7, 25.32, "Ohn'ahran Plains", "Sansok Khan", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(85.79, 26.56, "Ohn'ahran Plains", "Aru", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(83.94, 25.93, "Ohn'ahran Plains", "Beastmaster Nuqut", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(85.58, 20.9, "Ohn'ahran Plains", "Ohn Seshteng", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(84.68, 22.87, "Ohn'ahran Plains", "Scout Tomul", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(84.68, 22.87, "Ohn'ahran Plains", "Scout Tomul", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(84.68, 22.87, "Ohn'ahran Plains", "Scout Tomul", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(83.19, 23.72, "Ohn'ahran Plains", "Scout Tomul", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(85.01, 15.22, "Ohn'ahran Plains", "Ravenous Rockfang", "Get Gizzard and Fermur", "QUEST_WATCH_UPDATE", 70319));
table.insert(steps, CreateStep(85.01, 15.22, "Ohn'ahran Plains", "Ravenous Rockfang", "Get Gizzard and Fermur", "QUEST_WATCH_UPDATE", 70319));
table.insert(steps, CreateStep(77.73, 18.55, "Ohn'ahran Plains", "Swift Hornstrider", "Get Scale", "QUEST_WATCH_UPDATE", 70319));
table.insert(steps, CreateStep(75.13, 25.04, "Ohn'ahran Plains", "Clearwater Ottuk", "Get Heart", "QUEST_WATCH_UPDATE", 70319));
table.insert(steps, CreateStep(75.65, 31.63, "Ohn'ahran Plains", "Scout Tomul", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(75.65, 31.63, "Ohn'ahran Plains", "Scout Tomul", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(76.7, 31.9, "Ohn'ahran Plains", nil, "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(77.95, 35.3, "Ohn'ahran Plains", "Konkhular", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(78.75, 30.91, "Ohn'ahran Plains", "Plainswalker Bull", "Kill Elephants", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(81.22, 29.87, "Ohn'ahran Plains", "Mudfin Mudrunner", "Talk", "QUEST_WATCH_UPDATE", 65950));
table.insert(steps, CreateStep(80.57, 30.77, "Ohn'ahran Plains", "Khasar", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(80.57, 30.77, "Ohn'ahran Plains", "Khasar", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(80.58, 30.77, "Ohn'ahran Plains", "Khasar", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(80.58, 30.77, "Ohn'ahran Plains", "Khasar", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(80.58, 30.77, "Ohn'ahran Plains", "Khasar", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(84.43, 25.01, "Ohn'ahran Plains", "Farrier Roscha", "Complete all Murloc quests, then Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(84.43, 25.01, "Ohn'ahran Plains", "Farrier Roscha", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(84.57, 25.27, "Ohn'ahran Plains", "Muqur Rain-Touched", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(75.65, 31.69, "Ohn'ahran Plains", "Scout Tomul", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(75.65, 31.69, "Ohn'ahran Plains", "Scout Tomul", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(75.65, 31.69, "Ohn'ahran Plains", "Scout Tomul", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(69.99, 37.96, "Ohn'ahran Plains", "Ohn Seshteng", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(69.99, 37.96, "Ohn'ahran Plains", "Ohn Seshteng", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(69.95, 37.96, "Ohn'ahran Plains", "Ohn Seshteng", "Complete and Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(69.99, 37.96, "Ohn'ahran Plains", "Ohn Seshteng", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(69.95, 37.96, "Ohn'ahran Plains", "Ohn Seshteng", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(70, 37.97, "Ohn'ahran Plains", "Ohn Seshteng", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(70.04, 37.99, "Ohn'ahran Plains", "Sansok Khan", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(61.45, 39.58, "Ohn'ahran Plains", "Sansok Khan", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(61.45, 39.58, "Ohn'ahran Plains", "Sansok Khan", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(61.45, 39.58, "Ohn'ahran Plains", "Sansok Khan", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(61.45, 39.58, "Ohn'ahran Plains", "Sansok Khan", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(61.45, 39.58, "Ohn'ahran Plains", "Sansok Khan", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(63.6, 40.5, "Ohn'ahran Plains", "Hunter Narman", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(62.79, 40.66, "Ohn'ahran Plains", "Make Inn Home", "Talk", "QUEST_WATCH_UPDATE"));

table.insert(steps, CreateStep(60.43, 40.73, "Ohn'ahran Plains", "Scout Tomul", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(60.35, 40.76, "Ohn'ahran Plains", "Guard Bahir", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(59.96, 41.44, "Ohn'ahran Plains", "Nokhud Fighter", "Defeat", "QUEST_WATCH_UPDATE", 66017));
table.insert(steps, CreateStep(59.18, 37.66, "Ohn'ahran Plains", "Qariin Dotur", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(59.18, 37.66, "Ohn'ahran Plains", "Qariin Dotur", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(59.17, 37.59, "Ohn'ahran Plains", "Qariin Dotur", "Complete and Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(60.01, 37.37, "Ohn'ahran Plains", "Elder Odgerel", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(60.37, 37.61, "Ohn'ahran Plains", "Agari Dotur", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(60.37, 37.71, "Ohn'ahran Plains", "Quartermaster Huseng", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(62.17, 36.41, "Ohn'ahran Plains", "Windsage Kven", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(62.19, 35.76, "Ohn'ahran Plains", "Hearthkeeper Erden", "Buy Honey", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(62.79, 35.48, "Ohn'ahran Plains", "Windsage Dawa", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(62.97, 33.67, "Ohn'ahran Plains", "Ohn Seshteng", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.97, 33.67, "Ohn'ahran Plains", "Ohn Seshteng", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(63.12, 34.08, "Ohn'ahran Plains", "Windsage Ordven", "Accept quest", "QUEST_ACCEPTED")); -- A disgrunded initiate?

table.insert(steps, CreateStep(63.81, 35.91, "Ohn'ahran Plains", "Ohn Arasara", "Pick flowers and Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(62.97, 33.73, "Ohn'ahran Plains", "Ohn Seshteng", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.18, 35.71, "Ohn'ahran Plains", "Hearthkeeper Erden", "Buy milk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(65.97, 25.11, "Ohn'ahran Plains", "Telemancer Aerilyn", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(65.9, 25.13, "Ohn'ahran Plains", "Telemancer Aerilyn", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(64.03, 18.32, "Ohn'ahran Plains", "Skyscribe Adenedal", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(64.03, 18.32, "Ohn'ahran Plains", "Skyscribe Adenedal", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(64.03, 18.32, "Ohn'ahran Plains", "Skyscribe Adenedal", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(63.94, 15.82, "Ohn'ahran Plains", "Sundered Enforcer", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(64.34, 15.68, "Ohn'ahran Plains", "Tarasek Laborer", "Pick up", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(64.02, 18.27, "Ohn'ahran Plains", "Skyscribe Adenedal", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.92, 18.59, "Ohn'ahran Plains", "Tserasor the Preserver", "Talk", "QUEST_WATCH_UPDATE"));

table.insert(steps, CreateStep(62.42, 18.48, "Ohn'ahran Plains", "Sootscale the Indomitable", "KILL", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(61.74, 18.63, "Ohn'ahran Plains", nil, "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(62.58, 16.46, "Ohn'ahran Plains", "Malifron", "KILL", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(62.13, 16.35, "Ohn'ahran Plains", "Skyscribe Adenedal", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.13, 16.35, "Ohn'ahran Plains", "Skyscribe Adenedal", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(60.62, 17.37, "Ohn'ahran Plains", nil, "Click", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(60.62, 17.37, "Ohn'ahran Plains", "Hypoxicron", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(66.31, 24.34, "Ohn'ahran Plains", "Skyscribe Adenedal", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(66.31, 24.34, "Ohn'ahran Plains", "Skyscribe Adenedal", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(65.99, 25.07, "Ohn'ahran Plains", "Telemancer Aerilyn", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(63.54, 41.05, "Ohn'ahran Plains", "Provisioner Zara", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(62.42, 41.69, "Ohn'ahran Plains", "Scout Tomul", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.39, 41.66, "Ohn'ahran Plains", "Aru", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(61.41, 39.53, "Ohn'ahran Plains", "Sansok Khan", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(61.43, 39.55, "Ohn'ahran Plains", "Sansok Khan", "Turn in quest", "QUEST_TURNED_IN"));

table.insert(steps, CreateStep(61.06, 40.44, "Ohn'ahran Plains", "Gemisath", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(61.06, 40.44, "Ohn'ahran Plains", "Gemisath", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(61.06, 40.44, "Ohn'ahran Plains", "Gemisath", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(60.3, 37.91, "Ohn'ahran Plains", nil, "Click", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(60.33, 38.02, "Ohn'ahran Plains", "Khansguard Akato", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(59.5, 38.73, "Ohn'ahran Plains", "Scout Tomul", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(58.76, 39.41, "Ohn'ahran Plains", "Nokhud Reaver", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(58.2, 39.36, "Ohn'ahran Plains", "Guard Bahir", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(57.08, 42.65, "Ohn'ahran Plains", "Old Arbhog", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(55.36, 38.4, "Ohn'ahran Plains", "Matchmaker Osila", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(56.09, 38.24, "Ohn'ahran Plains", "Matchmaker Osila", "Talk", "QUEST_WATCH_UPDATE", 70739));
table.insert(steps, CreateStep(60.32, 38.07, "Ohn'ahran Plains", "Khanam Matra Sarest", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(60.32, 38.07, "Ohn'ahran Plains", "Khansguard Akato", "Turn in quest", "QUEST_TURNED_IN"));

table.insert(steps, CreateStep(60.32, 38.07, "Ohn'ahran Plains", "Khanam Matra Sarest", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(62.84, 35.43, "Ohn'ahran Plains", "Windsage Dawa", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(62.84, 35.43, "Ohn'ahran Plains", "Windsage Dawa", "Accept quest", "QUEST_TURNED_IN")); -- After My Ohn Heart available ?

table.insert(steps, CreateStep(60.05, 37.52, "Ohn'ahran Plains", "Khanam Matra Sarest", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(60.05, 37.52, "Ohn'ahran Plains", "Khanam Matra Sarest", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(63.6, 40.56, "Ohn'ahran Plains", "Hunter Narman", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(63.59, 40.45, "Ohn'ahran Plains", "Hunter Narman", "Talk", "QUEST_WATCH_UPDATE"));

table.insert(steps, CreateStep(62.03, 41.8, "Ohn'ahran Plains", "Beastmaster Tirren", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(63.02, 48.56, "Ohn'ahran Plains", "Sunscale Behemoth", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(46.67, 60.34, "Ohn'ahran Plains", nil, "Click", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(46.71, 60.52, "Ohn'ahran Plains", "Hunter Narman", "Turn in quest", "QUEST_TURNED_IN"));

-- Teerakai
table.insert(steps, CreateStep(41.89, 61.79, "Ohn'ahran Plains", "Khansguard Jebotai", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(41.87, 61.8, "Ohn'ahran Plains", "Khansguard Jebotai", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(40.97, 61.59, "Ohn'ahran Plains", "Elder Yuvari", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(39.05, 65.99, "Ohn'ahran Plains", "Initiate Zorig", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(39.05, 65.99, "Ohn'ahran Plains", "Initiate Zorig", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(37.16, 65.68, "Ohn'ahran Plains", "Tombcaller Ganzaya", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(37.06, 65.51, "Ohn'ahran Plains", nil, "Click", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(39.05, 65.99, "Ohn'ahran Plains", "Initiate Zorig", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(39.05, 65.99, "Ohn'ahran Plains", "Initiate Zorig", "Accept quest", "QUEST_ACCEPTED"));


table.insert(steps, CreateStep(36.2, 64.19, "Ohn'ahran Plains", "Risen Bakar", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(33.78, 65.37, "Ohn'ahran Plains", "Initiate Zorig", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(33.78, 65.37, "Ohn'ahran Plains", "Initiate Zorig", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(33.78, 65.37, "Ohn'ahran Plains", "Initiate Zorig", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(35.61, 68.14, "Ohn'ahran Plains", "Overseer Zambul", "Kill", "QUEST_WATCH_UPDATE"));

table.insert(steps, CreateStep(33.78, 65.36, "Ohn'ahran Plains", "Initiate Zorig", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(33.78, 65.36, "Ohn'ahran Plains", "Initiate Zorig", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(32.82, 71.73, "Ohn'ahran Plains", nil, "Kill", "QUEST_WATCH_UPDATE", 66656));
table.insert(steps, CreateStep(30.86, 71.14, "Ohn'ahran Plains", nil, "Kill", "QUEST_WATCH_UPDATE", 66656));
table.insert(steps, CreateStep(30.86, 71.14, "Ohn'ahran Plains", nil, "Kill", "QUEST_WATCH_UPDATE", 66656));
table.insert(steps, CreateStep(30.86, 71.14, "Ohn'ahran Plains", nil, "Kill", "QUEST_WATCH_UPDATE", 66656));

table.insert(steps, CreateStep(30.89, 71.19, "Ohn'ahran Plains", "Initiate Zorig", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(30.89, 71.19, "Ohn'ahran Plains", "Initiate Zorig", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(31.47, 70.85, "Ohn'ahran Plains", "Tombcaller Arban", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(31.09, 71, "Ohn'ahran Plains", "Tombcaller Arban", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(31.48, 71.49, "Ohn'ahran Plains", "Tombcaller Arban", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(31.45, 71.43, "Ohn'ahran Plains", "Initiate Zorig", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(31.45, 71.43, "Ohn'ahran Plains", "Initiate Zorig", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(37.54, 59.49, "Ohn'ahran Plains", "Scout Khenyug", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(39.57, 56.43, "Ohn'ahran Plains", "Herbalist Agura", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(39.55, 55.4, "Ohn'ahran Plains", "Khansguard Hojin", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(40.77, 56.33, "Ohn'ahran Plains", "Quartermaster Gensai", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(41.62, 56.75, "Ohn'ahran Plains", "Elder Nazuun", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(41.62, 56.75, "Ohn'ahran Plains", "Elder Nazuun", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(42.24, 47.34, "Ohn'ahran Plains", "Mara'nar the Thunderous", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(44.2, 48.39, "Ohn'ahran Plains", "Spider Eggs", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(44.94, 49.05, "Ohn'ahran Plains", "Skaara", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(46.65, 51.45, "Ohn'ahran Plains", nil, "Click", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(50.15, 50.95, "Ohn'ahran Plains", "Thunderspine Crasher", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(49.34, 49.51, "Ohn'ahran Plains", nil, "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(49.34, 49.43, "Ohn'ahran Plains", "Himia, The Blessed", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(41.6, 56.75, "Ohn'ahran Plains", "Elder Nazuun", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(41.6, 56.75, "Ohn'ahran Plains", "Elder Nazuun", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(41.6, 56.75, "Ohn'ahran Plains", "Elder Nazuun", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(40.14, 57.81, "Ohn'ahran Plains", "Elder Nazuun", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(41.6, 56.74, "Ohn'ahran Plains", "Elder Nazuun", "Turn in quest", "QUEST_TURNED_IN"));

table.insert(steps, CreateStep(41.86, 61.76, "Ohn'ahran Plains", "Khansguard Jebotai", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(41.86, 61.76, "Ohn'ahran Plains", "Khansguard Jebotai", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(36.84, 57.29, "Ohn'ahran Plains", "Initiate Boku", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(36.82, 57.31, "Ohn'ahran Plains", "Initiate Boku", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(36.82, 57.31, "Ohn'ahran Plains", "Initiate Boku", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(44.55, 61.95, "Ohn'ahran Plains", nil, "Click", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(46.51, 63.22, "Ohn'ahran Plains", "Unidentified Centaur", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(49.31, 63.21, "Ohn'ahran Plains", "Initiate Boku", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(49.31, 63.18, "Ohn'ahran Plains", "Tigari Khan", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(49.31, 63.18, "Ohn'ahran Plains", "Tigari Khan", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(48.92, 69, "Ohn'ahran Plains", "Shela the Windbinder", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(49.55, 67.13, "Ohn'ahran Plains", "Nokhud Mystic-Hunter", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(49.81, 67.02, "Ohn'ahran Plains", "Eaglemaster Niraak", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(49.36, 63.18, "Ohn'ahran Plains", "Tigari Khan", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(49.36, 63.18, "Ohn'ahran Plains", "Tigari Khan", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(49.39, 63.2, "Ohn'ahran Plains", "Tigari Khan", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(58.11, 68.97, "Ohn'ahran Plains", "Initiate Boku", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(58.11, 68.97, "Ohn'ahran Plains", "Initiate Boku", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(58.11, 68.97, "Ohn'ahran Plains", "Initiate Boku", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(58.11, 68.97, "Ohn'ahran Plains", "Initiate Boku", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(59.89, 66.82, "Ohn'ahran Plains", "Prozela Galeshot", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(60.65, 63.55, "Ohn'ahran Plains", "Initiate Boku", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(60.65, 63.55, "Ohn'ahran Plains", "Initiate Boku", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(60.65, 63.55, "Ohn'ahran Plains", "Initiate Boku", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(60.65, 63.55, "Ohn'ahran Plains", "Initiate Boku", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(61.41, 62.81, "Ohn'ahran Plains", "Initiate Boku", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(61.41, 62.81, "Ohn'ahran Plains", "Initiate Boku", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(60.05, 37.55, "Ohn'ahran Plains", "Khanam Matra Sarest", "HS and Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(60.05, 37.55, "Ohn'ahran Plains", "Khanam Matra Sarest", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(60.05, 37.55, "Ohn'ahran Plains", "Khanam Matra Sarest", "Accept quest", "QUEST_ACCEPTED"));


table.insert(steps, CreateStep(60.05, 37.55, "Ohn'ahran Plains", "Khanam Matra Sarest", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(73.01, 40.57, "Ohn'ahran Plains", "Khanam Matra Sarest", "Skip the lion and fly here. Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(73.01, 40.57, "Ohn'ahran Plains", "Khanam Matra Sarest", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(76.02, 40.91, "Ohn'ahran Plains", "Warmonger Kharad", "Kill", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(76.69, 40.91, "Ohn'ahran Plains", "Khanam Matra Sarest", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(76.69, 40.91, "Ohn'ahran Plains", "Khanam Matra Sarest", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(76.69, 40.91, "Ohn'ahran Plains", "Khanam Matra Sarest", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(76.69, 40.91, "Ohn'ahran Plains", "Khanam Matra Sarest", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(72.4, 50.37, "Ohn'ahran Plains", "Khanam Matra Sarest", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(72.42, 50.71, "Ohn'ahran Plains", "Merithra", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(72.31, 50.69, "Ohn'ahran Plains", "Gerithus", "Talk", "QUEST_WATCH_UPDATE"));
-- Shady Sanctuary

table.insert(steps, CreateStep(28.27, 57.71, "Ohn'ahran Plains", "Merithra", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(28.27, 57.71, "Ohn'ahran Plains", "Merithra", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(29.97, 58.33, "Ohn'ahran Plains", "Gracus", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(30.19, 55.73, "Ohn'ahran Plains", "Sidra the Mender", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(29.13, 55.29, "Ohn'ahran Plains", "Guard-Captain Alowen", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(29.29, 56.44, "Ohn'ahran Plains", "Aronus", "Talk", "QUEST_WATCH_UPDATE"));
table.insert(steps, CreateStep(29.71, 60.02, "Ohn'ahran Plains", "Viranikus", "Talk", "QUEST_WATCH_UPDATE"));

table.insert(steps, CreateStep(29.61, 58.68, "Ohn'ahran Plains", "Gracus", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(29.54, 58.76, "Ohn'ahran Plains", "Gracus", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(28.29, 57.7, "Ohn'ahran Plains", "Merithra", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(28.28, 57.69, "Ohn'ahran Plains", "Merithra", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(30.36, 58.2, "Ohn'ahran Plains", "Gracus", "Turn in quest", "QUEST_TURNED_IN"));
table.insert(steps, CreateStep(30.36, 58.19, "Ohn'ahran Plains", "Gracus", "Accept quest", "QUEST_ACCEPTED"));

table.insert(steps, CreateStep(55.86, 12.70, "Durotar", "NONE", "NONE", "NONE"));


-- Ketho edit box
function KethoEditBox_Show(text)
  if not KethoEditBox then
      local f = CreateFrame("Frame", "KethoEditBox", UIParent, "DialogBoxFrame")
      f:SetPoint("CENTER")
      f:SetSize(600, 500)
      
      f:SetBackdrop({
          bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
          edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
          edgeSize = 16,
          insets = { left = 8, right = 6, top = 8, bottom = 8 },
      })
      f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
      
      -- Movable
      f:SetMovable(true)
      f:SetClampedToScreen(true)
      f:SetScript("OnMouseDown", function(self, button)
          if button == "LeftButton" then
              self:StartMoving()
          end
      end)
      f:SetScript("OnMouseUp", f.StopMovingOrSizing)
      
      -- ScrollFrame
      local sf = CreateFrame("ScrollFrame", "KethoEditBoxScrollFrame", KethoEditBox, "UIPanelScrollFrameTemplate")
      sf:SetPoint("LEFT", 16, 0)
      sf:SetPoint("RIGHT", -32, 0)
      sf:SetPoint("TOP", 0, -16)
      sf:SetPoint("BOTTOM", KethoEditBoxButton, "TOP", 0, 0)
      
      -- EditBox
      local eb = CreateFrame("EditBox", "KethoEditBoxEditBox", KethoEditBoxScrollFrame)
      eb:SetSize(sf:GetSize())
      eb:SetMultiLine(true)
      eb:SetAutoFocus(false) -- dont automatically focus
      eb:SetFontObject("ChatFontNormal")
      sf:SetScrollChild(eb)
      
      -- Resizable
      f:SetResizable(true)
      
      local rb = CreateFrame("Button", "KethoEditBoxResizeButton", KethoEditBox)
      rb:SetPoint("BOTTOMRIGHT", -6, 7)
      rb:SetSize(16, 16)
      
      rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
      rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
      rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
      
      rb:SetScript("OnMouseDown", function(self, button)
          if button == "LeftButton" then
              f:StartSizing("BOTTOMRIGHT")
              self:GetHighlightTexture():Hide() -- more noticeable
          end
      end)

      rb:SetScript("OnMouseUp", function(self, button)
          f:StopMovingOrSizing()
          self:GetHighlightTexture():Show()
          eb:SetWidth(sf:GetWidth())
      end)
      f:Show()

      local c1 = CreateButton("Acc", KethoEditBox, 25);
      c1:SetPoint("RIGHT", KethoEditBox, "BOTTOMRIGHT", -50, 0);
      c1:SetScript("OnClick", function(self, event)
        PrintScript("QUEST_ACCEPTED", "Accept quest");
      end)
      
      local c2 = CreateButton("Tur", KethoEditBox, 25);
      c2:SetPoint("RIGHT", KethoEditBox, "BOTTOMRIGHT", -75, 0);
      c2:SetScript("OnClick", function(self, event)
        PrintScript("QUEST_TURNED_IN", "Turn in quest");
      end)
      
      local c3 = CreateButton("Upd", KethoEditBox, 25);
      c3:SetPoint("RIGHT", KethoEditBox, "BOTTOMRIGHT", -100, 0);
      c3:SetScript("OnClick", function(self, event)
        local target = UnitName("target");
        if target == nil then
          PrintScript("QUEST_WATCH_UPDATE", "Click");
        else
          local enemy = UnitCanAttack("player", "target") == true;
          if enemy then
            PrintScript("QUEST_WATCH_UPDATE", "Kill");
          else 
            PrintScript("QUEST_WATCH_UPDATE", "Talk");
          end
        end
      end)
      
      local c4 = CreateButton("CLEAR", KethoEditBox, 25);
      c4:SetPoint("RIGHT", KethoEditBox, "BOTTOMRIGHT", -200, 0);
      c4:SetScript("OnClick", function(self, event)
        paste = "";
        KethoEditBox_Show("");
      end)
  end
  
  if text then
      KethoEditBoxEditBox:SetText(text)
  end
  KethoEditBox:Show()
end

KethoEditBox_Show();
