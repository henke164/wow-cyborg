local barbedShot = 1;
local killCommand = 2;
local chimaeraShot = 3;
local murderOfCrows = 4;
local beastialWrath = 5;
local aspectOfWild = 6;
local cobraShot = 7;
local multiShot = 8;

local function GetBsCooldown()
  local bsCharges = GetSpellCharges("Barbed Shot");
  if bsCharges > 0 then
    return 0;
  end

  local bsStart, bsDuration = GetSpellCooldown("Barbed Shot");
  local bsCdLeft = bsStart + bsDuration - GetTime();
  return bsCdLeft;
end

local function RenderMultiTargetRotation(texture)
  if IsCastableAtEnemyTarget("Barbed Shot", 0) == false then
    local petBuff, petBuffTime = FindBuff("pet", "Frenzy");
    if petBuff == "Frenzy" and petBuffTime <= 3 then
      local bsCdLeft = GetBsCooldown();
      if bsCdLeft <= 2 then
        return;
      end
    end
  end

  if IsCastableAtEnemyTarget("Barbed Shot", 0) then
    local petBuff, petBuffTime = FindBuff("pet", "Frenzy");
    if petBuff == "Frenzy" then
      if petBuffTime <= 2 then
        return SetSpellRequest(texture, barbedShot);
      end
    end

    local bbCharges = GetSpellCharges("Barbed Shot");
    if bbCharges == 2 and petBuff == nil then
      return SetSpellRequest(texture, barbedShot);
    end
  end

  local bcBuff, bcTimeLeft = FindBuff("player", "Beast Cleave");
  if bcBuff == nil or bcTimeLeft < 2 then
    if IsCastableAtEnemyTarget("Multi-Shot", 40) then
      return SetSpellRequest(texture, multiShot);
    end
  end

  if IsCastableAtEnemyTarget("Kill Command", 30) then
    return SetSpellRequest(texture, killCommand);
  end
    
  if IsCastableAtEnemyTarget("Aspect of the Wild", 0) then
    local bwBuff = FindBuff("player", "Bestial Wrath");
    local bwCd = GetSpellCooldown("Bestial Wrath", "spell");
    if bwCd == 0 or bwCd > 20 or not bwBuff == nil then
      return SetSpellRequest(texture, aspectOfWild);
    end
  end

  if IsCastableAtEnemyTarget("Bestial Wrath", 0) then
    local aotwCd = GetSpellCooldown("Aspect of the Wild", "spell");
    local aotwBuff = FindBuff("player", "Aspect of the Wild");
    if aotwCd == 0 or aotwCd > 20 or not aotwBuff == nil then
      return SetSpellRequest(texture, beastialWrath);
    end
  end

  local bcBuff, bcTimeLeft = FindBuff("player", "Beast Cleave");
  if bcBuff == nil or bcTimeLeft < 2 then
    if IsCastableAtEnemyTarget("Multi-Shot", 40) then
      return SetSpellRequest(texture, multiShot);
    end
  end

  if IsCastableAtEnemyTarget("Chimaera Shot", 0) then
    return SetSpellRequest(texture, chimaeraShot);
  end

  local energy = UnitPower("player");
  if IsCastableAtEnemyTarget("Cobra Shot", 0) and energy > 90 then
    return SetSpellRequest(texture, cobraShot);
  end
end

local function RenderSingleTargetRotation(texture)
  if IsCastableAtEnemyTarget("Barbed Shot", 0) == false then
    local petBuff, petBuffTime = FindBuff("pet", "Frenzy");
    if petBuff == "Frenzy" and petBuffTime <= 3 then
      local bsCdLeft = GetBsCooldown();
      if bsCdLeft <= 2 then
        return;
      end
    end
  end

  if IsCastableAtEnemyTarget("Barbed Shot", 0) then
    local petBuff, petBuffTime = FindBuff("pet", "Frenzy");
    if petBuff == "Frenzy" then
      if petBuffTime <= 2 then
        return SetSpellRequest(texture, barbedShot);
      end
    end

    local bbCharges = GetSpellCharges("Barbed Shot");
    if bbCharges == 2 and petBuff == nil then
      return SetSpellRequest(texture, barbedShot);
    end
  end

  if IsCastableAtEnemyTarget("Kill Command", 30) then
    return SetSpellRequest(texture, killCommand);
  end
  
  if IsCastableAtEnemyTarget("Chimaera Shot", 0) then
    return SetSpellRequest(texture, chimaeraShot);
  end

  if IsCastableAtEnemyTarget("A Murder of Crows", 30) then
    return SetSpellRequest(texture, murderOfCrows);
  end
  
  if IsCastableAtEnemyTarget("Bestial Wrath", 0) then
    local aotwCd = GetSpellCooldown("Aspect of the Wild", "spell");
    local aotwBuff = FindBuff("player", "Aspect of the Wild");
    if aotwCd == 0 or aotwCd > 20 or not aotwBuff == nil then
      return SetSpellRequest(texture, beastialWrath);
    end
  end
  
  if IsCastableAtEnemyTarget("Aspect of the Wild", 0) then
    local bwBuff = FindBuff("player", "Bestial Wrath");
    local bwCd = GetSpellCooldown("Bestial Wrath", "spell");
    if bwCd == 0 or bwCd > 20 or not bwBuff == nil then
      return SetSpellRequest(texture, aspectOfWild);
    end
  end

  if IsCastableAtEnemyTarget("Cobra Shot", 0) then
    return SetSpellRequest(texture, cobraShot);
  end

  return SetSpellRequest(texture, nil);
end

function CreateRotationFrame()
  print("Beastmastery hunter rotation loaded");
  local frame, texture = CreateDefaultFrame(frameSize * 2, frameSize, frameSize, frameSize);

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