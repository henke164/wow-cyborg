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
function CreateOption(npc, text, index)
  local option = {}
  option.npc = npc;
  option.text = text;
  option.index = index;
  return option;
end

local optionsToSelect = {};
table.insert(optionsToSelect, CreateOption("Ebyssian", "A great journey", 1));
table.insert(optionsToSelect, CreateOption("Pathfinder Tacha", "interested in", 1));
table.insert(optionsToSelect, CreateOption("Cataloger Kieule", "new discovery", 1));
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


function CreateStep(x, y, zone, target, description, completeEvent, questId)
  local step = {};
  step.x = x;
  step.y = y;
  step.zone = zone;
  step.description = description;
  step.target = target;
  step.completeEvent = completeEvent;
  step.questId = questId;
  return step;
end

function CreateButton(text, parent)
	local button = CreateFrame("Button", nil, parent)
	button:SetWidth(25)
	button:SetHeight(25)
	
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

function RenderGuideFrame()
  local fontFrame, fontTexture = CreateDefaultFrame(0, 0, 250, 50);
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

  local previous = CreateButton("<-", fontFrame);
	previous:SetPoint("LEFT", fontFrame, "LEFT", 5, 0);
  
  local next = CreateButton("->", fontFrame);
	next:SetPoint("RIGHT", fontFrame, "RIGHT", -5, 0);
  
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
    print("Key:" .. event);

    if (event == "NAME_PLATE_UNIT_ADDED" and step.target) then
      local unitID = ...;
      local name = UnitName(unitID);
      if name == step.target then
        SetRaidTarget(unitID, 8);
      end
    end

    if (event == "QUEST_WATCH_UPDATE") then
      local questId = ...
      if step.completeEvent == event and step.questId == questId then

      end
    end

    if step.target and step.completeEvent == event and step.target == target then
      NextStep();
    end
  end);

  previous:SetScript("OnClick", function(self, event)
    PreviousStep();
  end)
    
  next:SetScript("OnClick", function(self, event)
    NextStep();
  end)

  setTimer(5, NextStep);
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
  RenderStep(step);
end

function RenderStep(step)
  WowCyborg_guideHeader:SetText(WowCyborg_Step .. ". " .. step.target);
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

table.insert(steps, CreateStep(44.12, 38.05, "Orgrimmar", "Ebyssian", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(44.12, 38.05, "Orgrimmar", "Naleidea Rivergleam", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(44.12, 38.05, "Orgrimmar", "Scalecommander Cindrethresh", "Accept quest", "QUEST_ACCEPTED"));
table.insert(steps, CreateStep(55.05, 89.44, "Orgrimmar", "Kodethi", "Talk", "QUEST_WATCH_UPDATE", 72256));
table.insert(steps, CreateStep(55.86, 12.70, "Durotar", "Ebyssian", "Turn in quest", "QUEST_TURNED_IN", 72256));
