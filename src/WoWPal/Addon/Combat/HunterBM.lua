function CreateHunterBMFrame()
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
    if IsCastableAtEnemyTarget("Barbed Shot", 0) then
      charges = GetSpellCharges("Barbed Shot");
      petBuff, petBuffTime = FindBuff("pet", "Frenzy");

      if charges == 2 or petBuff == nil or petBuffTime <= 1 then
        return SetSpellRequest(texture, 1);
      end
    end

    if IsCastableAtEnemyTarget("Kill Command", 30) then
      return SetSpellRequest(texture, 2);
    end
    
    if IsCastableAtEnemyTarget("Chimaera Shot", 0) then
      return SetSpellRequest(texture, 3);
    end

    if IsCastableAtEnemyTarget("A Murder of Crows", 30) then
      return SetSpellRequest(texture, 4);
    end
    
    if IsCastableAtEnemyTarget("Bestial Wrath", 0) then
      aotwCd = GetSpellCooldown("Aspect of the Wild", "spell");
      aotwBuff = FindBuff("player", "Aspect of the Wild");
      if aotwCd == 0 or aotwCd > 20 or not aotwBuff == nil then
        return SetSpellRequest(texture, 5);
      end
    end
    
    if IsCastableAtEnemyTarget("Aspect of the Wild", 0) then
      bwBuff = FindBuff("player", "Bestial Wrath");
      bwCd = GetSpellCooldown("Bestial Wrath", "spell");
      if bwCd == 0 or bwCd > 20 or not bwBuff == nil then
        return SetSpellRequest(texture, 6);
      end
    end

    if IsCastableAtEnemyTarget("Cobra Shot", 0) then
      return SetSpellRequest(texture, 7);
    end
    return SetSpellRequest(texture, nil);
  end)
end
