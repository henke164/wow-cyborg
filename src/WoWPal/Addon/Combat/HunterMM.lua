local function RenderMultiTargetRotation(texture)
  if UnitChannelInfo("player") == "Rapid Fire" then
    return;
  end

  if FindBuff("player", "Trick Shots") == nil then
    if IsCastableAtEnemyTarget("Multi-Shot", 15) then
      return SetSpellRequest(texture, 6);
    end
  end

  if IsCastableAtEnemyTarget("Rapid Fire", 0) then
    if IsCastableAtEnemyTarget("Double Tap", 0) then
      return SetSpellRequest(texture, 1);
    end
    return SetSpellRequest(texture, 3);
  end

  if FindBuff("player", "Precise Shots") == "Precise Shots" then
    if IsCastableAtEnemyTarget("Multi-Shot", 15) then
      return SetSpellRequest(texture, 6);
    end
  end

  if IsCastableAtEnemyTarget("Aimed Shot", 30) then
    if IsMoving() == false then
      return SetSpellRequest(texture, 2);
    end
  end

  if IsCastableAtEnemyTarget("Multi-Shot", 45) then
    return SetSpellRequest(texture, 6);
  end
  
  if IsCastableAtEnemyTarget("Steady Shot", 0) then
    return SetSpellRequest(texture, 5);
  end

  return SetSpellRequest(texture, nil);
end

local function RenderSingleTargetRotation(texture)
  if UnitChannelInfo("player") == "Rapid Fire" then
    return;
  end

  if IsCastableAtEnemyTarget("Double Tap", 0) then
    return SetSpellRequest(texture, 1);
  end
  
  if IsCastableAtEnemyTarget("Aimed Shot", 30) then
    asCharges = GetSpellCharges("Aimed Shot");
    if asCharges == 2 then
      if IsMoving() == false then
        return SetSpellRequest(texture, 2);
      end
    end
  end
  
  if IsCastableAtEnemyTarget("Rapid Fire", 0) then
    return SetSpellRequest(texture, 3);
  end

  if FindBuff("player", "Precise Shots") == "Precise Shots" then
    if IsCastableAtEnemyTarget("Arcane Shot", 15) then
      return SetSpellRequest(texture, 4);
    end
  end

  if IsCastableAtEnemyTarget("Aimed Shot", 30) then
    if IsMoving() == false then
      return SetSpellRequest(texture, 2);
    end
  end

  if IsCastableAtEnemyTarget("Arcane Shot", 45) then
    return SetSpellRequest(texture, 4);
  end

  if IsCastableAtEnemyTarget("Steady Shot", 0) then
    return SetSpellRequest(texture, 5);
  end

  return SetSpellRequest(texture, nil);
end

function CreateHunterMMFrame()
  local frame, texture = CreateDefaultFrame(frameSize * 2, frameSize, frameSize, frameSize);

  frame:SetPropagateKeyboardInput(true);
  frame:SetScript("OnKeyDown", function(self, key)
    if key == "CAPSLOCK" then
      WowCyborg_AOE_Rotation = not WowCyborg_AOE_Rotation;
    end
  end)

  frame:SetScript("OnUpdate", function(self, event, ...)
    if WowCyborg_AOE_Rotation == true then
      RenderMultiTargetRotation(texture);
    end
    if WowCyborg_AOE_Rotation == false then
      RenderSingleTargetRotation(texture);
    end
  end)

  RenderFontFrame();
end