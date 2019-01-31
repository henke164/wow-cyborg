function CreateMonkBrewmasterFrame()
  local inCombat = false;
  local frame, texture = CreateDefaultFrame(0, -40, 40, 10);
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
    if IsLowHealth() then
      if IsCastable("Healing Elixir", 0) then
        return SetSpellRequest(texture, 5);
      end
    end

    if inCombat == false then
      if IsCastableAtEnemyTarget("Crackling Jade Lightning", 50) then
        return SetSpellRequest(texture, 1);
      end
    end

    if IsCastableAtEnemyTarget("Keg Smash", 40) then
      return SetSpellRequest(texture, 2);
    end

    if IsCastableAtEnemyTarget("Blackout Strike", 0) then
      return SetSpellRequest(texture, 3);
    end
    
    if IsCastableAtEnemyTarget("Tiger Palm", 25) then
      return SetSpellRequest(texture, 4);
    end
    
    return SetSpellRequest(texture, nil);
  end)
end
