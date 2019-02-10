WowCyborg_AOE_Rotation = false;
WowCyborg_CURRENTATTACK = "-";
WowCyborg_HasFocus = false;

local spellButtonTexture;
local buttonCombinerTexture;

function CreateRotationFrame()
  frame, spellButtonTexture = CreateDefaultFrame(frameSize * 2, frameSize, frameSize, frameSize);
  _, buttonCombinerTexture = CreateDefaultFrame(frameSize * 3, frameSize, frameSize, frameSize);

  frame:SetScript("OnUpdate", function(self, event, ...)
    if WowCyborg_AOE_Rotation == true then
      RenderMultiTargetRotation();
    end
    if WowCyborg_AOE_Rotation == false then
      RenderSingleTargetRotation();
    end
  end)

  frame:RegisterEvent("PLAYER_FOCUS_CHANGED");
  frame:SetScript("OnEvent", function(self, event, ...)
    WowCyborg_HasFocus = UnitExists("Focus");
  end)

  
  RenderFontFrame();
end

function SetSpellRequest(buttonCombination)
  if buttonCombination == nil then
    r, g, b = GetColorFromNumber(nil);
    buttonCombinerTexture:SetColorTexture(r, g, b);
    spellButtonTexture:SetColorTexture(r, g, b);
    return;
  end

  local b1, b2 = strsplit("+", buttonCombination);

  if b2 == nil then
    buttonCombinerTexture:SetColorTexture(GetColorFromButton(nil));
    spellButtonTexture:SetColorTexture(GetColorFromNumber(tonumber(b1)));
    return
  end

  buttonCombinerTexture:SetColorTexture(GetColorFromButton(b1));
  spellButtonTexture:SetColorTexture(GetColorFromNumber(tonumber(b2)));
end

function IsMoving()
  local currentSpeed = GetUnitSpeed("player");
  return currentSpeed > 0;
end

function FindBuff(target, buffName)
  for i=1,40 do
    local name, _, _, _, _, etime = UnitBuff(target, i);
    if name == buffName then
      local time = GetTime();
      return name, etime - time;
    end
  end
end

function FindDebuff(target, buffName)
  for i=1,40 do
    local name, _, _, _, _, etime = UnitDebuff(target, i);
    if name == buffName then
      local time = GetTime();
      return name, etime - time;
    end
  end
end

function IsCastable(spellName, requiredEnergy)
  local spell, _, _, _, endTime = UnitCastingInfo("player");

  local energy = UnitPower("player");
  local cd = GetSpellCooldown(spellName, "spell");

  if cd == 0 then
    if energy >= requiredEnergy then
      return true;
    end
  end

  local charges = GetSpellCharges(spellName);
  if (charges == nil) == false then
    if charges > 0 then
      if energy >= requiredEnergy then
        return true;
      end
    end
  end
  
  return false;
end

function IsCastableAtFriendlyTarget(spellName, requiredEnergy)
  if IsSpellInRange(spellName, "target") == 0 then
    return false;
  end

  if UnitCanAttack("player", "target") == true then
    return false;
  end

  if TargetIsAlive() == false then
    return false;
  end;
  
  return IsCastable(spellName, requiredEnergy);
end

function IsCastableAtEnemyTarget(spellName, requiredEnergy)
  if IsSpellInRange(spellName, "target") == 0 then
    return false;
  end

  if UnitCanAttack("player", "target") == false then
    return false;
  end

  if TargetIsAlive() == false then
    return false;
  end;

  return IsCastable(spellName, requiredEnergy);
end

function GetHealthPercentage(unit)
  local maxHp = UnitHealthMax(unit);
  local hp = UnitHealth(unit);
  return (hp / maxHp) * 100;
end

function TargetIsAlive()
  hp = UnitHealth("target");
  return hp > 0;
end
  
function RenderFontFrame()
  local fontFrame, fontTexture = CreateDefaultFrame(frameSize * 5, frameSize * 5, 100, 20);
  fontFrame:SetMovable(true)
  fontFrame:EnableMouse(true)
  fontFrame:RegisterForDrag("LeftButton")
  fontFrame:SetScript("OnDragStart", fontFrame.StartMoving)
  fontFrame:SetScript("OnDragStop", fontFrame.StopMovingOrSizing)

  local str = fontFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
  str:SetPoint("CENTER");
  str:SetTextColor(1, 1, 1);

  local infoStr = fontFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  infoStr:SetPoint("CENTER", fontFrame, "CENTER", 0, -20);
  infoStr:SetTextColor(1, 1, 1);
  
  fontFrame:SetPropagateKeyboardInput(true);

  fontFrame:SetScript("OnKeyDown", function(self, key)
    if key == "CAPSLOCK" then
      WowCyborg_AOE_Rotation = not WowCyborg_AOE_Rotation;
    end
  end)
  
  fontFrame:SetScript("OnUpdate", function(self, event, ...)
    if WowCyborg_AOE_Rotation == true then
      fontTexture:SetColorTexture(1, 0, 0);
      str:SetText("Multi target");
      infoStr:SetText(WowCyborg_CURRENTATTACK);
    end
    
    if WowCyborg_AOE_Rotation == false then
      fontTexture:SetColorTexture(0, 0, 1);
      str:SetText("Single target");
      infoStr:SetText(WowCyborg_CURRENTATTACK);
    end
  end)
end
