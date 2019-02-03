function CreateMonkBrewmasterFrame()
  local inCombat = false;
  local frame, texture = CreateDefaultFrame(frameSize * 2, frameSize, frameSize, frameSize);
  local str = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
  str:SetPoint("CENTER");
  str:SetTextColor(1, 1, 1);

  frame:RegisterEvent("PLAYER_REGEN_DISABLED");
  frame:RegisterEvent("PLAYER_REGEN_ENABLED");
  frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
      inCombat = true;
    end
    if event == "PLAYER_REGEN_ENABLED" then
      inCombat = false;
    end
  end)

  frame:SetScript("OnUpdate", function(self, event, ...)
    if GetHealthPercentage("target") > 95 then
      --return SetSpellRequest(texture, nil);
    end

    if IsCastableAtFriendlyTarget("Renewing Mist", 2800) then
      local rnMistBuff = FindBuff("target", "Renewing Mist");
      if rnMistBuff == nil then
        return SetSpellRequest(texture, 4);
      end
    end

    if IsCastableAtFriendlyTarget("Soothing Mist", 400) then
      local spell, _, _, _, endTimeMS = UnitChannelInfo("player");
      if spell == nil or 
        not spell == "Sooting Mist" or
        endTimeMS/1000 - GetTime() < 1.5 then
          return SetSpellRequest(texture, 2);
      end
    end
    
    if IsCastableAtFriendlyTarget("Enveloping Mist", 5200) then
      local envMistBuff = FindBuff("target", "Enveloping Mist");
      if envMistBuff == nil then
        return SetSpellRequest(texture, 1);
      end
    end
    
    if IsCastableAtFriendlyTarget("Vivify", 3500) then
      return SetSpellRequest(texture, 3);
    end
    
    return SetSpellRequest(texture, nil);
  end)
end