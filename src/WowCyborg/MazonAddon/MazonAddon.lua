WowCyborg_ISDEAD = false;
frameSize = 5;
WowCyborg_INCOMBAT = false;

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
      WowCyborg_INCOMBAT = true;
      texture:SetColorTexture(0, 1, 0);
    end
    if event == "PLAYER_REGEN_ENABLED" then
      WowCyborg_INCOMBAT = false;
      texture:SetColorTexture(1, 0, 0);
    end
  end)

  frame:SetScript("OnUpdate", function(self, event, ...)
    if UnitIsDeadOrGhost("Player") then
      WowCyborg_INCOMBAT = false;
      WowCyborg_ISDEAD = true;
      texture:SetColorTexture(0, 0, 1);
    else
      if WowCyborg_ISDEAD == true then
        WowCyborg_INCOMBAT = false;
        WowCyborg_ISDEAD = false;
        texture:SetColorTexture(1, 0, 0);
      end
    end
  end)
end

function CreateAlertFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE");

  frame:SetScript("OnEvent", function(self, event, ...)
    print("BOSS EMOTE!");
    if event == "CHAT_MSG_RAID_BOSS_EMOTE" then
      PlaySoundFile(567478);
    end
  end)
end

function TargetIsAlive()
  hp = UnitHealth("target");
  return hp > 0;
end

CreateCombatFrame();
CreateRotationFrame();
CreateWrapperFrame();
CreateAlertFrame();
