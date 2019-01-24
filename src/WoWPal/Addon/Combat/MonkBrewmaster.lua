function IsCastable(spellName, requiredEnergy)
  local spell, _, _, _, endTime = UnitCastingInfo("player");

  energy = UnitPower("player");
  cd = GetSpellCooldown(spellName, "spell");

  if cd == 0 then
    if energy > requiredEnergy then
      return true;
    end
  end
  return false;
end

function IsCastableAtEnemyTarget(spellName, requiredEnergy)
  if CheckInteractDistance("target", 4) == false then
    return false;
  end

  if UnitCanAttack("player","target") == false then
    return false;
  end

  if TargetIsAlive() == false then
	return false;
  end;
  
  return IsCastable(spellName, requiredEnergy);
end

function IsLowHealth()
  maxHp = UnitHealthMax("player");
  hp = UnitHealth("player");
  perc = (hp / maxHp) * 100;
  return perc < 80;
end

function TargetIsAlive()
  hp = UnitHealth("target");
  return hp > 0;
end

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
        r, g, b = GetColorFromNumber(5);
        texture:SetColorTexture(r, g, b);
        return;
      end
    end

    if inCombat == false then
      if IsCastableAtEnemyTarget("Crackling Jade Lightning", 50) then
        r, g, b = GetColorFromNumber(1);
        texture:SetColorTexture(r, g, b);
        --str:SetText("Crackling Jade Lightning");
        return;
      end
    end

    if IsCastableAtEnemyTarget("Keg Smash", 40) then
      r, g, b = GetColorFromNumber(2);
      texture:SetColorTexture(r, g, b);
      --str:SetText("Keg Smash");
      return;
    end

    if IsCastableAtEnemyTarget("Blackout Strike", 0) then
      r, g, b = GetColorFromNumber(3);
      texture:SetColorTexture(r, g, b);
      --str:SetText("Blackout Strike");
      return;
    end
    
    if IsCastableAtEnemyTarget("Tiger Palm", 25) then
      r, g, b = GetColorFromNumber(4);
      texture:SetColorTexture(r, g, b);
      --str:SetText("Tiger Palm");
      return;
    end
    
    --str:SetText("Wait");
    r, g, b = GetColorFromNumber(nil);
    texture:SetColorTexture(r, g, b);
  end)
end
