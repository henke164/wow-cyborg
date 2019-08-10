frameSize = 5;

function CreateWrapperFrame()
  local frame, texture = CreateDefaultFrame(0, 0, frameSize * 4, frameSize);
  texture:SetColorTexture(1, 0, 1);
end

function CreateCombatFrame()
  local frame, texture = CreateDefaultFrame(0, frameSize, frameSize, frameSize);
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

function TargetIsAlive()
  hp = UnitHealth("target");
  return hp > 0;
end

function CreateFacingCheckFrame()
  local frame, texture = CreateDefaultFrame(frameSize, frameSize, frameSize, frameSize);
  frame:RegisterEvent("UI_ERROR_MESSAGE");
  frame:RegisterEvent("PLAYER_DAMAGE_DONE_MODS");
  texture:SetColorTexture(1, 0, 0);
  
  local lastCheck = GetTime();
  frame:SetScript("OnUpdate", function(self, event, ...)
    local time = GetTime();
    if time > lastCheck + 0.5 then
      lastCheck = time;
      texture:SetColorTexture(0, 1, 0);
    end
  end)

  frame:SetScript("OnEvent", function(self, event, ...)
    if event == "UI_ERROR_MESSAGE" then
      code, msg = ...;
      if code == 254 then
        texture:SetColorTexture(1, 0, 0);
        lastCheck = GetTime();
      end

      if code == 255 then
        texture:SetColorTexture(0, 0, 1);
        lastCheck = GetTime();
      end
    end
  end)
end

CreateCombatFrame();
CreateFacingCheckFrame();
CreateRotationFrame();
CreateWrapperFrame();