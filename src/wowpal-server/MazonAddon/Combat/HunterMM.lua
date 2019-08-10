local function RenderMultiTargetRotation(texture)
  if UnitChannelInfo("player") == "Rapid Fire" then
    return;
  end

  if FindBuff("player", "Trick Shots") == nil then
    if IsCastableAtEnemyTarget("Multi-Shot", 15) then
      return SetSpellRequest(6);
    end
  end

  if IsCastableAtEnemyTarget("Rapid Fire", 0) then
    if IsCastableAtEnemyTarget("Double Tap", 0) then
      return SetSpellRequest(1);
    end
    return SetSpellRequest(3);
  end

  if FindBuff("player", "Precise Shots") == "Precise Shots" then
    if IsCastableAtEnemyTarget("Multi-Shot", 15) then
      return SetSpellRequest(6);
    end
  end

  if IsCastableAtEnemyTarget("Aimed Shot", 30) then
    if IsMoving() == false then
      return SetSpellRequest(2);
    end
  end

  if IsCastableAtEnemyTarget("Multi-Shot", 45) then
    return SetSpellRequest(6);
  end
  
  if IsCastableAtEnemyTarget("Steady Shot", 0) then
    return SetSpellRequest(5);
  end

  return SetSpellRequest(nil);
end

local function RenderSingleTargetRotation(texture)
  if UnitChannelInfo("player") == "Rapid Fire" then
    return;
  end

  if IsCastableAtEnemyTarget("Double Tap", 0) then
    return SetSpellRequest(1);
  end
  
  if IsCastableAtEnemyTarget("Aimed Shot", 30) then
    asCharges = GetSpellCharges("Aimed Shot");
    if asCharges == 2 then
      if IsMoving() == false then
        return SetSpellRequest(2);
      end
    end
  end
  
  if IsCastableAtEnemyTarget("Rapid Fire", 0) then
    return SetSpellRequest(3);
  end

  if FindBuff("player", "Precise Shots") == "Precise Shots" then
    if IsCastableAtEnemyTarget("Arcane Shot", 15) then
      return SetSpellRequest(4);
    end
  end

  if IsCastableAtEnemyTarget("Aimed Shot", 30) then
    if IsMoving() == false then
      return SetSpellRequest(2);
    end
  end

  if IsCastableAtEnemyTarget("Arcane Shot", 45) then
    return SetSpellRequest(4);
  end

  if IsCastableAtEnemyTarget("Steady Shot", 0) then
    return SetSpellRequest(5);
  end

  return SetSpellRequest(nil);
end

print("Marksman hunter rotation loaded");