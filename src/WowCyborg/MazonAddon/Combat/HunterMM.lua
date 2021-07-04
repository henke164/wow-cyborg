--[[
  Button    Spell
  1         Double Tap
  2         Aimed Shot
  3         Rapid Fire
  4         Arcane Shot
  5         Steady Shot
  6         Multi Shot
]]--
local doubleTap = "1";
local aimedShot = "2";
local rapidFire = "3";
local arcaneShot = "4";
local steadyShot = "5";
local multiShot = "6";

function RenderMultiTargetRotation(texture)
  if UnitChannelInfo("player") == "Rapid Fire" then
    return SetSpellRequest(nil);
  end

  if FindBuff("player", "Trick Shots") == nil then
    if IsCastableAtEnemyTarget("Multi-Shot", 15) then
      return SetSpellRequest(multiShot);
    end
  end

  if IsCastableAtEnemyTarget("Rapid Fire", 0) then
    if IsCastableAtEnemyTarget("Double Tap", 0) then
      return SetSpellRequest(doubleTap);
    end
    return SetSpellRequest(rapidFire);
  end

  if FindBuff("player", "Precise Shots") == "Precise Shots" then
    if IsCastableAtEnemyTarget("Multi-Shot", 15) then
      return SetSpellRequest(multiShot);
    end
  end

  if IsCastableAtEnemyTarget("Aimed Shot", 30) then
    if IsMoving() == false then
      return SetSpellRequest(aimedShot);
    end
  end

  if IsCastableAtEnemyTarget("Multi-Shot", 45) then
    return SetSpellRequest(multiShot);
  end
  
  if IsCastableAtEnemyTarget("Steady Shot", 0) then
    return SetSpellRequest(steadyShot);
  end

  return IdleOrAssist();
end

function RenderSingleTargetRotation(texture)
  if UnitChannelInfo("player") == "Rapid Fire" then
    return SetSpellRequest(nil);
  end

  if IsCastableAtEnemyTarget("Double Tap", 0) then
    return SetSpellRequest(doubleTap);
  end
  
  if IsCastableAtEnemyTarget("Aimed Shot", 30) then
    asCharges = GetSpellCharges("Aimed Shot");
    if asCharges == 2 then
      if IsMoving() == false then
        return SetSpellRequest(aimedShot);
      end
    end
  end
  
  if IsCastableAtEnemyTarget("Rapid Fire", 0) then
    return SetSpellRequest(rapidFire);
  end

  if FindBuff("player", "Precise Shots") == "Precise Shots" then
    if IsCastableAtEnemyTarget("Arcane Shot", 15) then
      return SetSpellRequest(arcaneShot);
    end
  end

  if IsCastableAtEnemyTarget("Aimed Shot", 30) then
    if IsMoving() == false then
      return SetSpellRequest(aimedShot);
    end
  end

  if IsCastableAtEnemyTarget("Arcane Shot", 45) then
    return SetSpellRequest(arcaneShot);
  end

  if IsCastableAtEnemyTarget("Steady Shot", 0) then
    return SetSpellRequest(steadyShot);
  end

  return IdleOrAssist();
end


function IdleOrAssist()
  WowCyborg_CURRENTATTACK = "-";
  if not WowCyborg_HasFocus then
    return SetSpellRequest(nil);
  elseif UnitGUID("focustarget") == nil then
    return SetSpellRequest(nil);
  elseif UnitGUID("focustarget") == UnitGUID("target") then
    return SetSpellRequest(nil);
  end

  WowCyborg_CURRENTATTACK = "Assist focus";
  return SetSpellRequest(assist);
end

print("Marksman hunter follower rotation loaded");