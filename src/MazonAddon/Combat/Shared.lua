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

local hekiliQueue = nil;

function GetHekiliQueue()
  if hekiliQueue == nil then
    hekiliQueue = Hekili:Query("queue");
  end
  return hekiliQueue;
end

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
    local buff = UnitBuff(target, i);
    if buff ~= nil then
      if buff.sourceUnit == "player" then
        if buffName ~= nil and string.lower(buff.name) == string.lower(buffName) then
          local time = GetTime();
          return buff.name, buff.expirationTime - time, buff.applications, i, buff.icon, buff.points;
        end
      end
    end
  end
end

function FindUnitBuff(target, buffName)
  for i=1,40 do
    local buff = UnitBuff(target, i);
    if buff ~= nil and buffName ~= nil and string.lower(buff.name) == string.lower(buffName) then
      return buff;
    end
  end
end

function FindDebuff(target, buffName)
  for i=1,40 do
    local debuff = C_UnitAuras.GetDebuffDataByIndex(target, i);
    if debuff ~= nil and string.lower(debuff.name) == string.lower(buffName) then
      if (target == "target" and debuff.sourceUnit == "player") then
        local time = GetTime();
        return debuff.name, debuff.expirationTime - time, debuff.applications;
      elseif(target == "player") then
        local time = GetTime();
        return debuff.name, debuff.expirationTime - time, debuff.applications;
      end
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
  if charges ~= nil then
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
  local absorb = UnitGetTotalHealAbsorbs(unit);

  if maxHp == 0 or hp == 0 then
    return 0;
  end

  return ((hp - absorb) / maxHp) * 100;
end

function GetMissingHealth(unit)
  local maxHp = UnitHealthMax(unit);
  local hp = UnitHealth(unit);
  local absorb = UnitGetTotalHealAbsorbs(unit);

  if maxHp == 0 or hp == 0 then
    return 0;
  end

  return maxHp - (hp - absorb);
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

local delay = 0.5;
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
  return (gcd - ((gcd / 2) * (spellHastePercent * 0.01)));
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
    WowCyborg_PAUSE_UNTIL
     = GetTime() + (finish + 1);
  end

  local channelInfo, c_, c__, c___, channelEndTime = UnitChannelInfo("player");
  if channelInfo == "Focused Azerite Beam" then
    local finish = channelEndTime / 1000 - GetTime();
    WowCyborg_PAUSE_UNTIL = GetTime() + (finish + 0.5);
  end
end

function GetNearbyEnemyCount(spellRangeCheck)
  if spellRangeCheck == nil then
    return 0;
  end

  local count = 0;

  for i = 1, 40 do 
    if IsNearby("nameplate"..i, spellRangeCheck) == true then
      if UnitHealth("nameplate"..i) > 0 then
        count = count + 1;
      end
    end
  end

  return count;
end


function IsNearby(target, spellRangeCheck)
  if UnitCanAttack("player", target) == false then
    return false
  end
  
  if IsSpellInRange(spellRangeCheck, target) == 1 then
    return true
  else
    return false
  end
end

function IsSpellInRange(spellId, target)
  if C_Spell.IsSpellInRange(spellId, target) == true then
    return 1
  else
    return 0
  end
end

function UnitBuff(target, i)
  return C_UnitAuras.GetBuffDataByIndex(target, i)
end

function GetSpellCooldown(spellName)
  if (C_Spell == nil) then
    return GetSpellCooldown(spellName)
  end

  local spellCd = C_Spell.GetSpellCooldown(spellName)
  if spellCd == nil then
    return nil;
  end

  return spellCd.startTime, spellCd.duration;
end

function GetSpellCharges(spellName)
  local spellC = C_Spell.GetSpellCharges(spellName)
  if (spellC == nil) then
    return 0
  end

  return spellC.currentCharges, spellC.maxCharges, spellC.cooldownStartTime, spellC.cooldownDuration
end

function IsUsableSpell(spellName)
  return C_Spell.IsSpellUsable(spellName)
end