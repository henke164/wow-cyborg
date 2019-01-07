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
  local frame, texture = CreateDefaultFrame(0, 10, 10, 10);
  frame:RegisterEvent("PLAYER_REGEN_DISABLED");
  frame:RegisterEvent("PLAYER_REGEN_ENABLED");

  frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
      texture:SetColorTexture(0, 1, 0);
    end
    if event == "PLAYER_REGEN_ENABLED" then
      texture:SetColorTexture(1, 0, 0);
    end
  end)
end

function CreateRangeCheckFrame()
  local frame, texture = CreateDefaultFrame(10, 10, 20, 10);
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
  local frame, texture = CreateDefaultFrame(30, 10, 10, 10);
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
CreateRangeCheckFrame();
CreateCooldownCheckFrame();