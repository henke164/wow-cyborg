local rampage = 1;
local recklessness = 2;
local execute = 3;
local bloodthirst = 4;
local ragingBlow = 5;
local whirlwind = 7;
local siegeBreaker = 8;
local bladestorm = 9;

local function RenderMultiTargetRotation(texture)
  local wwBuff = FindBuff("player", "Whirlwind");
  if wwBuff == nil then
    if IsCastableAtEnemyTarget("Whirlwind", 0) then
      return SetSpellRequest(texture, whirlwind);
    end
  end

  if IsCastableAtEnemyTarget("Recklessness", 0) then
    return SetSpellRequest(texture, recklessness);
  end
  
  if IsCastableAtEnemyTarget("Siegebreaker", 0) then
    return SetSpellRequest(texture, siegeBreaker);
  end
  
  local enrageBuff = FindBuff("player", "Enrage");
  if enrageBuff == nil then
    if IsCastableAtEnemyTarget("Rampage", 75) then
      return SetSpellRequest(texture, rampage);
    end
  end

  if IsCastableAtEnemyTarget("Bladestorm", 0) then
    return SetSpellRequest(texture, rampage);
  end

  if IsCastableAtEnemyTarget("Whirlwind", 0) then
    return SetSpellRequest(texture, whirlwind);
  end
  
  return SetSpellRequest(texture, nil);
end

local function RenderSingleTargetRotation(texture)
  local rage = UnitPower("player");
  local enrageBuff = FindBuff("player", "Enrage");
  if enrageBuff == nil or rage > 90 then
    if IsCastableAtEnemyTarget("Rampage", 75) then
      return SetSpellRequest(texture, rampage);
    end
  end

  if IsCastableAtEnemyTarget("Recklessness", 0) then
    return SetSpellRequest(texture, recklessness);
  end

  if enrageBuff == "Enrage" and IsCastableAtEnemyTarget("Execute", 0) then
    return SetSpellRequest(texture, execute);
  end

  if enrageBuff == nil and IsCastableAtEnemyTarget("Bloodthirst", 0) then
    return SetSpellRequest(texture, bloodthirst);
  end

  local rbCharges = GetSpellCharges("Raging Blow")
  if rbCharges == 2 and IsCastableAtEnemyTarget("Raging Blow", 0) then
    return SetSpellRequest(texture, ragingBlow);
  end

  if IsCastableAtEnemyTarget("Bloodthirst", 0) then
    return SetSpellRequest(texture, bloodthirst);
  end
  
  if rbCharges > 0 and IsCastableAtEnemyTarget("Raging Blow", 0) then
    return SetSpellRequest(texture, ragingBlow);
  end

  if IsCastableAtEnemyTarget("Whirlwind", 0) then
    return SetSpellRequest(texture, whirlwind);
  end

  return SetSpellRequest(texture, nil);
end

function CreateRotationFrame()
  print("Fury warrior rotation loaded");
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