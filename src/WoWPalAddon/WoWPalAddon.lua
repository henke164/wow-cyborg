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
  local frame, texture = CreateDefaultFrame(0, 70, 200, 20);
  frame:RegisterEvent("PLAYER_REGEN_DISABLED");
  frame:RegisterEvent("PLAYER_REGEN_ENABLED");
  frame:SetScript("OnEvent", function(self, event, ...)
      if event == "PLAYER_REGEN_DISABLED" then
        texture:SetColorTexture(1, 0, 0);
      end
      if event == "PLAYER_REGEN_ENABLED" then
        texture:SetColorTexture(0, 1, 0);
      end
  end)
end

function CreateDataFrame()
  local frame = CreateDefaultFrame(0, 0, 200, 120);
  local str = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
  str:SetPoint("CENTER");
  str:SetTextColor(1, 1, 1);
  frame:SetScript("OnUpdate", function(self, event, ...)
      facing = GetPlayerFacing();
      px, py = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY()
      str:SetText(px .. "\n\n" .. py .. "\n\n" .. facing);
  end)
end

function CreateRangeCheckFrame()
  local frame, texture = CreateDefaultFrame(0, -70, 200, 20);
  frame:SetScript("OnUpdate", function(self, event, ...)
    texture:SetColorTexture(1, 0, 0);
    if CheckInteractDistance("target", 4) then
      texture:SetColorTexture(0, 1, 0);
    end
  end)
end

CreateCombatFrame();
CreateDataFrame();
CreateRangeCheckFrame();