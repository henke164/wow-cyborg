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
      if (UnitIsEnemy("target","player")) then
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
CreateRangeCheckFrame();
CreateCooldownCheckFrame();