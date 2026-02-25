local frameSize = 5;

function CreateWrapperFrame()
  local frame, texture = CreateDefaultFrame(0, 0, frameSize * 4, frameSize);
  texture:SetColorTexture(1, 0, 1);
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
    UpdateMazonRotation()
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

CreateRotationFrame();
CreateWrapperFrame();
