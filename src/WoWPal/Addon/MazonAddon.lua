function CreateDefaultFrame(x, y, width, height)
  local frame = CreateFrame("Frame");
  frame:ClearAllPoints();
  frame:SetPoint("LEFT", UIParent, "LEFT", x, y);
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

function CreateCombatFrame()
  local frame, texture = CreateDefaultFrame(0, 70, 75, 20);
  frame:RegisterEvent("PLAYER_REGEN_DISABLED");
  frame:RegisterEvent("PLAYER_REGEN_ENABLED");
  local str = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  str:SetPoint("CENTER");
  str:SetTextColor(1, 1, 1);
  str:SetText("Combat");

  frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
      texture:SetColorTexture(0, 1, 0);
    end
    if event == "PLAYER_REGEN_ENABLED" then
      texture:SetColorTexture(1, 0, 0);
    end
  end)
end

function GetColorFromNumber(number)
  if number == 0 then
    return 0, 0, 0;
  end
  if number == 1 then
    return 0, 0, 0.5;
  end
  if number == 2 then
    return 0, 0, 1;
  end
  if number == 3 then
    return 0, 0.5, 0;
  end
  if number == 4 then
    return 0, 1, 0;
  end
  if number == 5 then
    return 0.5, 0, 0;
  end
  if number == 6 then
    return 1, 0, 0;
  end
  if number == 7 then
    return 0, 0.5, 1;
  end
  if number == 8 then
    return 0, 1, 1;
  end
  if number == 9 then
    return 0.5, 0, 1;
  end
  return 1, 1, 1;
end

function CreateMapDataFrame(numberIndex)
  local frame, texture = CreateDefaultFrame(numberIndex * 10, 120, 10, 10);

  frame:SetScript("OnUpdate", function(self, event, ...)
    map = C_Map.GetBestMapForUnit("player");
    number = tonumber(strsub(map, numberIndex + 1, numberIndex + 1));
    r, g, b = GetColorFromNumber(number);
    texture:SetColorTexture(r, g, b);
  end)
end

function CreateXDataFrame(decimalIndex)
  local frame, texture = CreateDefaultFrame(decimalIndex * 10, 100, 10, 10);

  frame:SetScript("OnUpdate", function(self, event, ...)
    map = C_Map.GetBestMapForUnit("player");
    px = C_Map.GetPlayerMapPosition(map, "player"):GetXY();
    fullXString = tostring(px);
    number = tonumber(strsub(fullXString, decimalIndex + 3, decimalIndex + 3));
    r, g, b = GetColorFromNumber(number);
    texture:SetColorTexture(r, g, b);
  end)
end

function CreateYDataFrame(decimalIndex)
  local frame, texture = CreateDefaultFrame(decimalIndex * 10, 110, 10, 10);

  frame:SetScript("OnUpdate", function(self, event, ...)
    map = C_Map.GetBestMapForUnit("player");
    _, py = C_Map.GetPlayerMapPosition(map, "player"):GetXY();
    fullYString = tostring(py);
    number = tonumber(strsub(fullYString, decimalIndex + 3, decimalIndex + 3));
    r, g, b = GetColorFromNumber(number);
    texture:SetColorTexture(r, g, b);
  end)
end

function CreateRotationDataFrame(numberIndex)
  local frame, texture = CreateDefaultFrame(numberIndex * 10, 90, 10, 10);

  frame:SetScript("OnUpdate", function(self, event, ...)
    facing = GetPlayerFacing();
    fullFacingString = tostring(facing * 1000);
    number = tonumber(strsub(fullFacingString, numberIndex + 1, numberIndex + 1));
    print(numberIndex, number);
    r, g, b = GetColorFromNumber(number);
    texture:SetColorTexture(r, g, b);
  end)
end

function CreateDataFrame()
  local frame = CreateDefaultFrame(0, 0, 225, 120);
  local str = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
  str:SetPoint("CENTER");
  str:SetTextColor(1, 1, 1);
  frame:SetScript("OnUpdate", function(self, event, ...)
    facing = GetPlayerFacing();
    map = C_Map.GetBestMapForUnit("player");
    px, py = C_Map.GetPlayerMapPosition(map, "player"):GetXY();
    str:SetText(map .. "\n\n" .. px .. "\n\n" .. py .. "\n\n" .. facing);
  end)
end

function CreateRangeCheckFrame()
  local frame, texture = CreateDefaultFrame(75, 70, 75, 20);
  local str = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  str:SetPoint("CENTER");
  str:SetTextColor(1, 1, 1);
  str:SetText("Range");

  frame:SetScript("OnUpdate", function(self, event, ...)
    texture:SetColorTexture(1, 0, 0);
    if CheckInteractDistance("target", 4) then
      if (UnitCanAttack("player","target")) then
        texture:SetColorTexture(0, 1, 0);
      end
    end
  end)
end

function CreateCooldownCheckFrame()
  local frame, texture = CreateDefaultFrame(150, 70, 75, 20);
  local str = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  str:SetPoint("CENTER");
  str:SetTextColor(1, 1, 1);
  str:SetText("Cooldown");

  local defaultSpellId = 0;
  local _, _, classId = UnitClass("player");

  if classId == 7 then
    print("shaman");
    defaultSpellId = 188196; -- Lightning bolt
  end
  if classId == 9 then
    print("warlock");
    defaultSpellId = 686; -- Shadow bolt
  end
  if classId == 10 then
    print("monk");
    defaultSpellId = 100780; -- Tiger Palm
  end

  frame:SetScript("OnUpdate", function(self, event, ...)
    cooldown = GetSpellCooldown(defaultSpellId);

    if cooldown > 0 then
      texture:SetColorTexture(0, 1, 0);
    end
    if cooldown == 0 then
      texture:SetColorTexture(1, 0, 0);
    end
  end)
end

CreateCombatFrame();
CreateDataFrame();

CreateMapDataFrame(0);
CreateMapDataFrame(1);
CreateMapDataFrame(2);
CreateMapDataFrame(3);

CreateXDataFrame(0);
CreateXDataFrame(1);
CreateXDataFrame(2);
CreateXDataFrame(3);

CreateYDataFrame(0);
CreateYDataFrame(1);
CreateYDataFrame(2);
CreateYDataFrame(3);

CreateRotationDataFrame(0);
CreateRotationDataFrame(1);
CreateRotationDataFrame(2);
CreateRotationDataFrame(3);

CreateRangeCheckFrame();
CreateCooldownCheckFrame();