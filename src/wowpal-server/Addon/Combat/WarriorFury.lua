--[[
  Button    Spell
  1         Rampage
  2         Recklessness
  3         Execute
  4         Bloodthirst
  5         Raging blow
  6         Whirlwind
  7         Siegebreaker
  8         Bladestorm
]]--

local rampage = 1;
local recklessness = 2;
local execute = 3;
local bloodthirst = 4;
local ragingBlow = 5;
local whirlwind = 6;
local siegeBreaker = 7;
local bladestorm = 8;

local function RenderMultiTargetRotation(texture)
  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(texture, nil);
  end

  local wwBuff = FindBuff("player", "Whirlwind");
  if wwBuff == nil then
    if IsCastableAtEnemyTarget("Whirlwind", 0) then
      WowCyborg_CURRENTATTACK = "Whirlwind";
      return SetSpellRequest(texture, whirlwind);
    end
  end

  if IsCastableAtEnemyTarget("Recklessness", 0) then
    WowCyborg_CURRENTATTACK = "Recklessness";
    return SetSpellRequest(texture, recklessness);
  end
  
  if IsCastableAtEnemyTarget("Siegebreaker", 0) then
    WowCyborg_CURRENTATTACK = "Siegebreaker";
    return SetSpellRequest(texture, siegeBreaker);
  end
  
  local enrageBuff = FindBuff("player", "Enrage");
  if enrageBuff == nil then
    if IsCastableAtEnemyTarget("Rampage", 75) then
      WowCyborg_CURRENTATTACK = "Rampage";
      return SetSpellRequest(texture, rampage);
    end
  end

  if IsCastableAtEnemyTarget("Bladestorm", 0) then
    WowCyborg_CURRENTATTACK = "Bladestorm";
    return SetSpellRequest(texture, bladestorm);
  end

  if IsCastableAtEnemyTarget("Whirlwind", 0) then
    WowCyborg_CURRENTATTACK = "Whirlwind";
    return SetSpellRequest(texture, whirlwind);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(texture, nil);
end

local function RenderSingleTargetRotation(texture)
  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(texture, nil);
  end

  local rage = UnitPower("player");
  local enrageBuff = FindBuff("player", "Enrage");
  if enrageBuff == nil or rage > 90 then
    if IsCastableAtEnemyTarget("Rampage", 75) then
      WowCyborg_CURRENTATTACK = "Rampage";
      return SetSpellRequest(texture, rampage);
    end
  end

  if IsCastableAtEnemyTarget("Recklessness", 0) then
    WowCyborg_CURRENTATTACK = "Recklessness";
    return SetSpellRequest(texture, recklessness);
  end

  local enemyHP = GetHealthPercentage("target");
  local sdBuff = FindBuff("player", "Sudden Death");

  if enemyHP < 20 or sdBuff == "Sudden Death" then
    if enrageBuff == "Enrage" and IsCastableAtEnemyTarget("Execute", 0) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(texture, execute);
    end
  end

  if enrageBuff == nil and IsCastableAtEnemyTarget("Bloodthirst", 0) then
    WowCyborg_CURRENTATTACK = "Bloodthirst";
    return SetSpellRequest(texture, bloodthirst);
  end

  local rbCharges = GetSpellCharges("Raging Blow")
  WowCyborg_CURRENTATTACK = "Raging Blow";
  if rbCharges == 2 and IsCastableAtEnemyTarget("Raging Blow", 0) then
    return SetSpellRequest(texture, ragingBlow);
  end

  if IsCastableAtEnemyTarget("Bloodthirst", 0) then
    WowCyborg_CURRENTATTACK = "Bloodthirst";
    return SetSpellRequest(texture, bloodthirst);
  end
  
  if rbCharges > 0 and IsCastableAtEnemyTarget("Raging Blow", 0) then
    WowCyborg_CURRENTATTACK = "Raging Blow";
    return SetSpellRequest(texture, ragingBlow);
  end

  if IsCastableAtEnemyTarget("Whirlwind", 0) then
    WowCyborg_CURRENTATTACK = "Whirlwind";
    return SetSpellRequest(texture, whirlwind);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(texture, nil);
end

function InMeleeRange()
  return IsSpellInRange("Execute", "target") == 1;
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