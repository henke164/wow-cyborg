--[[
  Button    Spell
  CTRL+2    Macro for assisting focus "/assist focus"
  1         Barbed shot
  2         Kill command
  3         Chimaera shot
  4         Murder of crows
  5         Beastial wrath
  6         Aspect of wild
  7         Cobra shot
  8         Multi shot
]]--
local isFollowing = false;
local stoppedFollowAt = 0;
local barbedShot = "1";
local killCommand = "2";
local chimaeraShot = "3";
local murderOfCrows = "4";
local beastialWrath = "5";
local aspectOfWild = "6";
local cobraShot = "7";
local multiShot = "8";
local follow = "CTRL+1";
local assist = "CTRL+2";
local mount = "CTRL+3";
local back = "CTRL+9";

local function GetBsCooldown()
  local bsCharges = GetSpellCharges("Barbed Shot");
  if bsCharges > 0 then
    return 0;
  end

  local bsStart, bsDuration = GetSpellCooldown("Barbed Shot");
  local bsCdLeft = bsStart + bsDuration - GetTime();
  return bsCdLeft;
end

function IsFollowing()
  if isFollowing then
    return true;
  end

  if stoppedFollowAt == 0 then
    return true;
  end

  if GetTime() <= stoppedFollowAt + 1 then
    return true;
  end

  return false;
end

function RenderMultiTargetRotation(texture)
  if IsFollowing() then
    WowCyborg_CURRENTATTACK = "Following...";
    return SetSpellRequest(nil);
  end

  if IsCastableAtEnemyTarget("Barbed Shot", 0) == false then
    local petBuff, petBuffTime = FindBuff("pet", "Frenzy");
    if petBuff == "Frenzy" and petBuffTime <= 3 then
      local bsCdLeft = GetBsCooldown();
      if bsCdLeft <= 2 then
        WowCyborg_CURRENTATTACK = "-";
        return SetSpellRequest(nil);
      end
    end
  end

  if IsCastableAtEnemyTarget("Barbed Shot", 0) then
    local petBuff, petBuffTime = FindBuff("pet", "Frenzy");
    if petBuff == "Frenzy" then
      if petBuffTime <= 2 then
        WowCyborg_CURRENTATTACK = "Barbed Shot";
        return SetSpellRequest(barbedShot);
      end
    end

    local bbCharges = GetSpellCharges("Barbed Shot");
    if bbCharges == 2 and petBuff == nil then
      WowCyborg_CURRENTATTACK = "Barbed Shot";
      return SetSpellRequest(barbedShot);
    end
  end

  local bcBuff, bcTimeLeft = FindBuff("player", "Beast Cleave");
  if bcBuff == nil or bcTimeLeft < 2 then
    if IsCastableAtEnemyTarget("Multi-Shot", 40) then
      WowCyborg_CURRENTATTACK = "Multi-Shot";
      return SetSpellRequest(multiShot);
    end
  end

  if IsCastableAtEnemyTarget("Kill Command", 30) then
    WowCyborg_CURRENTATTACK = "Kill Command";
    return SetSpellRequest(killCommand);
  end
    
  if IsCastableAtEnemyTarget("Aspect of the Wild", 0) then
    local bwBuff = FindBuff("player", "Bestial Wrath");
    local bwCd = GetSpellCooldown("Bestial Wrath", "spell");
    if bwCd == 0 or bwCd > 20 or not bwBuff == nil then
      WowCyborg_CURRENTATTACK = "Aspect of the Wild";
      return SetSpellRequest(aspectOfWild);
    end
  end

  if IsCastableAtEnemyTarget("Bestial Wrath", 0) then
    local aotwCd = GetSpellCooldown("Aspect of the Wild", "spell");
    local aotwBuff = FindBuff("player", "Aspect of the Wild");
    if aotwCd == 0 or aotwCd > 20 or not aotwBuff == nil then
      WowCyborg_CURRENTATTACK = "Bestial Wrath";
      return SetSpellRequest(beastialWrath);
    end
  end

  local bcBuff, bcTimeLeft = FindBuff("player", "Beast Cleave");
  if bcBuff == nil or bcTimeLeft < 2 then
    if IsCastableAtEnemyTarget("Multi-Shot", 40) then
      WowCyborg_CURRENTATTACK = "Multi-Shot";
      return SetSpellRequest(multiShot);
    end
  end

  if IsCastableAtEnemyTarget("Chimaera Shot", 0) then
    WowCyborg_CURRENTATTACK = "Chimaera Shot";
    return SetSpellRequest(chimaeraShot);
  end

  local energy = UnitPower("player");
  if IsCastableAtEnemyTarget("Cobra Shot", 0) and energy > 90 then
    WowCyborg_CURRENTATTACK = "Cobra Shot";
    return SetSpellRequest(cobraShot);
  end
  
  IdleOrAssist();
end

function RenderSingleTargetRotation(texture)
  if IsFollowing() then
    WowCyborg_CURRENTATTACK = "Following...";
    return false;
  end

  if IsCastableAtEnemyTarget("Barbed Shot", 0) == false then
    local petBuff, petBuffTime = FindBuff("pet", "Frenzy");
    if petBuff == "Frenzy" and petBuffTime <= 3 then
      local bsCdLeft = GetBsCooldown();
      if bsCdLeft <= 2 then
        WowCyborg_CURRENTATTACK = "-";
        return SetSpellRequest(nil);
      end
    end
  end

  if IsCastableAtEnemyTarget("Barbed Shot", 0) then
    local petBuff, petBuffTime = FindBuff("pet", "Frenzy");
    if petBuff == "Frenzy" then
      if petBuffTime <= 2 then
        WowCyborg_CURRENTATTACK = "Barbed Shot";
        return SetSpellRequest(barbedShot);
      end
    end

    local bbCharges = GetSpellCharges("Barbed Shot");
    if bbCharges == 2 and petBuff == nil then
      WowCyborg_CURRENTATTACK = "Barbed Shot";
      return SetSpellRequest(barbedShot);
    end
  end

  if IsCastableAtEnemyTarget("Kill Command", 30) then
    WowCyborg_CURRENTATTACK = "Kill Command";
    return SetSpellRequest(killCommand);
  end
  
  if IsCastableAtEnemyTarget("Chimaera Shot", 0) then
    WowCyborg_CURRENTATTACK = "Chimaera Shot";
    return SetSpellRequest(chimaeraShot);
  end

  if IsCastableAtEnemyTarget("A Murder of Crows", 30) then
    WowCyborg_CURRENTATTACK = "A Murder of Crows";
    return SetSpellRequest(murderOfCrows);
  end
  
  if IsCastableAtEnemyTarget("Bestial Wrath", 0) then
    local aotwCd = GetSpellCooldown("Aspect of the Wild", "spell");
    local aotwBuff = FindBuff("player", "Aspect of the Wild");
    if aotwCd == 0 or aotwCd > 20 or not aotwBuff == nil then
      WowCyborg_CURRENTATTACK = "Bestial Wrath";
      return SetSpellRequest(beastialWrath);
    end
  end
  
  if IsCastableAtEnemyTarget("Aspect of the Wild", 0) then
    local bwBuff = FindBuff("player", "Bestial Wrath");
    local bwCd = GetSpellCooldown("Bestial Wrath", "spell");
    if bwCd == 0 or bwCd > 20 or not bwBuff == nil then
      WowCyborg_CURRENTATTACK = "Aspect of the Wild";
      return SetSpellRequest(aspectOfWild);
    end
  end

  if IsCastableAtEnemyTarget("Cobra Shot", 0) then
    WowCyborg_CURRENTATTACK = "Cobra Shot";
    return SetSpellRequest(cobraShot);
  end

  IdleOrAssist();
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

function CreateEmoteListenerFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("CHAT_MSG_TEXT_EMOTE");
  frame:SetScript("OnEvent", function(self, event, ...)
    command = ...;
    if string.find(command, "follow", 1, true) then
      print("Following");
      SetSpellRequest(follow);
      isFollowing = true;
      stoppedFollowAt = 0;
    end
    if string.find(command, "wait", 1, true) then
      print("Waiting");
      SetSpellRequest(assist);
      isFollowing = false;
      stoppedFollowAt = GetTime();
    end
    if string.find(command, "fart", 1, true) then
      print("Mounting");
      SetSpellRequest(mount);
      isFollowing = false;
      startedFollowAt = 0;
      stoppedFollowAt = GetTime();
    end
    if string.find(command, "waves", 1, true) then
      print("Fall back");
      SetSpellRequest(back);
      isFollowing = false;
      stoppedFollowAt = GetTime();
    end
  end)
end

print("Beastmastery hunter follower rotation loaded");
CreateEmoteListenerFrame();