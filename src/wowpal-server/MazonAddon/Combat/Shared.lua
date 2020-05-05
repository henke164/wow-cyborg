WowCyborg_AOE_Rotation = false;
WowCyborg_CLASSIC = true;
WowCyborg_CURRENTATTACK = "-";
WowCyborg_DISABLED = false;
WowCyborg_PAUSE = false;
WowCyborg_PAUSE_UNTIL = 0;

local spellButtonTexture;
local buttonCombinerTexture;

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
  frame, spellButtonTexture = CreateDefaultFrame(frameSize * 2, frameSize, frameSize, frameSize);
  _, buttonCombinerTexture = CreateDefaultFrame(frameSize * 3, frameSize, frameSize, frameSize);
  
  frame:EnableKeyboard(true);
  frame:SetPropagateKeyboardInput(true);

  frame:SetScript("OnUpdate", function(self, event, ...)
    if WowCyborg_DISABLED == true then
      WowCyborg_CURRENTATTACK = "-";
      return SetSpellRequest(nil);
    end

    local castingInfo, _a, __a, ___a, endTime = UnitChannelInfo("player")
    local channelInfo, _b, __b, ___b, channelEndTime = UnitCastingInfo("player")
  
    if castingInfo ~= nil then
      local finish = endTime / 1000 - GetTime()
      WowCyborg_PAUSE_UNTIL = GetTime() + (finish + 1)
      return
    end
    
    if channelInfo ~= nil then
      local finish = channelEndTime / 1000 - GetTime()
      WowCyborg_PAUSE_UNTIL = GetTime() + (finish + 1)
      return
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
  if IsMouseButtonDown("MiddleButton") then
    WowCyborg_PAUSE_UNTIL = GetTime() + 1;
  end

  if GetTime() < WowCyborg_PAUSE_UNTIL then
    return false
  end

  if buttonCombination == nil then
    r, g, b = GetColorFromNumber(nil);
    buttonCombinerTexture:SetColorTexture(r, g, b);
    spellButtonTexture:SetColorTexture(r, g, b);
    return true
  end

  local b1, b2 = strsplit("+", buttonCombination);

  if b2 == nil then
    buttonCombinerTexture:SetColorTexture(GetColorFromButton(nil));
    spellButtonTexture:SetColorTexture(GetColorFromNumber(tonumber(b1)));
    return true
  end

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
    local name, _, stacks, _, _, etime = UnitBuff(target, i);
    if name ~= nil and string.lower(name) == string.lower(buffName) then
      local time = GetTime();
      return name, etime - time, stacks;
    end
  end
end

function FindDebuff(target, buffName)
  for i=1,40 do
    local name, _, stack, _, _, etime = UnitDebuff(target, i);
    if name ~= nil and string.lower(name) == string.lower(buffName) then
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
  local lastCast, totalCd = GetSpellCooldown(spellName, "spell");

  if lastCast == 0 then
    if energy >= requiredEnergy then
      return true;
    end
  end

  local time = GetTime();
  local timeLeft = ((lastCast + totalCd) - time);

  if timeLeft < 0.5 then
    if energy >= requiredEnergy then
      return true;
    end
  end
  
  local charges = GetSpellCharges(spellName);
  if (charges == nil) == false then
    if charges > 0 then
      if energy >= requiredEnergy then
        return true;
      end
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

function GetHealthPercentage(unit)
  local maxHp = UnitHealthMax(unit);
  local hp = UnitHealth(unit);
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
        WowCyborg_DISABLED = true;
      elseif WowCyborg_DISABLED == true then
        WowCyborg_DISABLED = false;
      else
        WowCyborg_AOE_Rotation = not WowCyborg_AOE_Rotation;
      end
    end

    if GetTime() - 1 < WowCyborg_PAUSE_UNTIL or WowCyborg_PAUSE then
      return
    end

    local cdUntil = GetSpellCooldown(61304);
    local globalTl = 1 - (GetTime() - cdUntil);
    if globalTl > 1.5 then
      globalTl = 0;
    end

    if string.len(tostring(key)) > 1 then
      local func = string.sub(tostring(key), 1, 1);
      if func == "F" then
        local num = string.sub(tostring(key), 2, 3);
        WowCyborg_CURRENTATTACK = "F+" .. num;
        SetSpellRequest("F+" .. num);
        WowCyborg_PAUSE_UNTIL = GetTime() + globalTl + 0.1;
      end
    end
  end)
  
  fontFrame:SetScript("OnUpdate", function(self, event, ...)
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
  local spellHastePercent = UnitSpellHaste("player")
  return (0.75 * (spellHastePercent * 0.01)) - delay;
end