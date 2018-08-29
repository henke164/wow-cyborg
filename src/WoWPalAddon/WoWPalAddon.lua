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
    local combatFrame, combatTexture = CreateDefaultFrame(0, 70, 200, 20);
    combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
    combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
    combatFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            combatTexture:SetColorTexture(1, 0, 0);
        end
        if event == "PLAYER_REGEN_ENABLED" then
            combatTexture:SetColorTexture(0, 1, 0);
        end
    end)
end

function CreateDataFrame()
    local dataFrame = CreateDefaultFrame(0, 0, 200, 120);
    local dataString = dataFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    dataString:SetPoint("CENTER");
    dataString:SetTextColor(1, 1, 1);
    dataFrame:SetScript("OnUpdate", function(self, event, ...)
        local facing = GetPlayerFacing();
        local px, py = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY()
        dataString:SetText(px .. "\n\n" .. py .. "\n\n" .. facing);
    end)
end

CreateCombatFrame();
CreateDataFrame();